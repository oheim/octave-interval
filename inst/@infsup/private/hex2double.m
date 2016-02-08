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
## @deftypefun {[@var{X}, @var{ISEXACT}] =} hex2double (@var{S}, @var{DIRECTION})
## 
## Convert a hexadecimal floating point number @var{S} to double precision with
## directed rounding.
##
## The input number format is [+-]0xh[,.]h[[pP][+-]d].
##
## @seealso{str2decimal}
## @end deftypefun

## Author: Oliver Heimlich
## Created: 2014-10-20

function [binary, isexact] = hex2double (string, direction)

## Strip Sign
if (isempty (string))
    hex.s = false;
else
    hex.s = (string (1) == "-");
    if (strfind("+-", string(1)))
        string = string (2:end);
    endif
endif

## Strip hex indicator
if (strncmpi ("0x", string, 2))
    string = string (3:end);
else
    error ("interval:InvalidOperand", ...
           ["invalid hex number does not start with 0x: " string]);
endif

## Split mantissa & exponent
[hex.m, hex.e] = strtok (string, "pP");

## Convert exponent from string to number
if (isempty (hex.e))
    hex.e = int64(0); # 2 ^ 0 = 1
else
    if (strfind (hex.e, ".") || strfind (hex.e, ","))
        error ("interval:InvalidOperand", ...
               ["invalid hex number with rational exponent: " string]);
    endif
    hex.e = str2double (hex.e(2:end)); # remove “p” and convert
    if (isnan (hex.e) || ... # greater than realmax or illegal format
        abs(hex.e) >= pow2 (53)) # possibly lost precision
        error ("interval:InvalidOperand", ...
               ["invalid hex number with big/invalid exponent: " string]);
    endif
    hex.e = int64 (hex.e);
endif

## Split Mantissa at point
hex.m = strsplit (hex.m, {".",","});
switch length(hex.m)
    case 0
        hex.m = {"", ""};
    case 1
        hex.m{2} = "";
    case 2
        # nothing to do
    otherwise
        error ("interval:InvalidOperand", ...
               ["invalid hex number with multiple points: " string]);
endswitch

## Normalize mantissa string: move point to the right
if (hex.e - length (hex.m{2}) * 4 <= intmin (class (hex.e)))
    error ("interval:InvalidOperand", ...
           ["exponent overflow during normalization: " string ]);
endif
hex.e -= length (hex.m{2}) * 4;
hex.m = strcat (hex.m{1}, hex.m{2});

hexvalues = rem (uint8 (hex.m) - 47, 39); # 1 .. 16
lookup = [0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1;...
          0 0 0 0 1 1 1 1 0 0 0 0 1 1 1 1;...
          0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1;...
          0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1];
hex.m = (logical (lookup (:, hexvalues))) (:)';

## Normalize mantissa: remove leading zeroes
firstnonzerodigit = find (hex.m, 1, "first");
if (firstnonzerodigit > 1)
    hex.m = hex.m (firstnonzerodigit:end);
elseif (isempty (firstnonzerodigit))
    ## All digits are zero
    isexact = true ();
    if (hex.s)
        binary = -0;
    else
        binary = 0;
    endif
    return
endif

## Move point to the left, right after the first significand binary digit
if (length (hex.m) > 1)
    if (hex.e + (length (hex.m) - 1) >= intmax (class (hex.e)))
        error ("interval:InvalidOperand", ...
               ["exponent overflow during normalization: " string ]);
    endif
    hex.e += length (hex.m) - 1;
endif

## Overflow
if (hex.e > 1023)
    isexact = false ();
    if (hex.s && direction < 0)
        binary = -inf;
    elseif (hex.s)
        binary = -realmax ();
    elseif (direction > 0)
        binary = inf;
    else
        binary = realmax ();
    endif
    return
endif

## Underflow
if (hex.e < -1074)
    isexact = false ();
    if (hex.s && direction < 0)
        binary = -pow2 (-1074);
    elseif (hex.s)
        binary = -0;
    elseif (direction > 0)
        binary = pow2 (-1074);
    else
        binary = 0;
    endif
    return
endif

if (hex.e < -1022)
    ## Subnormal numbers
    hex.m = [zeros(1, -1022 - hex.e), hex.m];
    ieee754exponent = -1023;
else
    ## Normal numbers
    ieee754exponent = hex.e;
endif

## Only the most significand 53 bits are relevant.
significand = postpad (hex.m, 53, 0, 2);
isexact = length (hex.m) <= length (significand) || ...
          isempty (find (hex.m (54:end), 1));

## The first bit can be omitted (normalization).
significand (1) = [];

## The remaining 52 bits can be converted to 13 hex digits
ieee754mantissa = dec2hex (pow2 (51 : -1 : 0) * significand', 13);

if (not (hex.s))
    ieee754signandexponent = ieee754exponent + 1023;
else
    ieee754signandexponent = ieee754exponent + 1023 + pow2 (11);
endif

ieee754double = strcat (dec2hex (ieee754signandexponent, 3), ieee754mantissa);
binary = hex2num (ieee754double);

## Last, consider the rounding direction
if (isexact || ...
    (direction < 0 && not (hex.s)) ||
    (direction > 0 && hex.s))
    ## The number is exact or the truncation of digits above resulted in 
    ## correct rounding direction
else
    delta = pow2 (-1074);
    binary = mpfr_function_d ('plus', direction, binary, delta);
endif

endfunction