## Copyright 2014-2015 Oliver Heimlich
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
## @deftypefn {Function File} {@var{Z} =} cancelminus (@var{X}, @var{Y})
## 
## Recover interval @var{Z} from intervals @var{X} and @var{Y}, given that one
## knows @var{X} was obtained as the sum @var{Y} + @var{Z}.
##
## Accuracy: The result is a tight enclosure.
##
## @seealso{@@infsup/cancelplus}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-19

function result = cancelminus (x, y)

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

l = mpfr_function_d ('minus', -inf, x.inf, y.inf);
u = mpfr_function_d ('minus', +inf, x.sup, y.sup);

wid_x1 = wid (x & infsup (-inf, 0));
wid_x2 = wid (x & infsup (0, inf));
wid_y1 = wid (y & infsup (-inf, 0));
wid_y2 = wid (y & infsup (0, inf));
[wid_x1, wid_x2] = deal (max (wid_x1, wid_x2), min (wid_x1, wid_x2));
[wid_y1, wid_y2] = deal (max (wid_y1, wid_y2), min (wid_y1, wid_y2));

entireresult = (isempty (y) & not (isempty (x))) | ...
               y.inf == -inf | y.sup == inf | ...
               x.inf == -inf | x.sup == inf | ...
               ## We have to check for wid (x) < wid (y), which is difficult
               ## for wid > realmax, because of overflow and
               ## for interior zero, because of rounding errors.
               (iscommoninterval (x) & iscommoninterval (y) & ...
                (wid_x1 - wid_y1) + (wid_x2 - wid_y2) < 0);
l (entireresult) = -inf;
u (entireresult) = inf;

emptyresult = isempty (x) & not (entireresult);
l (emptyresult) = inf;
u (emptyresult) = -inf;

result = infsup (l, u);

endfunction
