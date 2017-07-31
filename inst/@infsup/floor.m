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
## @defmethod {@@infsup} floor (@var{X})
##
## Round each number in interval @var{X} towards -Inf.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## floor (infsup (2.5, 3.5))
##   @result{} ans = [2, 3]
## floor (infsup (-0.5, 5))
##   @result{} ans = [-1, +5]
## @end group
## @end example
## @seealso{@@infsup/ceil, @@infsup/round, @@infsup/roundb, @@infsup/fix}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-04

function x = floor (x)

  if (nargin ~= 1)
    print_usage ();
    return
  endif

  x.inf = floor (x.inf);
  x.sup = floor (x.sup);

  x.inf(x.inf == 0) = -0;

endfunction

%!# Empty interval
%!assert (floor (infsup ()) == infsup ());

%!# Singleton intervals
%!assert (floor (infsup (0)) == infsup (0));
%!assert (floor (infsup (0.5)) == infsup (0));
%!assert (floor (infsup (-0.5)) == infsup (-1));

%!# Bounded intervals
%!assert (floor (infsup (-0.5, 0)) == infsup (-1, 0));
%!assert (floor (infsup (0, 0.5)) == infsup (0));
%!assert (floor (infsup (0.25, 0.5)) == infsup (0));
%!assert (floor (infsup (-1, 0)) == infsup (-1, 0));
%!assert (floor (infsup (-1, 1)) == infsup (-1, 1));
%!assert (floor (infsup (-realmin, realmin)) == infsup (-1, 0));
%!assert (floor (infsup (-realmax, realmax)) == infsup (-realmax, realmax));

%!# Unbounded intervals
%!assert (floor (infsup (-realmin, inf)) == infsup (-1, inf));
%!assert (floor (infsup (-realmax, inf)) == infsup (-realmax, inf));
%!assert (floor (infsup (-inf, realmin)) == infsup (-inf, 0));
%!assert (floor (infsup (-inf, realmax)) == infsup (-inf, realmax));
%!assert (floor (infsup (-inf, inf)) == infsup (-inf, inf));

%!# from the documentation string
%!assert (floor (infsup (2.5, 3.5)) == infsup (2, 3));
%!assert (floor (infsup (-0.5, 5)) == infsup (-1, 5));

%!# correct use of signed zeros
%!test
%! x = floor (infsup (0.5));
%! assert (signbit (inf (x)));
%! assert (not (signbit (sup (x))));
%!test
%! x = floor (infsup (0));
%! assert (signbit (inf (x)));
%! assert (not (signbit (sup (x))));

%!shared testdata
%! # Load compiled test data (from src/test/*.itl)
%! testdata = load (file_in_loadpath ("test/itl.mat"));

%!test
%! # Scalar evaluation
%! testcases = testdata.NoSignal.infsup.floor;
%! for testcase = [testcases]'
%!   assert (isequaln (...
%!     floor (testcase.in{1}), ...
%!     testcase.out));
%! endfor

%!test
%! # Vector evaluation
%! testcases = testdata.NoSignal.infsup.floor;
%! in1 = vertcat (vertcat (testcases.in){:, 1});
%! out = vertcat (testcases.out);
%! assert (isequaln (floor (in1), out));

%!test
%! # N-dimensional array evaluation
%! testcases = testdata.NoSignal.infsup.floor;
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
%! assert (isequaln (floor (in1), out));
