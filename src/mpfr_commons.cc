/*
  Copyright 2015-2016 Oliver Heimlich
  
  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 3 of the License, or
  (at your option) any later version.
  
  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.
  
  You should have received a copy of the GNU General Public License
  along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

#include <octave/oct.h>
#include <mpfr.h>

#define BINARY64_PRECISION 53
#define BINARY64_ACCU_PRECISION 2134 + 2150

mpfr_rnd_t parse_rounding_mode (const double octave_rounding_direction)
{
  // Use rounding mode semantics from the GNU Octave fenv package
  mpfr_rnd_t mp_rnd;
  if (octave_rounding_direction == INFINITY)
    mp_rnd = MPFR_RNDU;
  else if (octave_rounding_direction == -INFINITY)
    mp_rnd = MPFR_RNDD;
  else if (octave_rounding_direction == 0.0)
    mp_rnd = MPFR_RNDZ;
  else
    // default mode
    mp_rnd = MPFR_RNDN;
  
  return mp_rnd;
}

void exact_interval_dot_product (
  mpfr_t accu_l, mpfr_t accu_u,    // Add result into the accu
  const MArray <double> vector_xl, // Lower boundary of first parameter
  const MArray <double> vector_xu, // Upper boundary of first parameter
  const MArray <double> vector_yl, // Lower boundary of second parameter
  const MArray <double> vector_yu) // Upper boundary of second parameter
{
  if (! vector_xl.is_vector () ||
      ! vector_xu.is_vector () ||
      ! vector_yl.is_vector () ||
      ! vector_yu.is_vector ())
    {
      error ("dot product can only be computed over vectors");
      return;
    }

  const octave_idx_type n = vector_xl.numel ();
  if (n != vector_xu.numel () ||
      n != vector_yl.numel () ||
      n != vector_yu.numel ())
    {
      error ("vectors must be of equal size");
      return;
    }

  if (mpfr_cmp (accu_l, accu_u) > 0)
    // Accu is already [Empty]
    return;

  mpfr_t mp_addend_l, mp_addend_u, mp_temp;
  mpfr_init2 (mp_addend_l, 2 * BINARY64_PRECISION + 1);
  mpfr_init2 (mp_addend_u, 2 * BINARY64_PRECISION + 1);
  mpfr_init2 (mp_temp,     2 * BINARY64_PRECISION + 1);
  for (octave_idx_type i = 0; i < n; i++)
    {
      const double xl = vector_xl.elem (i);
      const double xu = vector_xu.elem (i);
      const double yl = vector_yl.elem (i);
      const double yu = vector_yu.elem (i);
    
      if ((xl == INFINITY && xu == -INFINITY)
          ||
          (yl == INFINITY && yu == -INFINITY))
        {
          // [Empty] × Anything = [Empty]
          // [Empty] + Anything = [Empty]
          mpfr_set_inf (accu_l, +1);
          mpfr_set_inf (accu_u, -1);
          break;
        }

      if (mpfr_inf_p (accu_l) != 0 && mpfr_inf_p (accu_u) != 0)
        // [Entire] + Anything = [Entire]
        continue;

      if ((xl == 0.0 && xu == 0.0)
          ||
          (yl == 0.0 && yu == 0.0))
        // [0] × Anything = [0]
        continue;

      if ((xl == -INFINITY && xu == INFINITY)
          ||
          (yl == -INFINITY && yu == INFINITY))
        {
          // [Entire] × Anything = [Entire]
          mpfr_set_inf (accu_l, -1);
          mpfr_set_inf (accu_u, +1);
          continue;
        }

      // Both factors can be multiplied within 107 bits exactly!
      mpfr_set_d (mp_addend_l, xl, MPFR_RNDZ);
      mpfr_mul_d (mp_addend_l, mp_addend_l, yl, MPFR_RNDZ);
      mpfr_set (mp_addend_u, mp_addend_l, MPFR_RNDZ);

      // We have to compute the remaining 3 Products and determine min/max
      if (yl != yu)
        {
          mpfr_set_d (mp_temp, xl, MPFR_RNDZ);
          mpfr_mul_d (mp_temp, mp_temp, yu, MPFR_RNDZ);
          mpfr_min (mp_addend_l, mp_addend_l, mp_temp, MPFR_RNDZ);
          mpfr_max (mp_addend_u, mp_addend_u, mp_temp, MPFR_RNDZ);
        }
      if (xl != xu)
        {
          mpfr_set_d (mp_temp, xu, MPFR_RNDZ);
          mpfr_mul_d (mp_temp, mp_temp, yl, MPFR_RNDZ);
          mpfr_min (mp_addend_l, mp_addend_l, mp_temp, MPFR_RNDZ);
          mpfr_max (mp_addend_u, mp_addend_u, mp_temp, MPFR_RNDZ);
        }
      if (xl != xu || yl != yu)
        {
          mpfr_set_d (mp_temp, xu, MPFR_RNDZ);
          mpfr_mul_d (mp_temp, mp_temp, yu, MPFR_RNDZ);
          mpfr_min (mp_addend_l, mp_addend_l, mp_temp, MPFR_RNDZ);
          mpfr_max (mp_addend_u, mp_addend_u, mp_temp, MPFR_RNDZ);
        }

      // Compute sums
      if (mpfr_add (accu_l, accu_l, mp_addend_l, MPFR_RNDZ) != 0 ||
          mpfr_add (accu_u, accu_u, mp_addend_u, MPFR_RNDZ) != 0)
        error ("failed to compute exact dot product");
    }

  mpfr_clear (mp_addend_l);
  mpfr_clear (mp_addend_u);
  mpfr_clear (mp_temp);
}
