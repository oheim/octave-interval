/*
 * This file contains useful tools and data for triple double data representation.
 *
 * Copyright (C) 2004-2011 David Defour, Catherine Daramy-Loirat,
 * Florent de Dinechin, Matthieu Gallet, Nicolas Gast, Christoph Quirin Lauter,
 * and Jean-Michel Muller
 *
 * This file is part of crlibm, the correctly rounded mathematical library,
 * which has been developed by the Arénaire project at École normale supérieure
 * de Lyon.
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

#include "triple-double.h"
#include "crlibm_private.h"


#if TRIPLEDOUBLE_AS_FUNCTIONS

#if 0
void Renormalize3(double* resh, double* resm, double* resl, double ah, double am, double al)
{                                                      
  DoRenormalize3(resh, resm, resl, ah, am, al);
}
#endif


void Mul23(double* resh, double* resm, double* resl, double ah, double al, double bh, double bl)                
{
  DoMul23(resh, resm, resl, ah, al, bh, bl);
}

void Mul233(double* resh, double* resm, double* resl, double ah, double al, double bh, double bm, double bl)            
{
  DoMul233(resh, resm, resl, ah, al, bh, bm, bl);
}

void Mul33(double* resh, double* resm, double* resl, double ah, double am, double al, double bh, double bm, double bl)            
{
  DoMul33(resh, resm, resl, ah, am, al, bh, bm, bl);
}

void Mul133(double* resh, double* resm, double* resl, double a, double bh, double bm, double bl)
{
  DoMul133(resh, resm, resl, a, bh, bm, bl);
}

void Mul123(double* resh, double* resm, double* resl, double a, double bh,  double bl)
{
  DoMul123(resh, resm, resl, a, bh, bl);
}

void Sqrt13(double* resh, double* resm, double* resl, double x)
{
  DoSqrt13(resh, resm, resl , x);
}

void Recpr33(double* resh, double* resm, double* resl, double dh, double dm, double dl)
{
  DoRecpr33(resh, resm, resl, dh, dm, dl);
}

#endif /* TRIPLEDOUBLE_AS_FUNCTIONS*/
