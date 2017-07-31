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
## @defmethod {@@infsup} fix (@var{X})
##
## Truncate fractional portion of each number in interval @var{X}.  This is
## equivalent to rounding towards zero.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## fix (infsup (2.5, 3.5))
##   @result{} ans = [2, 3]
## fix (infsup (-0.5, 5))
##   @result{} ans = [0, 5]
## @end group
## @end example
## @seealso{@@infsup/floor, @@infsup/ceil, @@infsup/round, @@infsup/roundb}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-04

function x = fix (x)

  if (nargin ~= 1)
    print_usage ();
    return
  endif

  x.inf = fix (x.inf);
  x.sup = fix (x.sup);

  x.inf(x.inf == 0) = -0;
  x.sup(x.sup == 0) = +0;

endfunction

%!# Empty interval
%!assert (fix (infsup ()) == infsup ());

%!# Singleton intervals
%!assert (fix (infsup (0)) == infsup (0));
%!assert (fix (infsup (1)) == infsup (1));
%!assert (fix (infsup (1+eps)) == infsup (1));
%!assert (fix (infsup (-1)) == infsup (-1));
%!assert (fix (infsup (0.5)) == infsup (0));
%!assert (fix (infsup (-0.5)) == infsup (0));

%!# Bounded intervals
%!assert (fix (infsup (-0.5, 0)) == infsup (0));
%!assert (fix (infsup (0, 0.5)) == infsup (0));
%!assert (fix (infsup (0.25, 0.5)) == infsup (0));
%!assert (fix (infsup (-1, 0)) == infsup (-1, 0));
%!assert (fix (infsup (-1, 1)) == infsup (-1, 1));
%!assert (fix (infsup (-realmin, realmin)) == infsup (0));
%!assert (fix (infsup (-realmax, realmax)) == infsup (-realmax, realmax));

%!# Unbounded intervals
%!assert (fix (infsup (-realmin, inf)) == infsup (0, inf));
%!assert (fix (infsup (-realmax, inf)) == infsup (-realmax, inf));
%!assert (fix (infsup (-inf, realmin)) == infsup (-inf, 0));
%!assert (fix (infsup (-inf, realmax)) == infsup (-inf, realmax));
%!assert (fix (infsup (-inf, inf)) == infsup (-inf, inf));

%!# from the documentation string
%!assert (fix (infsup (2.5, 3.5)) == infsup (2, 3));
%!assert (fix (infsup (-0.5, 5)) == infsup (0, 5));

%!# correct use of signed zeros
%!test
%! x = fix (infsup (0.5));
%! assert (signbit (inf (x)));
%! assert (not (signbit (sup (x))));
%!test
%! x = fix (infsup (-0.5));
%! assert (signbit (inf (x)));
%! assert (not (signbit (sup (x))));
%!test
%! x = fix (infsup (0));
%! assert (signbit (inf (x)));
%! assert (not (signbit (sup (x))));

%!shared testdata
%! # Load compiled test data (from src/test/*.itl)
%! testdata = load (file_in_loadpath ("test/itl.mat"));

%!test
%! # Scalar evaluation
%! testcases = testdata.NoSignal.infsup.trunc;
%! for testcase = [testcases]'
%!   assert (isequaln (...
%!     fix (testcase.in{1}), ...
%!     testcase.out));
%! endfor

%!test
%! # Vector evaluation
%! testcases = testdata.NoSignal.infsup.trunc;
%! in1 = vertcat (vertcat (testcases.in){:, 1});
%! out = vertcat (testcases.out);
%! assert (isequaln (fix (in1), out));

%!test
%! # N-dimensional array evaluation
%! testcases = testdata.NoSignal.infsup.trunc;
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
%! assert (isequaln (fix (in1), out));
