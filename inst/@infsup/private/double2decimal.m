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

## usage: double2decimal (X)
##
## Convert a binary floating point number X in double precision to a decimal
## floating point number with arbitrary precision.  The number must be a finite
## number and must not be NaN.
##
## Conversion is exact, because rem (10, 2) == 0.
##
## Sign:     true (-) or false (+)
## Mantissa: Vector that holds the decimal digits after the decimal point.
##           Normalization: The first digit is not zero.
##           Normalization: Trailing zeroes are removed.
## Exponent: Integral exponent (base 10).
##
## See also:
##  str2decimal
##
## Example:
##  x = double2decimal (-200);
##      # x.s = 1
##      # x.m = [2]
##      # x.e = 2
##  y = str2decimal (0.125);
##      # y.s = 0
##      # y.m = [1 2 5]'
##      # y.e = 0
##  z = str2decimal (0);
##      # z.s = 0
##      # z.m = []
##      # z.e = 0

## Author: Oliver Heimlich
## Keywords: binary decimal conversion
## Created: 2014-09-29

function decimal = double2decimal (binary)

assert (isa (binary, "double"));
assert (not (isnan (binary)));
assert (isfinite (binary));

## Decode bit representation
hex = num2hex (binary); # 16 hexadecimal digits (with leading zeroes)
## The conversion has to be done in 2 steps, because hex2dec uses binary
## floating point numbers instead of a uint64.
bits1 = prepad (dec2bin (hex2dec (hex(1 : 8))), 32, "0", 2) == "1";
bits2 = prepad (dec2bin (hex2dec (hex(9 : end))), 32, "0", 2) == "1";
bits = [bits1, bits2];
clear hex bits1 bits2;

## Separate sign, exponent, and mantissa bits.
decimal.s = bits(1);
exponent = bits(2 : 12);
fraction = bits(13 : end)';
clear bits;

assert (sum (exponent) < 11, "NaNs and infinite values not allowed");

if (sum (exponent) == 0) # denormalized numbers
    if (sum (fraction) == 0) # this number equals zero
        decimal.s = false; # normalize: remove sign from -0
        decimal.m = [];
        decimal.e = int64 (0);
        return
    endif
else # normalized numbers
    fraction = [true(); fraction];
endif

## Decode IEEE 754 exponent
exponent = int64(bin2dec (num2str (exponent))) - 1023;

## binary == (-1) ^ sign * fraction (=X.XXXXX… in binary) * 2 ^ exponent

## Remove trailing zeroes if this might reduce the number of loop cycles below
if (exponent < length (fraction) - 1)
    fraction = fraction(1:find (fraction, 1, "last"));
endif

## Move the point to the end of the mantissa and interpret mantissa as a binary
## integer number that is now in front of the point. Convert binary integer
## to decimal.
exponent -= length (fraction) - 1;
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