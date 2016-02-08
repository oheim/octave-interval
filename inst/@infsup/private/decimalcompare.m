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
## @deffun decimalcompare (@var{X}, @var{Y})
## 
## Compare two decimal floating point numbers.
##
## The result is a negative number, if @code{@var{X} < @var{Y}};
## zero, if @code{@var{X} == @var{Y}}; a positive number,
## if @code{@var{X} > @var{Y}}.
##
## @seealso{str2decimal, double2decimal}
## @end deffun

## Author: Oliver Heimlich
## Created: 2014-09-29

function result = decimalcompare (x, y)

## Comparison with zero
if (isempty (x.m) ~= isempty (y.m))
    if (y.s || ... # Y < 0
        not (x.s || isempty (x.m))) # X > 0
        result = 1;
    else
        result = -1;
    endif
    return
endif

## Different signs
if (x.s ~= y.s)
    result = y.s - x.s;
    return
endif

## Different exponents
if (x.e ~= y.e)
    result = x.e - y.e;
    if (x.s)
        result .*= -1;
    endif
    return
endif

## Compare common mantissa places
for i = 1 : min (length (x.m), length (y.m))
    if (x.m(i) ~= y.m(i))
        result = x.m(i) - y.m(i);
        if (x.s)
            result .*= -1;
        endif
        return
    endif
endfor

## Compare mantissa length. There is no need to inspect the digits, because the
## mantissa is normalized (no trailing zeroes).
result = length (x.m) - length (y.m);
if (x.s)
    result .*= -1;
endif

endfunction