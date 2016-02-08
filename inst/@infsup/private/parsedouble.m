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
## @deftypefun {[@var{SIGN}, @var{EXPONENT}, @var{MANTISSA}] =} parsedouble (@var{X})
## 
## Parse a finite binary floating point number @var{X} in double precision.
##
## The mantissa is normalized, the implicit first bit is moved after the point
## @code{@var{X} = (-1) ^ @var{SIGN} * @var{MANTISSA} (=0.XXXXX… in binary) * 2 ^ @var{EXPONENT}}.
## @end deftypefun

## Author: Oliver Heimlich
## Created: 2014-10-24

function [sign, exponent, mantissa] = parsedouble (binary)

if (not (isfinite (binary)) || isnan (binary))
    assert (false (), "Invalid call to parsedouble");
endif

## Decode bit representation
hex = num2hex (binary); # 16 hexadecimal digits (with leading zeros)
hexvalues = rem (uint8 (hex) - 47, 39); # 1 .. 16
lookup = [0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1;...
          0 0 0 0 1 1 1 1 0 0 0 0 1 1 1 1;...
          0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1;...
          0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1];
bits = (logical (lookup (:, hexvalues))) (:)';

## Separate sign, exponent, and mantissa bits.
sign = bits(1);
exponent = bits(2 : 12);
fraction = bits(13 : end)';

if (sum (exponent) == 0) # denormalized numbers
    mantissa = fraction;
else # normalized numbers
    mantissa = [true(); fraction];
endif

## Decode IEEE 754 exponent
exponent = int64(pow2 (10 : -1 : 0) * exponent') - 1023;

## binary == (-1) ^ sign * fraction (=X.XXXXX… in binary) * 2 ^ exponent

exponent ++;

endfunction