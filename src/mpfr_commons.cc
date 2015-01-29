/*
  Copyright 2015 Oliver Heimlich
  
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

#define DOUBLE_PRECISION 53

mpfr_rnd_t parse_rounding_mode (const NDArray octave_rounding_direction)
{
  // Use rounding mode semantics from the GNU Octave fenv package
  mpfr_rnd_t mp_rnd;
  if (octave_rounding_direction.elem (0) == INFINITY)
    mp_rnd = MPFR_RNDU;
  else if (octave_rounding_direction.elem (0) == -INFINITY)
    mp_rnd = MPFR_RNDD;
  else if (octave_rounding_direction.elem (0) == 0)
    mp_rnd = MPFR_RNDZ;
  else
    // default mode
    mp_rnd = MPFR_RNDN;
  
  return mp_rnd;
}
