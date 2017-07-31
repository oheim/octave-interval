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
## @defmethod {@@infsupdec} pow (@var{X}, @var{Y})
##
## Compute the simple power function on intervals defined by
## @code{exp (@var{Y} * log (@var{X}))}.
##
## The function is only defined where @var{X} is positive or where @var{X} is
## zero and @var{Y} is positive.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## pow (infsupdec (5, 6), infsupdec (2, 3))
##   @result{} ans = [25, 216]_com
## @end group
## @end example
## @seealso{@@infsupdec/pown, @@infsupdec/pow2, @@infsupdec/pow10, @@infsupdec/exp, @@infsupdec/mpower}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-13

function result = pow (x, y)

  if (nargin ~= 2)
    print_usage ();
    return
  endif

  if (not (isa (x, "infsupdec")))
    x = infsupdec (x);
  endif
  if (not (isa (y, "infsupdec")))
    y = infsupdec (y);
  endif

  result = newdec (pow (x.infsup, y.infsup));

  ## pow is continuous everywhere (where it is defined),
  ## but defined for x > 0 or (x = 0 and y > 0) only
  persistent nonnegative = infsup (0, inf);
  domain = interior (x.infsup, nonnegative) | ...
           (subset (x.infsup, nonnegative) & interior (y.infsup, nonnegative));

  result.dec(not (domain)) = _trv ();

  result.dec = min (result.dec, min (x.dec, y.dec));

endfunction

%!# from the documentation string
%!assert (isequal (pow (infsupdec (5, 6), infsupdec (2, 3)), infsupdec (25, 216)));

%!shared testdata
%! # Load compiled test data (from src/test/*.itl)
%! testdata = load (file_in_loadpath ("test/itl.mat"));

%!test
%! # Scalar evaluation
%! testcases = testdata.NoSignal.infsupdec.pow;
%! for testcase = [testcases]'
%!   assert (isequaln (...
%!     pow (testcase.in{1}, testcase.in{2}), ...
%!     testcase.out));
%! endfor

%!test
%! # Vector evaluation
%! testcases = testdata.NoSignal.infsupdec.pow;
%! in1 = vertcat (vertcat (testcases.in){:, 1});
%! in2 = vertcat (vertcat (testcases.in){:, 2});
%! out = vertcat (testcases.out);
%! assert (isequaln (pow (in1, in2), out));

%!test
%! # N-dimensional array evaluation
%! testcases = testdata.NoSignal.infsupdec.pow;
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
%! assert (isequaln (pow (in1, in2), out));
