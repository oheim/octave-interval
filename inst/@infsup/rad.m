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
## @deftypemethod {@@infsup} {@var{R} =} rad (@var{X})
## @deftypemethodx {@@infsup} {[@var{M}, @var{R}] =} rad (@var{X})
## 
## Get the radius (and midpoint) of interval @var{X}.
##
## If @var{X} is empty, @code{rad (@var{X})} is NaN.
## If @var{X} is unbounded in one or both directions, @code{rad (@var{X})} is 
## positive infinity.
##
## With two output parameters the midpoint and radius are computed.
##
## Accuracy: The radius @var{R} will make a tight enclosure of the interval
## together with midpoint @var{M}.
##
## @example
## @group
## rad (infsup (2.5, 3.5))
##   @result{} ans = 0.50000
## @end group
## @end example
## @seealso{@@infsup/inf, @@infsup/sup, @@infsup/mid, @@infsup/wid}
## @end deftypemethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-05

function [out1, out2] = rad (x)

if (nargin ~= 1)
    print_usage ();
    return
endif

m = mid (x);
## The midpoint is rounded to nearest and the radius must cover both boundaries
r1 = mpfr_function_d ('minus', +inf, m, x.inf);
r2 = mpfr_function_d ('minus', +inf, x.sup, m);
r = max (r1, r2);

r (isempty (x)) = nan ();

if (nargout >= 2)
    out1 = m;
    out2 = r;
else
    out1 = r;
endif

endfunction

%!test;
%! [m, r] = rad (infsup (2.5, 3.5));
%! assert (m, 3);
%! assert (r, .5);
%!test "from the documentation string";
%! assert (rad (infsup (2.5, 3.5)), .5);
