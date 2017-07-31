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
## @deftypemethod {@@infsup} {@var{Z} =} cancelminus (@var{X}, @var{Y})
##
## Recover interval @var{Z} from intervals @var{X} and @var{Y}, given that one
## knows @var{X} was obtained as the sum @var{Y} + @var{Z}.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## cancelminus (infsup (2, 3), infsup (1, 1.5))
##   @result{} ans = [1, 1.5]
## @end group
## @end example
## @seealso{@@infsup/cancelplus}
## @end deftypemethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-19

function x = cancelminus (x, y)

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

  wid_x1 = wid (intersect (x, infsup (-inf, 0)));
  wid_x2 = wid (intersect (x, infsup (0, inf)));
  wid_y1 = wid (intersect (y, infsup (-inf, 0)));
  wid_y2 = wid (intersect (y, infsup (0, inf)));
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
  l(entireresult) = -inf;
  u(entireresult) = inf;

  emptyresult = isempty (x) & not (entireresult);
  l(emptyresult) = inf;
  u(emptyresult) = -inf;

  l(l == 0) = -0;

  x.inf = l;
  x.sup = u;

endfunction

%!# from the documentation string
%!assert (cancelminus (infsup (2, 3), infsup (1, 1.5)) == infsup (1, 1.5));

%!shared testdata
%! # Load compiled test data (from src/test/*.itl)
%! testdata = load (file_in_loadpath ("test/itl.mat"));

%!test
%! # Scalar evaluation
%! testcases = testdata.NoSignal.infsup.cancelMinus;
%! for testcase = [testcases]'
%!   assert (isequaln (...
%!     cancelminus (testcase.in{1}, testcase.in{2}), ...
%!     testcase.out));
%! endfor

%!test
%! # Vector evaluation
%! testcases = testdata.NoSignal.infsup.cancelMinus;
%! in1 = vertcat (vertcat (testcases.in){:, 1});
%! in2 = vertcat (vertcat (testcases.in){:, 2});
%! out = vertcat (testcases.out);
%! assert (isequaln (cancelminus (in1, in2), out));

%!test
%! # N-dimensional array evaluation
%! testcases = testdata.NoSignal.infsup.cancelMinus;
%! in1 = vertcat (vertcat (testcases.in){:, 1});
%! in2 = vertcat (vertcat (testcases.in){:, 2});
%! out = vertcat (testcases.out);
%! # Reshape data
%! i = -1;
%! do
%!   i = i + 1;
%!   testsize = factor (numel (in1) + i);
%! until (numel (testsize) > 2)
%! in1 = reshape ([in1; in1(1:i)], testsize);
%! in2 = reshape ([in2; in2(1:i)], testsize);
%! out = reshape ([out; out(1:i)], testsize);
%! assert (isequaln (cancelminus (in1, in2), out));
