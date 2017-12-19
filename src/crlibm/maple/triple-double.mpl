# This file is part of crlibm, the correctly rounded mathematical library,
# which has been developed by the Arénaire project at École normale supérieure
# de Lyon.
#
# Copyright (C) 2004-2011 David Defour, Catherine Daramy-Loirat,
# Florent de Dinechin, Matthieu Gallet, Nicolas Gast, Christoph Quirin Lauter,
# and Jean-Michel Muller
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA

read "common-procedures.mpl":


#---------------------------------------------------------------------
# hi_mi_lo takes an arbitrary precision number x and returns three doubles such that:
# x ~ x_hi + x_mi + x_lo
hi_mi_lo:= proc(x)
local x_hi, x_mi, x_lo, res:
x_hi:= nearest(evalf(x)):
res:=x-x_hi:
if (res = 0) then
  x_mi:=0:
  x_lo:=0:
else
  x_mi:=nearest(evalf(res)):
  res:=x-(x_hi+x_mi);
  if (res = 0) then
    x_lo:=0:
  else
    x_lo:=nearest(evalf(res)):
  end if:
end if:
x_hi,x_mi,x_lo:
end:


#---------------------------------------------------------------------
# same as hi_mi_lo, but returns hexadecimal strings
ieeehexa3:=proc(x)
local x_hi, x_mi, x_lo;
  x_hi, x_mi, x_lo := hi_mi_lo(x):
  ieeehexa(x_hi), ieeehexa(x_mi), ieeehexa(x_lo):
end proc:


#---------------------------------------------------------------------
#Like poly_exact, but the first n coefficients as triple doubles, 
#the next m coefiicients as double doubles and the rest as doubles
#
poly_exact32:=proc(P,n,m)
local deg,i, coef, coef_hi, coef_mi, coef_lo, Q:
Q:= 0:
convert(Q, polynom):
deg:=degree(P,x):
  for i from 0 to deg do
    coef :=coeff(P,x,i):
    coef_hi, coef_mi, coef_lo:=hi_mi_lo(coef):
    Q:= Q + coef_hi*x^i:
    if(i<m+n) then
        Q := Q + coef_mi*x^i:
    fi: 
    if(i<n) then
	Q := Q + coef_lo*x^i:
    fi:
  od:
  return(Q):
end:


#---------------------------------------------------------------------
# Returns nearest double-double:
nearestDD := proc(x)
  local xh,xm:
  xh := nearest(x);
  xm := nearest(x - xh);
  evalf(xh + xm);
end:

#---------------------------------------------------------------------
# Returns nearest triple-double:
nearestTD := proc(x)
  local xh,xm,xl:
  xh := nearest(x);
  xm := nearest(x - xh);
  xl := nearest(x - (xh + xm));
  evalf(xh + xm + xl);
end:
