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
## @deftypefn {Function File} {@var{ACCUMULATOR} =} accuaddproduct (@var{ACCUMULATOR}, @var{MULTIPLICAND}, @var{MULTIPLIER})
## 
## Perform exact multiplication and add the result to the accumulator with infinite precision.
##
## @end deftypefn

## Author: Oliver Heimlich
## Created: 2014-10-26

function [accumulator] = accuaddproduct (accumulator, multiplicand, multiplier)

if (multiplicand == 0 || multiplier == 0)
    return
endif

doubles.x = multiplicand;
doubles.y = multiplier;

for [doubleprecision, key] = doubles
    assert (isa (doubleprecision, "double"));
    assert (not (isnan (doubleprecision)));
    assert (isfinite (doubleprecision));

    [extendedprecision.(key).sign, ...
    extendedprecision.(key).exponent, ...
    mantissa] = parsedouble (doubleprecision);
    
    if (length (mantissa) < 53)
        # subnormal numbers
        mantissa = [mantissa; false];
        assert (length (mantissa) == 53);
    endif

    ## Move the point to the end of the mantissa and interpret mantissa as a
    ## binary integer number that is now in front of the point.
    extendedprecision.(key).exponent -= length (mantissa);
    
    ## Split mantissa into two parts with 27 and 26 bits
    extendedprecision.(key).high = uint64 (bin2dec (num2str (mantissa (1:27))'));
    extendedprecision.(key).low = uint64 (bin2dec (num2str (mantissa (28:end))'));
endfor

## Compute the exact product x * y.
## The result can almost always be stored as the sum of two binary64 numbers,
## but there would be a problem if the product happens to overflow or underflow
##
## We do the calulcation with integer arithmetic (ignoring the sign), 
##   x = a * 2^(26 + ex) + b * 2^ex
##   y = c * 2^(26 + ey) + d * 2^ey
## Mantissa parts a, b, c, and d are 26 or 27 bit unsigned integers.
## Exponents ex and ey are 11 or 12 bit signed integers.
##   x * y = (  a * c           * 2^52
##            + (a * d + b * c) * 2^26
##            + b * d
##           ) * 2^(ex + ey)
## Each addend can be computed and stored in uint64.
## The sum in brackets is an integral and can be stored in 106 bits.

## a * c -- 54 bits unsigned
ac = extendedprecision.x.high * extendedprecision.y.high;
## a * d + b * c -- 54 bits unsigned
adbc = extendedprecision.x.high * extendedprecision.y.low ...
     + extendedprecision.x.low * extendedprecision.y.high;
## b * d -- 52 bits unsigned
bd = extendedprecision.x.low * extendedprecision.y.low;

## a * c * 2^52 + (a * d + b * c) * 2^26 + b * d
binaryproduct = int8 ([prepad(dec2bin (ac) == "1", 54, 0, 2), ...
                       prepad(dec2bin (bd) == "1", 52, 0, 2)]);
binaryproduct(27 : 80) += prepad(dec2bin (adbc) == "1", 54, 0, 2);
clear ac adbc bd;

## x * y = s * binaryproduct * 2^e
s = sign (multiplicand) * sign (multiplier);
e = extendedprecision.x.exponent + extendedprecision.y.exponent;
assert (length (binaryproduct) == 106);

## Increase the accumulator's size if neccessary
if (e + length (binaryproduct) > accumulator.e)
    accumulator.m = [zeros(1, ...
                     e + length (binaryproduct) - accumulator.e, "int8"), ...
                     accumulator.m];
    accumulator.e = e + length (binaryproduct);
endif
if (accumulator.e - length (accumulator.m) > e)
    accumulator.m = [accumulator.m, ...
                     zeros(1, ...
                     accumulator.e - length (accumulator.m) - e, "int8")];
endif

## Add the product into the accumulator
accumulator.m ((accumulator.e - e - length (binaryproduct) + 1) : ...
               (accumulator.e - e)) += s * binaryproduct;

## Lazy carry
carry = (accumulator.m - rem (accumulator.m, 64)) / 2;
accumulator.m += [carry(2 : end), zeros(1, 1, "int8")] ...
               - int8 (2) * carry;
if (carry (1) ~= 0)
    accumulator.e ++;
    accumulator.m = [carry(1), accumulator.m];
endif

endfunction