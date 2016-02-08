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
## @deffun str2decimal (@var{S})
## 
## Parse a decimal number string @var{S} and split the sign, the mantissa and
## the exponent information.
##
## The input number format is [+-]d[,.]d[[eE][+-]d] (cf. str2double).
##
## Limitations: The decimal exponent of the input format must be a number
## between -2^53 (exclusive) and +2^53 (exclusive).
## The number itself either must equal zero or its absolute value must be
## between 10^(-2^62) (inclusive) and 10^(2^63 - 1) (exclusive).
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
## x = str2decimal ("-12.3e14")
##   @result{}
##     x.s = 1
##     x.m = [1 2 3]'
##     x.e = 16
## y = str2decimal ("0.00123e-14")
##   @result{}
##     y.s = 0
##     y.m = [1 2 3]'
##     y.e = -12
## z = str2decimal ("0")
##   @result{}
##     z.s = 0
##     z.m = []
##     z.e = 0
## @end group
## @end example
## @seealso{double2decimal}
## @end deffun

## Author: Oliver Heimlich
## Created: 2014-09-27

function decimal = str2decimal (string)

## Strip Sign
if (isempty (string))
    decimal.s = false;
else
    decimal.s = (string(1) == "-");
    if (strfind("+-", string(1)))
        string = string (2:end);
    endif
endif

## Split mantissa & exponent
[decimal.m, decimal.e] = strtok (string, "eE");

## Convert exponent from string to number
if (isempty (decimal.e))
    decimal.e = int64(0); # 10 ^ 0 = 1
else
    if (strfind (decimal.e, ".") || strfind (decimal.e, ","))
        error ("interval:InvalidOperand", ...
               ["invalid decimal number with rational exponent: " string]);
    endif
    decimal.e = str2double (decimal.e(2:end)); # remove “e” and convert
    if (isnan (decimal.e) || ... # greater than realmax or illegal format
        abs(decimal.e) >= pow2 (53)) # possibly lost precision
        error ("interval:InvalidOperand", ...
               ["invalid decimal number with big/invalid exponent: " string]);
    endif
    decimal.e = int64 (decimal.e);
endif

## Normalize mantissa: remove leading zeroes within string representation
## before decimal point. This does not affect the exponent and is therefore
## preferred over the normalization below, which might produce overflow errors.
decimal.m = decimal.m(find(decimal.m ~= "0", 1):end);

## Split Mantissa at decimal point
decimal.m = strsplit (decimal.m, {".",","});
switch length(decimal.m)
    case 0
        decimal.m = {"", ""};
    case 1
        decimal.m{2} = "";
    case 2
        # nothing to do
    otherwise
        error ("interval:InvalidOperand", ...
               ["invalid decimal number with multiple decimal points: " ...
                string]);
endswitch

## Normalize mantissa string: move decimal point to the left
if (decimal.e + length (decimal.m{1}) >= intmax (class (decimal.e)))
    error ("interval:InvalidOperand", ...
           ["exponent overflow during normalization: " string ]);
endif
decimal.e += length (decimal.m{1});
decimal.m = strcat (decimal.m{1}, decimal.m{2});

## Convert mantissa to numeric vector with decimal digits
decimal.m = str2num (decimal.m');

## Normalize mantissa: remove leading zeroes
firstnonzerodigit = find (decimal.m ~= 0, 1, "first");
if (firstnonzerodigit > 1)
    decimal.m = decimal.m(firstnonzerodigit:end);
    if (decimal.e - (firstnonzerodigit - 1) <= intmin (class (decimal.e)))
        error ("interval:InvalidOperand", ...
               ["exponent overflow during normalization: " string ]);
    endif
    decimal.e -= firstnonzerodigit - 1;
elseif (isempty (firstnonzerodigit)) # all digits are zero
    decimal.s = false;
    decimal.m = [];
    decimal.e = int64 (0);
    return
endif

## Normalize mantissa: remove trailing zeroes;
lastnonzerodigit = find (decimal.m ~= 0, 1, "last");
if (lastnonzerodigit < length (decimal.m))
    decimal.m = decimal.m(1:lastnonzerodigit);
endif

endfunction