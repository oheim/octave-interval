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
## @deftypefn {Interval Comparison} {@var{Z} =} @var{A} == @var{B}
## @cindex IEEE1788 equal
## 
## Compare intervals @var{A} and @var{B} for equality.
##
## True, if all numbers from @var{A} are also contained in @var{B} and vice
## versa.  False, if @var{A} contains a number which is not a member in @var{B}
## or vice versa.
##
## @example
## @group
## x = infsupdec (2, 3);
## y = infsupdec (1, 2);
## x == y
##   @result{} False
## @end group
## @end example
## @seealso{subset, interior, disjoint}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-13

function result = eq(a, b)

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
    result = false();
else
    result = eq (intervalpart (a), intervalpart (b)) && strcmp (a.dec, b.dec);
endif

endfunction