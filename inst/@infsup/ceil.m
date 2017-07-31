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
## @defmethod {@@infsup} ceil (@var{X})
##
## Round each number in interval @var{X} towards +Inf.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## ceil (infsup (2.5, 3.5))
##   @result{} ans = [3, 4]
## ceil (infsup (-0.5, 5))
##   @result{} ans = [0, 5]
## @end group
## @end example
## @seealso{@@infsup/floor, @@infsup/round, @@infsup/roundb, @@infsup/fix}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-04

function x = ceil (x)

  if (nargin ~= 1)
    print_usage ();
    return
  endif

  x.inf = ceil (x.inf);
  x.sup = ceil (x.sup);

  x.sup(x.sup == 0) = +0;

endfunction

%!# Empty interval
%!assert (ceil (infsup ()) == infsup ());

%!# Singleton intervals
%!assert (ceil (infsup (0)) == infsup (0));
%!assert (ceil (infsup (0.5)) == infsup (1));
%!assert (ceil (infsup (-0.5)) == infsup (0));

%!# Bounded intervals
%!assert (ceil (infsup (-0.5, 0)) == infsup (0));
%!assert (ceil (infsup (0, 0.5)) == infsup (0, 1));
%!assert (ceil (infsup (0.25, 0.5)) == infsup (1));
%!assert (ceil (infsup (-1, 0)) == infsup (-1, 0));
%!assert (ceil (infsup (-1, 1)) == infsup (-1, 1));
%!assert (ceil (infsup (-realmin, realmin)) == infsup (0, 1));
%!assert (ceil (infsup (-realmax, realmax)) == infsup (-realmax, realmax));

%!# Unbounded intervals
%!assert (ceil (infsup (-realmin, inf)) == infsup (0, inf));
%!assert (ceil (infsup (-realmax, inf)) == infsup (-realmax, inf));
%!assert (ceil (infsup (-inf, realmin)) == infsup (-inf, 1));
%!assert (ceil (infsup (-inf, realmax)) == infsup (-inf, realmax));
%!assert (ceil (infsup (-inf, inf)) == infsup (-inf, inf));

%!# from the documentation string
%!assert (ceil (infsup (2.5, 3.5)) == infsup (3, 4));
%!assert (ceil (infsup (-.5, 5)) == infsup (0, 5));

%!# correct use of signed zeros
%!test
%! x = ceil (infsup (-0.5));
%! assert (signbit (inf (x)));
%! assert (not (signbit (sup (x))));
%!test
%! x = ceil (infsup (0));
%! assert (signbit (inf (x)));
%! assert (not (signbit (sup (x))));

%!shared testdata
%! # Load compiled test data (from src/test/*.itl)
%! testdata = load (file_in_loadpath ("test/itl.mat"));

%!test
%! # Scalar evaluation
%! testcases = testdata.NoSignal.infsup.ceil;
%! for testcase = [testcases]'
%!   assert (isequaln (...
%!     ceil (testcase.in{1}), ...
%!     testcase.out));
%! endfor

%!test
%! # Vector evaluation
%! testcases = testdata.NoSignal.infsup.ceil;
%! in1 = vertcat (vertcat (testcases.in){:, 1});
%! out = vertcat (testcases.out);
%! assert (isequaln (ceil (in1), out));

%!test
%! # N-dimensional array evaluation
%! testcases = testdata.NoSignal.infsup.ceil;
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
%! assert (isequaln (ceil (in1), out));
