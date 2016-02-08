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
## @deftypefun {[@var{QUOTIENT}, @var{REMAINDER}] =} decimaldivide (@var{DIVIDEND}, @var{DIVISOR}, @var{PRECISION})
## 
## Divide two decimal numbers.  The parameter @var{PRECISION} limits the
## maximum significand places in the @var{QUOTIENT}.
##
## @end deftypefun

## Author: Oliver Heimlich
## Created: 2014-10-22

function [quotient, remainder] = decimaldivide (dividend, divisor, precision)

assert (not (isempty (divisor.m)), "division by zero");

if (isempty (dividend.m)) # 0 / divisor
    quotient = dividend;
    remainder = dividend;
    return
endif

## Compute exponent and sign of the result
quotient.e = dividend.e - divisor.e + 1;
divisor.e = dividend.e;
quotient.s = xor (dividend.s, divisor.s);
divisor.s = dividend.s;
quotient.m = zeros (precision, 1);

## Perform long division
remainder = dividend;
i = 1;
while (i <= length (quotient.m))
    if (isempty (remainder.m))
        break
    endif
    
    while (sign (decimalcompare (divisor, remainder)) ~= (-1) ^ remainder.s)
        quotient.m (i) ++;
        
        ## Subtract divisor from remainder
        divisor.s = not (remainder.s);
        remainder = decimaladd (remainder, divisor);
        divisor.s = remainder.s;
    endwhile
    divisor.e --;
    if (i == 1 && quotient.m (i) == 0)
        quotient.e --;
    else
        i++;
    endif
endwhile

## Remove trailing zeros
quotient.m = quotient.m(1 : find (quotient.m ~= 0, 1, "last"));

endfunction