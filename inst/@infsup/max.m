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
## @defmethod {@@infsup} max (@var{X})
## @defmethodx {@@infsup} max (@var{X}, @var{Y})
## @defmethodx {@@infsup} max (@var{X}, [], @var{DIM})
##
## Compute the maximum value chosen from intervals.
##
## This function does not return the greatest element of the interval (see
## @code{sup}), but returns an interval enclosure of the function:
## @display
## max (@var{x}, @var{y}) = ( (x + y) + abs (x - y) ) / 2
## @end display
##
## With two arguments the function is applied element-wise.  Otherwise the
## maximum is computed for all interval members along dimension @var{DIM},
## which defaults to the first non-singleton dimension.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## x = infsup (2, 3);
## y = infsup (1, 2);
## max (x, y)
##   @result{} ans = [2, 3]
## @end group
## @end example
## @seealso{@@infsup/min}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-04

function x = max (x, y, dim)

  if (not (isa (x, "infsup")))
    x = infsup (x);
  endif

  switch (nargin)
    case 1
      l = max (x.inf);
      u = max (x.sup);
      u(any (isempty (x))) = -inf;
    case 2
      if (not (isa (y, "infsup")))
        y = infsup (y);
      endif
      l = max (x.inf, y.inf);
      u = max (x.sup, y.sup);
      u(isempty (x) | isempty (y)) = -inf;
    case 3
      if (not (builtin ("isempty", y)))
        warning ("max: second argument is ignored");
      endif
      l = max (x.inf, [], dim);
      u = max (x.sup, [], dim);
      u(any (isempty (x), dim)) = -inf;
    otherwise
      print_usage ();
      return
  endswitch

  x.inf = l;
  x.sup = u;

endfunction

%!# from the documentation string
%!assert (max (infsup (2, 3), infsup (1, 2)) == infsup (2, 3));

%!shared testdata
%! # Load compiled test data (from src/test/*.itl)
%! testdata = load (file_in_loadpath ("test/itl.mat"));

%!test
%! # Scalar evaluation
%! testcases = testdata.NoSignal.infsup.max;
%! for testcase = [testcases]'
%!   assert (isequaln (...
%!     max (testcase.in{1}, testcase.in{2}), ...
%!     testcase.out));
%! endfor

%!test
%! # Vector evaluation
%! testcases = testdata.NoSignal.infsup.max;
%! in1 = vertcat (vertcat (testcases.in){:, 1});
%! in2 = vertcat (vertcat (testcases.in){:, 2});
%! out = vertcat (testcases.out);
%! assert (isequaln (max (in1, in2), out));

%!test
%! # N-dimensional array evaluation
%! testcases = testdata.NoSignal.infsup.max;
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
%! assert (isequaln (max (in1, in2), out));
