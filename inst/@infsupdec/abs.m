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
## @defmethod {@@infsupdec} abs (@var{X})
##
## Compute the absolute value of numbers.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## abs (infsupdec (2.5, 3.5))
##   @result{} ans = [2.5, 3.5]_com
## abs (infsupdec (-0.5, 5.5))
##   @result{} ans = [0, 5.5]_com
## @end group
## @end example
## @seealso{@@infsupdec/mag, @@infsupdec/mig}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-13

function result = abs (x)

  if (nargin ~= 1)
    print_usage ();
    return
  endif

  result = newdec (abs (x.infsup));
  ## abs is defined and continuous everywhere
  result.dec = min (result.dec, x.dec);

endfunction

%!# Empty interval
%!assert (isequal (abs (infsupdec ()), infsupdec ()));

%!# Singleton intervals
%!assert (isequal (abs (infsupdec (1)), infsupdec (1)));
%!assert (isequal (abs (infsupdec (0)), infsupdec (0)));
%!assert (isequal (abs (infsupdec (-1)), infsupdec (1)));
%!assert (isequal (abs (infsupdec (realmax)), infsupdec (realmax)));
%!assert (isequal (abs (infsupdec (realmin)), infsupdec (realmin)));
%!assert (isequal (abs (infsupdec (-realmin)), infsupdec (realmin)));
%!assert (isequal (abs (infsupdec (-realmax)), infsupdec (realmax)));

%!# Bounded intervals
%!assert (isequal (abs (infsupdec (1, 2)), infsupdec (1, 2)));
%!assert (isequal (abs (infsupdec (0, 1)), infsupdec (0, 1)));
%!assert (isequal (abs (infsupdec (-1, 1)), infsupdec (0, 1)));
%!assert (isequal (abs (infsupdec (-1, 0)), infsupdec (0, 1)));
%!assert (isequal (abs (infsupdec (-2, -1)), infsupdec (1, 2)));

%!# Unbounded intervals
%!assert (isequal (abs (infsupdec (0, inf)), infsupdec (0, inf)));
%!assert (isequal (abs (infsupdec (-inf, inf)), infsupdec (0, inf)));
%!assert (isequal (abs (infsupdec (-inf, 0)), infsupdec (0, inf)));
%!assert (isequal (abs (infsupdec (1, inf)), infsupdec (1, inf)));
%!assert (isequal (abs (infsupdec (-1, inf)), infsupdec (0, inf)));
%!assert (isequal (abs (infsupdec (-inf, -1)), infsupdec (1, inf)));
%!assert (isequal (abs (infsupdec (-inf, 1)), infsupdec (0, inf)));

%!# from the documentation string
%!assert (isequal (abs (infsupdec (2.5, 3.5)), infsupdec (2.5, 3.5)));
%!assert (isequal (abs (infsupdec (-0.5, 5.5)), infsupdec (0, 5.5)));

%!shared testdata
%! # Load compiled test data (from src/test/*.itl)
%! testdata = load (file_in_loadpath ("test/itl.mat"));

%!test
%! # Scalar evaluation
%! testcases = testdata.NoSignal.infsupdec.abs;
%! for testcase = [testcases]'
%!   assert (isequaln (...
%!     abs (testcase.in{1}), ...
%!     testcase.out));
%! endfor

%!test
%! # Vector evaluation
%! testcases = testdata.NoSignal.infsupdec.abs;
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
