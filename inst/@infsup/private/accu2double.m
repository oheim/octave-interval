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
## @deftypefn {Function File} {[@var{BINARY}, @var{ISEXACT}] =} accu2double (@var{ACCUMULATOR}, @var{DIRECTION})
## 
## Compute an approximation of the accumulator's content in double precision.
##
## @end deftypefn

## Author: Oliver Heimlich
## Created: 2014-10-26

function [binary, isexact] = accu2double (accumulator, direction)

## Carry
## All operations on the accumulator perform a lazy carry and use the 8 bits
## as good as possible.  Now we want at most 1 bit (plus sign) per digit.
while (find (abs(accumulator.m) > 1, 1))

    carry = (accumulator.m - rem (accumulator.m, 2)) / 2;
    accumulator.m += [carry(2 : end), zeros(1, 1, "int8")] ...
                   - int8(2) * carry;
    if (carry (1) ~= 0)
        accumulator.e ++;
        accumulator.m = [carry(1), accumulator.m];
    endif
endwhile

## Resolve negative bits in the accumulator
s = false ();
while (1)
    highestnegativebit = find (accumulator.m < 0, 1);
    if (isempty (highestnegativebit))
        break;
    endif
    highestpositivebit = find (accumulator.m > 0, 1);
    
    if (isempty (highestpositivebit) || ...
        highestnegativebit < highestpositivebit)
        ## Flip sign
        s = not (s);
        accumulator.m *= -1;
    else
        ## Exchange 2 bits against 1 higher bit.
        assert (accumulator.m (1) >= 0);
        accumulator.m += 2 * (accumulator.m < 0) ...
                       - [(accumulator.m (2:end) < 0), zeros(1, 1, "int8")];
    endif
endwhile
clear highestnegativebit highestpositivebit;

## Normalize: Remove leading zeroes
firstnonzerodigit = find (accumulator.m ~= 0, 1, "first");
if (firstnonzerodigit > 1)
    accumulator.m = accumulator.m (firstnonzerodigit : end);
    accumulator.e -= firstnonzerodigit - 1;
elseif (isempty (firstnonzerodigit)) # all digits are zero
    binary = 0;
    isexact = true ();
    return
endif
clear firstnonzerodigit;

## Check for overflow 
if (accumulator.e > 1024) # > realmax
    isexact = false ();
    if (s && direction < 0)
        binary = -inf;
    elseif (s)
        binary = -realmax ();
    elseif (direction <= 0)
        binary = realmax ();
    else
        binary = inf;
    endif
    return
endif

## Check for underflow
if (accumulator.e <= -1074) # < subnormal numbers
    isexact = false ();
    if ((s && direction > 0) || (not (s) && direction < 0))
        binary = 0;
    elseif (s)
        binary = -pow2 (-1074);
    else
        binary = pow2 (-1074);
    endif
    return
endif

## Extract up to 53 bits for an approximate double
## Subnormal numbers must have less than 53 bit.
significand = abs (accumulator.m (1 : (min (53, accumulator.e + 1074))));
rest = accumulator.m ((1 + length (significand)) : end);

## The following calculation is exact in double format
binary = realpow (-1, s) * bin2dec (num2str (significand')') ...
       * pow2 (double (accumulator.e - length (significand)));

if (sum (rest) == 0)
    ## binary is the exact result
    isexact = true ();
else
    ## binary is a rounded number (rounded towards zero)
    isexact = false ();
    if ((s && direction > 0) || ...
        (not (s) && direction < 0))
        ## Rounding occurred as desired
    else
        delta = pow2 (-1074);
        fesetround (direction);
        if (direction > 0)
            binary = binary + delta;
        else
            binary = binary - delta;
        endif
        fesetround (0.5);
    endif
endif
endfunction