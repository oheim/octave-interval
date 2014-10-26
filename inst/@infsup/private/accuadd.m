## Copyright 2014 Oliver Heimlich
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {@var{ACCUMULATOR} =} accuadd (@var{ACCUMULATOR}, @var{ADDEND})
## 
## Add the @var{ADDEND} to the accumulator with infinite precision.
##
## @end deftypefn

## Author: Oliver Heimlich
## Created: 2014-10-26

function [accumulator] = accuadd (accumulator, addend)

if (addend == 0)
    return
endif

assert (isa (addend, "double"));
assert (not (isnan (addend)));
assert (isfinite (addend));

[s, e, mantissa] = parsedouble (addend);
    
## Increase the accumulator's size if neccessary
if (e > accumulator.e)
    accumulator.m = [zeros(1, e - accumulator.e, "int8"), accumulator.m];
    accumulator.e = e;
endif
if (length (mantissa) + accumulator.e - e > length (accumulator.m))
    accumulator.m = [accumulator.m, ...
                     zeros(1, length (mantissa) - length (accumulator.m) ...
                            + accumulator.e - e, "int8")];
endif

## Add the number into the accumulator
accumulator.m ((1 + accumulator.e - e) : ...
               (length (mantissa) + accumulator.e - e)) += (-1)^s * mantissa';

## Lazy carry
carry = (accumulator.m - rem (accumulator.m, 64)) / 2;
accumulator.m += [carry(2 : end), zeros(1, 1, "int8")] ...
               - int8 (2) * carry;
if (carry (1) ~= 0)
    accumulator.e ++;
    accumulator.m = [carry(1), accumulator.m];
endif

endfunction