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
## @defmethod {@@infsup} abs (@var{X})
##
## Compute the absolute value of numbers.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## abs (infsup (2.5, 3.5))
##   @result{} ans = [2.5, 3.5]
## abs (infsup (-0.5, 5.5))
##   @result{} ans = [0, 5.5]
## @end group
## @end example
## @seealso{@@infsup/mag, @@infsup/mig}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-04

function x = abs (x)

  if (nargin ~= 1)
    print_usage ();
    return
  endif

  ## This is already correct, if the interval(s) are non-negative.
  l = x.inf;
  u = x.sup;

  ## This is even correct, if the interval(s) are empty.
  notpositive = (x.sup <= 0);
  l(notpositive) = -x.sup(notpositive);
  u(notpositive) = -x.inf(notpositive);

  zerointerior = (x.inf < 0 & not (notpositive));
  l(zerointerior) = -0;
  u(zerointerior) = max (-x.inf(zerointerior), x.sup(zerointerior));

  x.inf = l;
  x.sup = u;

endfunction

%!# Empty interval
%!assert (abs (infsup ()) == infsup ());

%!# Singleton intervals
%!assert (abs (infsup (1)) == infsup (1));
%!assert (abs (infsup (0)) == infsup (0));
%!assert (abs (infsup (-1)) == infsup (1));
%!assert (abs (infsup (realmax)) == infsup (realmax));
%!assert (abs (infsup (realmin)) == infsup (realmin));
%!assert (abs (infsup (-realmin)) == infsup (realmin));
%!assert (abs (infsup (-realmax)) == infsup (realmax));

%!# Bounded intervals
%!assert (abs (infsup (1, 2)) == infsup (1, 2));
%!assert (abs (infsup (0, 1)) == infsup (0, 1));
%!assert (abs (infsup (-1, 1)) == infsup (0, 1));
%!assert (abs (infsup (-1, 0)) == infsup (0, 1));
%!assert (abs (infsup (-2, -1)) == infsup (1, 2));

%!# Unbounded intervals
%!assert (abs (infsup (0, inf)) == infsup (0, inf));
%!assert (abs (infsup (-inf, inf)) == infsup (0, inf));
%!assert (abs (infsup (-inf, 0)) == infsup (0, inf));
%!assert (abs (infsup (1, inf)) == infsup (1, inf));
%!assert (abs (infsup (-1, inf)) == infsup (0, inf));
%!assert (abs (infsup (-inf, -1)) == infsup (1, inf));
%!assert (abs (infsup (-inf, 1)) == infsup (0, inf));

%!# from the documentation string
%!assert (abs (infsup (2.5, 3.5)) == infsup (2.5, 3.5));
%!assert (abs (infsup (-0.5, 5.5)) == infsup (0, 5.5));

%!# correct use of signed zeros
%!assert (signbit (inf (abs (infsup (-1, 0)))));
%!test
%! x = abs (infsup (0));
%! assert (signbit (inf (x)));
%! assert (not (signbit (sup (x))));

%!shared testdata
%! # Load compiled test data (from src/test/*.itl)
%! testdata = load (file_in_loadpath ("test/itl.mat"));

%!test
%! # Scalar evaluation
%! testcases = testdata.NoSignal.infsup.abs;
%! for testcase = [testcases]'
%!   assert (isequaln (...
%!     abs (testcase.in{1}), ...
%!     testcase.out));
%! endfor

%!test
%! # Vector evaluation
%! testcases = testdata.NoSignal.infsup.abs;
%! in1 = vertcat (vertcat (testcases.in){:, 1});
%! out = vertcat (testcases.out);
%! assert (isequaln (abs (in1), out));

%!test
%! # N-dimensional array evaluation
%! testcases = testdata.NoSignal.infsup.abs;
%! in1 = vertcat (vertcat (testcases.in){:, 1});
%! out = vertcat (testcases.out);
%! # Reshape data
%! i = -1;
%! do
%!   i = i + 1;
%!   testsize = factor (numel (in1) + i);
%! until (numel (testsize) > 2)
%! in1 = reshape ([in1; in1(1:i)], testsize);
%! out = reshape ([out; out(1:i)], testsize);
%! assert (isequaln (abs (in1), out));
