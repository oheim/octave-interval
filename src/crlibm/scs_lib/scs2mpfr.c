/*
 * Copyright (C) 2002 David Defour, Catherine Daramy, and Florent de Dinechin
 *
 * Author: David Defour
 *
 * This file is part of scslib, the Software Carry-Save multiple-precision
 * library, which has been developed by the Arénaire project at École normale
 * supérieure de Lyon.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 */


#include "scs.h"
#include "scs_private.h"

/* Compile only if mpfr is present */

#ifdef HAVE_MPFR_H


/*
 * Convert a scs number into a MPFR number rounded to nearest
 */
void scs_get_mpfr(scs_ptr x, mpfr_t rop){
    mpfr_t mp1;
    long int expo;
    int i;

    mpfr_set_ui(rop, 0, GMP_RNDN);

    /* mantissa */
    for (i=0; i<SCS_NB_WORDS; i++){
      mpfr_mul_2exp(rop, rop, SCS_NB_BITS, GMP_RNDN);
      mpfr_add_ui(rop, rop, X_HW[i], GMP_RNDN);
    }

    /* sign */
    if (X_SGN == -1) mpfr_neg(rop, rop, GMP_RNDN);

    /* exception */
    mpfr_init_set_d(mp1, X_EXP, GMP_RNDN); 
    mpfr_mul(rop, rop, mp1, GMP_RNDN);

    /* exponent */
    expo = (X_IND - SCS_NB_WORDS + 1) * SCS_NB_BITS;

    if (expo < 0)  mpfr_div_2exp(rop, rop, (unsigned int) -expo, GMP_RNDN);
    else           mpfr_mul_2exp(rop, rop, (unsigned int) expo, GMP_RNDN);

    mpfr_clear(mp1);
}
#endif /* HAVE_MPFR_H */
