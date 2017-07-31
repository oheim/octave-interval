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
## @defmethod {@@infsup} roundb (@var{X})
##
## Round each number in interval @var{X} to the nearest integer.  Ties are
## rounded towards the nearest even integer.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## roundb (infsup (2.5, 3.5))
##   @result{} ans = [2, 4]
## roundb (infsup (-0.5, 5.5))
##   @result{} ans = [0, 6]
## @end group
## @end example
## @seealso{@@infsup/floor, @@infsup/ceil, @@infsup/round, @@infsup/fix}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-04

function x = roundb (x)

  if (nargin ~= 1)
    print_usage ();
    return
  endif

  x.inf = roundb (x.inf);
  x.sup = roundb (x.sup);

  x.inf(x.inf == 0) = -0;
  x.sup(x.sup == 0) = +0;

endfunction

%!# Empty interval
%!assert (roundb (infsup ()) == infsup ());

%!# Singleton intervals
%!assert (roundb (infsup (0)) == infsup (0));
%!assert (roundb (infsup (0.5)) == infsup (0));
%!assert (roundb (infsup (0.25)) == infsup (0));
%!assert (roundb (infsup (0.75)) == infsup (1));
%!assert (roundb (infsup (1.5)) == infsup (2));
%!assert (roundb (infsup (-0.5)) == infsup (0));
%!assert (roundb (infsup (-1.5)) == infsup (-2));

%!# Bounded intervals
%!assert (roundb (infsup (-0.5, 0)) == infsup (0));
%!assert (roundb (infsup (0, 0.5)) == infsup (0));
%!assert (roundb (infsup (0.25, 0.5)) == infsup (0));
%!assert (roundb (infsup (-1, 0)) == infsup (-1, 0));
%!assert (roundb (infsup (-1, 1)) == infsup (-1, 1));
%!assert (roundb (infsup (-realmin, realmin)) == infsup (0));
%!assert (roundb (infsup (-realmax, realmax)) == infsup (-realmax, realmax));

%!# Unbounded intervals
%!assert (roundb (infsup (-realmin, inf)) == infsup (0, inf));
%!assert (roundb (infsup (-realmax, inf)) == infsup (-realmax, inf));
%!assert (roundb (infsup (-inf, realmin)) == infsup (-inf, 0));
%!assert (roundb (infsup (-inf, realmax)) == infsup (-inf, realmax));
%!assert (roundb (infsup (-inf, inf)) == infsup (-inf, inf));

%!# correct use of signed zeros
%!test
%! x = roundb (infsup (0));
%! assert (signbit (inf (x)));
%! assert (not (signbit (sup (x))));
%!test
%! x = roundb (infsup (-0.25, 0.25));
%! assert (signbit (inf (x)));
%! assert (not (signbit (sup (x))));

%!shared testdata
%! # Load compiled test data (from src/test/*.itl)
%! testdata = load (file_in_loadpath ("test/itl.mat"));

%!test
%! # Scalar evaluation
%! testcases = testdata.NoSignal.infsup.roundTiesToEven;
%! for testcase = [testcases]'
%!   assert (isequaln (...
%!     roundb (testcase.in{1}), ...
%!     testcase.out));
%! endfor

%!test
%! # Vector evaluation
%! testcases = testdata.NoSignal.infsup.roundTiesToEven;
%! in1 = vertcat (vertcat (testcases.in){:, 1});
%! out = vertcat (testcases.out);
%! assert (isequaln (roundb (in1), out));

%!test
%! # N-dimensional array evaluation
%! testcases = testdata.NoSignal.infsup.roundTiesToEven;
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
%! assert (isequaln (roundb (in1), out));
