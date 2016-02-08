## Copyright 2014-2016 Oliver Heimlich
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
## @documentencoding UTF-8
## @deffun double2decimal (@var{X})
## 
## Convert a binary floating point number @var{X} in double precision to a
## decimal floating point number with arbitrary precision.  The number must be
## a finite number and must not be NaN.
##
## Conversion is exact, because @code{rem (10, 2) == 0}.
##
## Sign: true (-) or false (+)
##
## Mantissa: Vector that holds the decimal digits after the decimal point.  The
## first digit is not zero.  Trailing zeroes are removed.
##
## Exponent: Integral exponent (base 10).
##
## @example
## @group
## x = double2decimal (-200)
##   @result{}
##     x.s = 1
##     x.m = [2]
##     x.e = 2
## y = double2decimal (0.125)
##   @result{}
##     y.s = 0
##     y.m = [1 2 5]'
##     y.e = 0
## z = double2decimal (0)
##   @result{}
##     z.s = 0
##     z.m = []
##     z.e = 0
## @end group
## @end example
## @seealso{str2decimal}
## @end deffun

## Author: Oliver Heimlich
## Created: 2014-09-29

function decimal = double2decimal (binary)

[decimal.s, exponent, fraction] = parsedouble (binary);

if (sum (fraction) == 0) # this number equals zero
    decimal.s = false; # normalize: remove sign from -0
    decimal.m = [];
    decimal.e = int64 (0);
    return
endif

## Remove trailing zeroes if this might reduce the number of loop cycles below
if (exponent < length (fraction))
    fraction = fraction(1:find (fraction, 1, "last"));
endif

## Move the point to the end of the mantissa and interpret mantissa as a binary
## integer number that is now in front of the point. Convert binary integer
## to decimal.
exponent -= length (fraction);
decimal.m = zeros ();
for i = 1 : length(fraction)
    ## Multiply by 2
    decimal.m .*= 2;
    ## Add 1 if necessary
    decimal.m(end) += fraction(i);
    ## Carry
    decimal.m = [0; rem(decimal.m, 10)] ...
              + [(decimal.m >= 10); 0];
endfor
clear fraction;

## Normalize: Remove leading zeroes (for performance reasons not in loop)
decimal.m = decimal.m(find (decimal.m ~= 0, 1, "first"):end);
assert (length (decimal.m) > 0, "number must not equal zero at this point");
decimal.e = int64 (length (decimal.m));

## Multiply decimal integer with 2 ^ exponent
while (exponent > 0)
    decimal.m .*= 2;
    decimal.m = [0; rem(decimal.m, 10)] ...
              + [(decimal.m >= 10); 0];
    if (decimal.m(1) == 0)
        decimal.m(1) = [];
    else
        decimal.e ++;
    endif
    exponent --;
endwhile
while (exponent < 0)
    ## Instead of division by 2 we devide by 10 and multiply by 5
    decimal.e --; # cheap division by 10
    decimal.m .*= 5;
    decimal.m = [0; rem(decimal.m, 10)] ...
              + [floor(decimal.m ./ 10); 0];
    if (decimal.m(1) == 0)
        decimal.m(1) = [];
    else
        decimal.e ++;
    endif
    exponent ++;
endwhile

## Normalize mantissa: remove trailing zeroes;
decimal.m = decimal.m(1 : find (decimal.m ~= 0, 1, "last"));

endfunction