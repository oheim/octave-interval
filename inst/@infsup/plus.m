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
## @deftypefn {Interval Function} {} @var{X} + @var{Y}
## @cindex IEEE1788 add
## 
## Add all numbers of interval @var{X} to all numbers of @var{Y}.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## x = infsup (2, 3);
## y = infsup (1, 2);
## x + y
##   @result{} [3, 5]
## @end group
## @end example
## @seealso{minus}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-09-30

function result = plus (x, y)

if (nargin ~= 2)
    print_usage ();
    return
endif
if (not (isa (x, "infsup")))
    x = infsup (x);
endif
if (not (isa (y, "infsup")))
    y = infsup (y);
endif

fesetround (-inf);
l = x.inf + y.inf;
fesetround (inf);
u = x.sup + y.sup;
fesetround (0.5);

## Sum of empty intervals must be empty
emptyresult = isempty (x) | isempty (y);
l (emptyresult) = inf;
u (emptyresult) = -inf;

result = infsup (l, u);

endfunction