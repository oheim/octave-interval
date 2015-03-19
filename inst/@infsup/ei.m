## Copyright 2015 Oliver Heimlich
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
## @documentencoding utf-8
## @deftypefn {Function File} {} ei (@var{X})
## 
## Compute the exponential integral for positive arguments.
##
## @tex
## $$
##  {\rm ei} (x) = \int_{-\infty}^x {{\exp t} \over t} dt
## $$
## @end tex
## @ifnottex
## @example
## @group
##           x
##          /  exp (t)
## ei (x) = | --------- dt
##          /     t
##        -∞
## @end group
## @end example
## @end ifnottex
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## ei (infsup (1))
##   @result{} [1.8951178163559365, 1.8951178163559368]
## @end group
## @end example
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2015-02-29

function result = ei (x)

if (nargin ~= 1)
    print_usage ();
    return
endif

l = inf (size (x.inf));
u = -l;

## ei is monotonically increasing and defined for x > 0
defined = x.sup > 0;
l (defined) = mpfr_function_d ('ei', -inf, max (0, x.inf (defined)));
u (defined) = mpfr_function_d ('ei', +inf, x.sup (defined));

result = infsup (l, u);

endfunction

%!assert (isempty (ei (infsup (0))));
%!assert (isempty (ei (infsup (-inf, -2))));
%!assert (isentire (ei (infsup (0, inf))));

%!test "from the documentation string";
%! assert (ei (infsup (1)) == "[0x1.E52670F350D08, 0x1.E52670F350D09]");