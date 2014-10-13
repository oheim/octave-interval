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
## @deftypefn {Interval Comparison} {@var{Z} =} @var{A} < @var{B}
## @cindex IEEE1788 strictLess
## 
## Compare intervals @var{A} and @var{B} for strictly less.
##
## True, if all numbers from @var{A} are strict less than at least one number
## in @var{B}.  False, if @var{A} contains a number which is greater than all
## numbers in @var{B} or is equal to the greatest number of @var{B}.
##
## @seealso{eq, le, gt, subset, interior, disjoint}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-13

function result = lt (a, b)

assert (nargin == 2);

## Convert first parameter into interval, if necessary
if (not (isa (a, "infsupdec")))
    a = infsupdec (a);
endif

## Convert second parameter into interval, if necessary
if (not (isa (b, "infsupdec")))
    b = infsupdec (b);
endif

if (isnai (a) || isnai (b))
    error ("interval comparison with NaI")
endif

result = lt (intervalpart (a), intervalpart (b));

endfunction