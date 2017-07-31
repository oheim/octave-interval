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
## @defmethod {@@infsupdec} pow10 (@var{X})
##
## Compute @code{10^x} for all numbers in @var{X}.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## pow10 (infsupdec (5))
##   @result{} ans = [1e+05]_com
## @end group
## @end example
## @seealso{@@infsupdec/log10, @@infsupdec/pow, @@infsupdec/pow2, @@infsupdec/exp}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-13

function result = pow10 (x)

  if (nargin ~= 1)
    print_usage ();
    return
  endif

  result = newdec (pow10 (x.infsup));
  ## pow10 is defined and continuous everywhere
  result.dec = min (result.dec, x.dec);

endfunction

%!# from the documentation string
%!assert (isequal (pow10 (infsupdec (5)), infsupdec (100000)));

%!shared testdata
%! # Load compiled test data (from src/test/*.itl)
%! testdata = load (file_in_loadpath ("test/itl.mat"));

%!test
%! # Scalar evaluation
%! testcases = testdata.NoSignal.infsupdec.exp10;
%! for testcase = [testcases]'
%!   assert (isequaln (...
%!     pow10 (testcase.in{1}), ...
%!     testcase.out));
%! endfor

%!test
%! # Vector evaluation
%! testcases = testdata.NoSignal.infsupdec.exp10;
%! in1 = vertcat (vertcat (testcases.in){:, 1});
%! out = vertcat (testcases.out);
%! assert (isequaln (pow10 (in1), out));

%!test
%! # N-dimensional array evaluation
%! testcases = testdata.NoSignal.infsupdec.exp10;
%! in1 = vertcat (vertcat (testcases.in){:, 1});
%! out = vertcat (testcases.out);
%! # Reshape data
%! i = -1;
%! do
%!   i = i + 1;
%!   testsize = factor (numel (in1) + i);
%! until (numel (testsize) > 2 || i == numel (in1))
%! in1 = reshape ([in1; in1(1:i)], testsize);
%! out = reshape ([out; out(1:i)], testsize);
%! assert (isequaln (pow10 (in1), out));
