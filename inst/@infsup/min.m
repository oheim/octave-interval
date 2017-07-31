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
## @defmethod {@@infsup} min (@var{X})
## @defmethodx {@@infsup} min (@var{X}, @var{Y})
## @defmethodx {@@infsup} min (@var{X}, [], @var{DIM})
##
## Compute the minimum value chosen from intervals.
##
## This function does not return the least element of the interval (see
## @code{inf}), but returns an interval enclosure of the function:
## @display
## min (@var{x}, @var{y}) = ( (x + y) - abs (x - y) ) / 2
## @end display
##
## With two arguments the function is applied element-wise.  Otherwise the
## minimum is computed for all interval members along dimension @var{DIM},
## which defaults to the first non-singleton dimension.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## x = infsup (2, 3);
## y = infsup (1, 2);
## min (x, y)
##   @result{} ans = [1, 2]
## @end group
## @end example
## @seealso{@@infsup/max}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-04

function x = min (x, y, dim)

  if (not (isa (x, "infsup")))
    x = infsup (x);
  endif

  switch (nargin)
    case 1
      l = min (x.inf);
      u = min (x.sup);
      l(any (isempty (x))) = inf;
    case 2
      if (not (isa (y, "infsup")))
        y = infsup (y);
      endif
      l = min (x.inf, y.inf);
      u = min (x.sup, y.sup);
      l(isempty (x) | isempty (y)) = inf;
    case 3
      if (not (builtin ("isempty", y)))
        warning ("min: second argument is ignored");
      endif
      l = min (x.inf, [], dim);
      u = min (x.sup, [], dim);
      l(any (isempty (x), dim)) = inf;
    otherwise
      print_usage ();
      return
  endswitch

  x.inf = l;
  x.sup = u;

endfunction

%!# from the documentation string
%!assert (min (infsup (2, 3), infsup (1, 2)) == infsup (1, 2));

%!shared testdata
%! # Load compiled test data (from src/test/*.itl)
%! testdata = load (file_in_loadpath ("test/itl.mat"));

%!test
%! # Scalar evaluation
%! testcases = testdata.NoSignal.infsup.min;
%! for testcase = [testcases]'
%!   assert (isequaln (...
%!     min (testcase.in{1}, testcase.in{2}), ...
%!     testcase.out));
%! endfor

%!test
%! # Vector evaluation
%! testcases = testdata.NoSignal.infsup.min;
%! in1 = vertcat (vertcat (testcases.in){:, 1});
%! in2 = vertcat (vertcat (testcases.in){:, 2});
%! out = vertcat (testcases.out);
%! assert (isequaln (min (in1, in2), out));

%!test
%! # N-dimensional array evaluation
%! testcases = testdata.NoSignal.infsup.min;
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
%! assert (isequaln (min (in1, in2), out));
