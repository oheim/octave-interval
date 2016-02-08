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
## @deftypefun {@var{DECIMAL} =} decimaladd (@var{DECIMAL}, @var{ADDEND})
## 
## Add two decimal numbers.
##
## @end deftypefun

## Author: Oliver Heimlich
## Created: 2014-10-21

function [decimal] = decimaladd (decimal, addend)

## Align mantissas
if (addend.e < decimal.e)
    addend.m = [zeros(decimal.e - addend.e, 1); ...
                   addend.m];
    addend.e = decimal.e;
elseif (addend.e > decimal.e)
    decimal.m = [zeros(addend.e - decimal.e, 1); ...
                 decimal.m];
    decimal.e = addend.e;
endif
if (length (decimal.m) > length (addend.m))
    addend.m = [addend.m; ...
        zeros(length (decimal.m) - ...
              length (addend.m), 1)];
elseif (length (decimal.m) < length (addend.m))
    decimal.m = [decimal.m; ...
        zeros(length (addend.m) - ...
              length (decimal.m), 1)];
endif

assert (length (decimal.m) == length (addend.m));
assert (decimal.e == addend.e);

## Add
if (decimal.s == addend.s)
    decimal.m += addend.m;
else
    decimal.m -= addend.m;
endif

## Carry
while (not (isempty (find (decimal.m >= 10))))
    decimal.m = [0; rem(decimal.m, 10)] ...
              + [(decimal.m >= 10); 0];
    if (decimal.m(1) == 0)
        decimal.m(1) = [];
    else
        decimal.e ++;
    endif
endwhile

## Resolve negative decimal digits
while (1)
    highestnegative = find (decimal.m < 0, 1);
    if (isempty (highestnegative))
        break;
    endif
    highestpositive = find (decimal.m > 0, 1);
    
    if (isempty (highestpositive) || ...
        highestnegative < highestpositive)
        ## Flip sign
        decimal.s = not (decimal.s);
        decimal.m *= -1;
    else
        assert (decimal.m(1) >= 0);
        decimal.m += 10 * (decimal.m < 0) ...
                   - [(decimal.m(2:end) < 0); 0];
    endif
endwhile
clear highestnegative highestpositive;

## Normalize mantissa: remove leading zeroes
firstnonzerodigit = find (decimal.m ~= 0, 1, "first");
if (firstnonzerodigit > 1)
    decimal.m = decimal.m(firstnonzerodigit:end);
    decimal.e -= firstnonzerodigit - 1;
elseif (isempty (firstnonzerodigit)) # all digits are zero
    decimal.s = false;
    decimal.m = [];
    decimal.e = int64 (0);
    return
endif

## Remove trailing zeros
decimal.m = decimal.m(1 : find (decimal.m ~= 0, 1, "last"));

endfunction