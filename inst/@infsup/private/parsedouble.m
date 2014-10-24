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
## @deftypefn {Function File} {[@var{SIGN}, @var{EXPONENT}, @var{MANTISSA}] =} parsedouble (@var{X})
## 
## Parse a finite binary floating point number @var{X} in double precision.
##
## The mantissa is normalized, the implicit first bit is moved after the point
## @code{@var{X} = (-1) ^ @var{SIGN} * @var{MANTISSA} (=0.XXXXX… in binary) * 2 ^ @var{EXPONENT}}.
## @end deftypefn

## Author: Oliver Heimlich
## Created: 2014-10-24

function [sign, exponent, mantissa] = parsedouble (binary)

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
sign = bits(1);
exponent = bits(2 : 12);
fraction = bits(13 : end)';
clear bits;

assert (sum (exponent) < 11, "NaNs and infinite values not allowed");

if (sum (exponent) == 0) # denormalized numbers
    mantissa = fraction;
else # normalized numbers
    mantissa = [true(); fraction];
endif

## Decode IEEE 754 exponent
exponent = int64(bin2dec (num2str (exponent))) - 1023;

## binary == (-1) ^ sign * fraction (=X.XXXXX… in binary) * 2 ^ exponent

exponent ++;

endfunction