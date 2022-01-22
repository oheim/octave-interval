/*
  Copyright 2022 Oliver Heimlich
  
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

// Implementation for MPFR version 3.x.y

#include <mpfr.h>

// mpfr_root has been deprecated in MPFR 4 and the new function mpfr_rootn_ui
// should be used instead.  For old MPFR versions, we simulate the
// new function with the help of the old function.
int mpfr_rootn_ui (
  mpfr_t rop,
  const mpfr_t op,
  const uint64_t n,
  const mpfr_rnd_t rnd)
{
  if (mpfr_zero_p (op)) {
    return mpfr_set (rop, op, rnd);
  } else {
    return mpfr_root (rop, op, n, rnd);
  }
}
