/*
 * Various declarations and macros shared by
 * several .c files, but useless to users of the library
 *
 * Copyright (C) 2002 David Defour and Florent de Dinechin
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

#ifdef WORDS_BIGENDIAN
  const db_number radix_one_double  = {{((1023+SCS_NB_BITS)<<20) ,               0x00000000 }}; 
  const db_number radix_two_double  = {{((1023+2*SCS_NB_BITS)<<20) ,             0x00000000 }}; 
  const db_number radix_mone_double = {{((1023-SCS_NB_BITS)<<20) ,               0x00000000 }}; 
  const db_number radix_mtwo_double = {{((1023-2*SCS_NB_BITS)<<20) ,             0x00000000 }}; 
  const db_number radix_rng_double  = {{((1023+SCS_NB_BITS*SCS_MAX_RANGE)<<20) , 0x00000000 }}; 
  const db_number radix_mrng_double = {{((1023-SCS_NB_BITS*SCS_MAX_RANGE)<<20) , 0x00000000 }};
  const db_number max_double        = {{0x7FEFFFFF ,                             0xFFFFFFFF }}; 
  const db_number min_double        = {{0x00000000 ,                             0x00000001 }}; 
#else
  const db_number radix_one_double  = {{0x00000000 , ((1023+SCS_NB_BITS)<<20)               }}; 
  const db_number radix_two_double  = {{0x00000000 , ((1023+2*SCS_NB_BITS)<<20)             }}; 
  const db_number radix_mone_double = {{0x00000000 , ((1023-SCS_NB_BITS)<<20)               }}; 
  const db_number radix_mtwo_double = {{0x00000000 , ((1023-2*SCS_NB_BITS)<<20)             }}; 
  const db_number radix_rng_double  = {{0x00000000 , ((1023+SCS_NB_BITS*SCS_MAX_RANGE)<<20) }}; 
  const db_number radix_mrng_double = {{0x00000000 , ((1023-SCS_NB_BITS*SCS_MAX_RANGE)<<20) }}; 
  const db_number max_double        = {{0xFFFFFFFF ,                             0x7FEFFFFF }}; 
  const db_number min_double        = {{0x00000001 ,                             0x00000000 }}; 
#endif

