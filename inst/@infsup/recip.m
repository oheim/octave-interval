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
## @documentencoding UTF-8
## @deftypefn {Function File} {} recip (@var{X})
## 
## Compute the reciprocal of @var{X}.
##
## The result is equivalent to @code{1 ./ @var{X}}, but is computed more
## efficiently.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## recip (infsup (1, 4))
##   @result{} ans = [0.25, 1]
## @end group
## @end example
## @seealso{@@infsup/inv, @@infsup/rdivide}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2015-11-07

function result = recip (x)

if (nargin ~= 1)
    print_usage ();
    return
endif

l = inf (size (x.inf));
u = -l;

## Fix signs to make use of limit values for 1 ./ x.
x.inf(x.inf == 0) = +0;
x.sup(x.sup == 0) = -0;

select = (x.inf >= 0 | x.sup <= 0) & ...
         # undefined for x = [0, 0]
         not (x.inf == 0 & x.sup == 0) & ...
         # x is not empty
         x.inf < inf;
if (any (any (select)))
    ## recip is monotonically decreasing
    l(select) = mpfr_function_d ('rdivide', -inf, 1, x.sup(select));
    u(select) = mpfr_function_d ('rdivide', +inf, 1, x.inf(select));
endif

## singularity at x = 0
select = x.inf < 0 & x.sup > 0;
if (any (any (select)))
    l(select) = -inf;
    u(select) = +inf;
endif

result = infsup (l, u);

endfunction

%!test "from the documentation string";
%!  assert (recip (infsup (1, 4)) == infsup (0.25, 1));
