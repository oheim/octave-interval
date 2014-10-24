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
## @deftypefn {Interval Function} {@var{R} =} fma (@var{X}, @var{Y}, @var{Z})
## @cindex IEEE1788 fma
## 
## Fused multiply and add @code{@var{X} * @var{Y} + @var{Z}}.  Multiply each
## number of interval @var{X} with each number of interval @var{Y} and add
## each number of interval @var{Z}.
##
## This function is semantically equivalent to evaluating multiplication and
## addition separately, but in addition guarantees a tight enclosure of the
## result.  The fused multiply and add is much slower.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## fma (infsup (1+eps), infsup (7), infsup ("0.1"))
##   @result{} [7.1000000000000014, 7.1000000000000024]
## infsup (1+eps) * infsup (7) + infsup ("0.1")
##   @result{} [7.1000000000000005, 7.1000000000000024]
## @end group
## @end example
## @seealso{plus, mtimes}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-03

function result = fma (x, y, z)

assert (nargin == 3);

## Convert first parameter into interval, if necessary
if (not (isa (x, "infsup")))
    x = infsup (x);
endif

## Convert second parameter into interval, if necessary
if (not (isa (y, "infsup")))
    y = infsup (y);
endif

## Convert third parameter into interval, if necessary
if (not (isa (z, "infsup")))
    z = infsup (z);
endif


if (isempty (x) || isempty (y) || isempty (z))
    result = infsup ();
    return
endif

if ((x.inf == 0 && x.sup == 0) || ...
    (y.inf == 0 && y.sup == 0))
    result = infsup (z.inf, z.sup);
    return
endif

if (isentire (x) || isentire (y) || isentire (z))
    result = infsup (-inf, inf);
    return
endif

if (y.sup <= 0)
    if (x.sup <= 0)
        l = fmarounded (x.sup, y.sup, z.inf, -inf);
        u = fmarounded (x.inf, y.inf, z.sup, inf);
    elseif (x.inf >= 0)
        l = fmarounded (x.sup, y.inf, z.inf, -inf);
        u = fmarounded (x.inf, y.sup, z.sup, inf);
    else
        l = fmarounded (x.sup, y.inf, z.inf, -inf);
        u = fmarounded (x.inf, y.inf, z.sup, inf);
    endif
elseif (y.inf >= 0)
    if (x.sup <= 0)
        l = fmarounded (x.inf, y.sup, z.inf, -inf);
        u = fmarounded (x.sup, y.inf, z.sup, inf);
    elseif (x.inf >= 0)
        l = fmarounded (x.inf, y.inf, z.inf, -inf);
        u = fmarounded (x.sup, y.sup, z.sup, inf);
    else
        l = fmarounded (x.inf, y.sup, z.inf, -inf);
        u = fmarounded (x.sup, y.sup, z.sup, inf);
    endif
else
    if (x.sup <= 0)
        l = fmarounded (x.inf, y.sup, z.inf, -inf);
        u = fmarounded (x.inf, y.inf, z.sup, inf);
    elseif (x.inf >= 0)
        l = fmarounded (x.sup, y.inf, z.inf, -inf);
        u = fmarounded (x.sup, y.sup, z.sup, inf);
    else
        l = min (...
            fmarounded (x.inf, y.sup, z.inf, -inf), ...
            fmarounded (x.sup, y.inf, z.inf, -inf));
        u = max (...
            fmarounded (x.inf, y.inf, z.sup, inf), ...
            fmarounded (x.sup, y.sup, z.sup, inf));
    endif
endif

result = infsup (l, u);

endfunction

function result = fmarounded (x, y, z, direction)

## Unfortunately we do not have access to an IEEE 754 fused multiply-add
## operation with directed rounding in GNU Octave's M-files, so we have
## to do the math in detail ourself...

if (isnan (x) || isnan (y) || isnan (z))
    result = nan ();
    return
endif

if (x == 0 || y == 0)
    if (isfinite (x) && isfinite (y))
        result = z;
    else
        result = nan ();
    endif
    return
endif

if (not (isfinite (x) && isfinite (y) && isfinite (z)))
    fesetround (0.5); # otherwise an overflow of x * y could break the result
    result = x * y + z; # == inf, -inf or NaN
    assert (not (isfinite (result)));
    return
endif

## Convert parameters to extended precision
parameters.x = x;
parameters.y = y;
parameters.z = z;
for [doubleprecision, key] = parameters
    hex = num2hex (doubleprecision); # 16 hexadecimal digits (leading zeroes)
    ## The conversion has to be done in 2 steps, because hex2dec uses binary
    ## floating point numbers instead of a uint64.
    bits1 = prepad (dec2bin (hex2dec (hex(1 : 8))), 32, "0", 2);
    bits2 = prepad (dec2bin (hex2dec (hex(9 : end))), 32, "0", 2);
    bits = [bits1 bits2];
    clear hex bits1 bits2;
    
    ## Separate sign, exponent, and mantissa bits.
    extendedprecision.(key).sign = bits(1) == "1";
    exponent = bits(2 : 12);
    fraction = bits(13 : end);
    clear bits;
    
    assert (sum (exponent == "1") < 11, ...
            "NaNs and infinite values not allowed");

    ## Decode IEEE 754 exponent
    exponent = bin2dec (exponent) - 1023;

    if (exponent == -1023)
        # denormalized numbers
        fraction = ["0" fraction];
        exponent ++;
    else # normalized numbers
        fraction = ["1" fraction];
    endif
    
    assert (length (fraction) == 53);

    ## Move the point to the end of the mantissa and interpret mantissa as a
    ## binary integer number that is now in front of the point.
    exponent -= length (fraction) - 1;
    extendedprecision.(key).exponent = int16(exponent);
    
    ## Split mantissa into two parts with 27 and 26 bits
    extendedprecision.(key).high = uint64 (bin2dec (fraction(1:27)));
    extendedprecision.(key).low = uint64 (bin2dec (fraction(28:end)));
endfor

## Check, if we really have to add the numbers:
## x * y is between 2^(ex + ey) inclusive and 2^(ex + ey + 107) exclusive
## z is between 2^ez inclusive and 2^(ez + 54) exclusive

if (extendedprecision.z.exponent >= ...
    extendedprecision.x.exponent + extendedprecision.y.exponent + 107 + 53)
    ## The magnitude of z is so big that the exact sum lies between z and
    ## one of its neighbours
    
    if ((sign (x) ~= sign (y) && direction > 0) || ...
        (sign (x) == sign (y) && direction < 0))
        result = z;
    else
        delta = pow2 (-1074);
        fesetround (direction);
        if (sign (x) == sign (y))
            result = z + delta;
        else
            result = z - delta;
        endif
        fesetround (0.5);
    endif
    return
endif

if (extendedprecision.x.exponent + extendedprecision.y.exponent >= ...
    extendedprecision.z.exponent + 54 + 53)
    ## The magnitude of x * y is so big that the exact sum lies between x * y
    ## and one of its floating point neighbours

    ## First using the opposite rounding direction and then going to nextup or
    ## nextdown will eventually use the desired rounding direction if x * y is 
    ## not a floting point number.
    ## If x * y is a floating point number this will lead us to the next higher
    ## or next lower floating point number because of the addition of z.
    fesetround (-direction);
    result = x * y;
    fesetround (direction);
    result += z;
    fesetround (0.5);
    
    ## Fix overflow
    if (not (isfinite (result)) && direction ~= result)
        result = sign (result) * realmax ();
    endif
    return
endif

## Part 1: Compute the exact product x * y.
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
accumulator = single ([prepad(dec2bin (ac) == "1", 54, 0, 2), ...
               prepad(dec2bin (bd) == "1", 52, 0, 2)]);
accumulator(27 : 80) += prepad(dec2bin (adbc) == "1", 54, 0, 2);
clear ac adbc bd;
## Carry
while (find (accumulator > 1, 1))
    assert (accumulator(1) <= 1);
    accumulator = [rem(accumulator, 2)] ...
                + [floor(accumulator(2 : end) ./ 2), 0];
endwhile

## x * y = (-1)^s * accumulator * 2^e
s = (sign (x) * sign (y) < 0);
e = extendedprecision.x.exponent + extendedprecision.y.exponent;

## Part 2: Add z to the exact product x * y

## Add trailing zeroes into the accumulator
if (e > extendedprecision.z.exponent)
    accumulator = [accumulator, false(1, e - extendedprecision.z.exponent)];
    e = extendedprecision.z.exponent;
endif

## Add leading zeroes to the accumulator
accumulator = [false(1, extendedprecision.z.exponent + 53 ...
                      - (e + length (accumulator))), accumulator];

## Add z into the accumulator
zbits = prepad (dec2bin (...
            extendedprecision.z.high * pow2 (26) + extendedprecision.z.low...
        ) == "1", 53, 0, 2);
if (extendedprecision.z.sign ~= s)
    ## If z has a different sign than x * y, we use negative bits in the
    ## accumulator.
    zbits *= -1;
endif
accumulator(...
    1 + e - extendedprecision.z.exponent + length (accumulator) - 53 ...
    : ...
    e - extendedprecision.z.exponent + length (accumulator)) ...
    += zbits;
clear zbits;

## Carry
while (find (accumulator > 1, 1))
    accumulator = [0, rem(accumulator, 2)] ...
                + [floor(accumulator ./ 2), 0];
endwhile

## Resolve negative bits in the accumulator
while (1)
    highestnegativebit = find (accumulator < 0, 1);
    if (isempty (highestnegativebit))
        break;
    endif
    highestpositivebit = find (accumulator > 0, 1);
    
    if (isempty (highestpositivebit) || ...
        highestnegativebit < highestpositivebit)
        ## Flip sign
        s = not (s);
        accumulator *= -1;
    else
        ## Exchange 2 bits against 1 higher bit.
        assert (accumulator(1) >= 0);
        accumulator += 2 * (accumulator < 0) ...
                    - [(accumulator(2:end) < 0), 0];
    endif
endwhile
clear highestnegativebit highestpositivebit;

## x * y + z = (-1)^s * accumulator * 2^e
if (sum (accumulator) == 0)
    result = 0;
    return
endif

## Normalize: Remove leading zeroes
accumulator = accumulator(find (accumulator ~= 0, 1, "first"):end);

## Normalize: Remove trailing zeroes
lastnonzerodigit = find (accumulator ~= 0, 1, "last");
if (lastnonzerodigit < length (accumulator))
    e += length (accumulator) - lastnonzerodigit;
    accumulator = accumulator(1:lastnonzerodigit);
endif
clear lastnonzerodigit;

## Check for overflow 
if (e + length (accumulator) - 1 >= 1024) # > realmax
    if (s && direction < 0)
        result = -inf;
    elseif (s)
        result = -realmax ();
    elseif (direction <= 0)
        result = realmax ();
    else
        result = inf;
    endif
    return
endif

## Check for underflow
if (e + length (accumulator) - 1 < -1074) # < subnormal numbers
    if ((s && direction > 0) || (not (s) && direction < 0))
        result = 0;
    elseif (s)
        result = -pow2 (-1074);
    else
        result = pow2 (-1074);
    endif
    return
endif

## Extract up to 53 bits for an approximate double
## Subnormal numbers must have less than 53 bit.
fraction = accumulator((min (e + 1074 + length (accumulator), 53) + 1) : end);
accumulator = accumulator(1 : (length (accumulator) - length (fraction)));
e += length (fraction);

## x * y + z = (-1)^s * accumulator.fraction * 2^e
## and (-1)^s * accumulator * 2^e is a binary64 floating point number

## The following calculation is exact in double format
binary = realpow (-1, s) * bin2dec (num2str (accumulator')') ...
       * pow2 (double (e));

if (isempty (fraction))
    ## binary is the exact fma
    result = binary;
else
    ## binary is a rounded fma (rounded towards zero)
    if ((s && direction > 0) || ...
        (not (s) && direction < 0))
        result = binary;
    else
        delta = pow2 (-1074);
        fesetround (direction);
        if (direction > 0)
            result = binary + delta;
        else
            result = binary - delta;
        endif
        fesetround (0.5);
    endif
endif    

endfunction