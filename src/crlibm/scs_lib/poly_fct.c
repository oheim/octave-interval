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


/*
 * result = z + (x * y)
 */
/* z->sign = X_SGN . Y_SGN */
void scs_fma(scs_ptr result,  scs_ptr x,  scs_ptr y,  scs_ptr z){
  uint64_t RES[2*SCS_NB_WORDS];
  uint64_t val, tmp;
  int i, j, ind, Diff;    

  ind = X_IND + Y_IND; 

  for(i=0; i<=SCS_NB_WORDS+1; i++)
    RES[i]=0;
  
  for(i=0 ; i<SCS_NB_WORDS; i++){
    for(j=0; j<(SCS_NB_WORDS-i); j++){
      RES[i+j] += (uint64_t)X_HW[i] * Y_HW[j];
    }}

  /* if we can perform an add */
  if (z->sign == (X_SGN * Y_SGN)){
    Diff = z->index - ind;
    if (Diff >= 0){
      for(i=(SCS_NB_WORDS-1), j=(SCS_NB_WORDS-Diff); j>=0; i--, j--)
	RES[i] = z->h_word[i] + RES[j];     
      for(  ; i>=0; i--)
	RES[i] = z->h_word[i]; 
    }else {    
      for(i=(SCS_NB_WORDS+Diff), j=(SCS_NB_WORDS-1); i>=0; i--, j--)
	RES[j] = z->h_word[i] + RES[j];     
    }

    /* Carry propagate */
    RES[SCS_NB_WORDS-1] += (RES[SCS_NB_WORDS]>>SCS_NB_BITS);
    for(i=(SCS_NB_WORDS-1); i>0; i--)
      {tmp = RES[i]>>SCS_NB_BITS;  RES[i-1] += tmp;  RES[i] -= (tmp<<SCS_NB_BITS);}
    
    val = RES[0] >> SCS_NB_BITS;
    R_IND = X_IND + Y_IND;
    
    /* Store the result */
    if(val != 0){
      /* shift all the digits ! */     
      R_HW[0] = (unsigned int)val;
      R_HW[1] = (unsigned int)(RES[0] - (val<<SCS_NB_BITS));
      for(i=2; i<SCS_NB_WORDS; i++)
	R_HW[i] = (unsigned int)RES[i-1];
      
      R_IND += 1;
    }
    else {
      for(i=0; i<SCS_NB_WORDS; i++)
	R_HW[i] = (unsigned int)RES[i];
    }
    
    R_EXP = (z->exception.d + (X_EXP * Y_EXP)) - 1;
    R_SGN = X_SGN * Y_SGN;
  
  }else {
    /* we have to do a sub */

    /* Carry propagate */
    RES[SCS_NB_WORDS-1] += (RES[SCS_NB_WORDS]>>SCS_NB_BITS);
    for(i=(SCS_NB_WORDS-1); i>0; i--)
      {tmp = RES[i]>>SCS_NB_BITS;  RES[i-1] += tmp;  RES[i] -= (tmp<<SCS_NB_BITS);}
    
    val = RES[0] >> SCS_NB_BITS;
    R_IND = X_IND + Y_IND;
    
    /* Store the result */
    if(val != 0){
      /* shift all the digits ! */     
      R_HW[0] = (unsigned int)val;
      R_HW[1] = (unsigned int)(RES[0] - (val<<SCS_NB_BITS));
      for(i=2; i<SCS_NB_WORDS; i++)
	R_HW[i] = (unsigned int)RES[i-1];
      
      R_IND += 1;
    }
    else {
      for(i=0; i<SCS_NB_WORDS; i++)
	R_HW[i] = (unsigned int)RES[i];
    }
    
    R_EXP = (X_EXP * Y_EXP);
    R_SGN = X_SGN * Y_SGN;

    scs_add(result, result, z);
  }
}
