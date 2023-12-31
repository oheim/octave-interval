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

Digits := 120:

interface(quiet=true):

read "common-procedures.mpl":
read "triple-double.mpl":


#---------------------------------------------------------------------
# Procedure gal computes a number x and a boolean such that 
# 
# if the boolean is true
# - |x - xstart| is minimal 
# - x = roundX(x) (x is a floating point number in format roundX)
# - |(roundY(f(x)) - f(x)) / f(x)| <= eps
#
# and the boolean is false if no such x could be found in iter iterations
#
# Limitations:
#
# - floating point numbers xp such that f(xp) = 0 are not considered
# 
# Uses: 
#
# - The successor function succX for floating point numbers roundX(t)

gal:=proc(xstart,roundX,f,roundY,epsi,succX,iter)
local xleft, xright, i, err, ima, d, x, eps, b;
d := Digits;
Digits := 120;
eps := abs(epsi);
xleft := roundX(xstart);
xright := roundX(succX(roundX(xstart)));
x := 0;
i := 0;
err := eps * 2;
while ((err > eps) and (i < iter)) do
	i := i + 1;
	if (type(i,odd)) then
		x := xright;
		xright := evalf(roundX(succX(roundX(xright))));
	else
		x := xleft;
		xleft := evalf(roundX(-succX(roundX(-xleft))));
	end if;
	ima := evalf(f(x));
	if (ima <> 0) then 
		err := evalf(abs((ima - roundY(ima))/ima));
	end if;
end do;
b := false;
if (i < iter) then b := true; end if;
Digits := d;
(x,b);
end proc:


galDoubleToDouble:=proc(xstart,f,epsi,iter)
local g,b,xn; 
(g,b) := gal(xstart,nearest,f,nearest,epsi,succDouble,iter);
if (b) then xn := g; else xn = xstart; end if; 
xn;
end proc:

galDoubleToDoubleDouble:=proc(xstart,f,epsi,iter) 
local g,b,xn; 
(g,b) := gal(xstart,nearest,f,nearestDD,epsi,succDouble,iter);
if (b) then xn := g; else xn = xstart; end if;
xn;
end proc:


