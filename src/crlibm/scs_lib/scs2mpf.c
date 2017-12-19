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

/* Compile only if gmp is present */

#ifdef HAVE_GMP_H

/*
 * Convert a scs number into a MPF number (GMP)
 */
void scs_get_mpf(scs_ptr x, mpf_t rop){
    mpf_t mp1;
    long int expo;
    int i;

    mpf_set_ui(rop, 0);

    /* mantissa */
    for (i=0; i<SCS_NB_WORDS; i++){
      mpf_mul_2exp(rop, rop, SCS_NB_BITS);
      mpf_add_ui(rop, rop, X_HW[i]);
    }

    /* sign */
    if (X_SGN == -1) mpf_neg(rop, rop);

    /* exception */
    mpf_init_set_d(mp1, X_EXP); mpf_mul(rop, rop, mp1);

    /* exponent */
    expo = (X_IND - SCS_NB_WORDS + 1) * SCS_NB_BITS;

    if (expo < 0)  mpf_div_2exp(rop, rop, (unsigned int) -expo);
    else           mpf_mul_2exp(rop, rop, (unsigned int) expo);

    mpf_clear(mp1);
}
#endif /*HAVE_GMP_H*/
