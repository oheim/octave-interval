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
## @defmethod {@@infsupdec} sign (@var{X})
##
## Compute the signum function for each number in interval @var{X}.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## sign (infsupdec (2, 3))
##   @result{} ans = [1]_com
## sign (infsupdec (0, 5))
##   @result{} ans = [0, 1]_def
## sign (infsupdec (-17))
##   @result{} ans = [-1]_com
## @end group
## @end example
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-13

function result = sign (x)

  if (nargin ~= 1)
    print_usage ();
    return
  endif

  result = newdec (sign (x.infsup));

  ## sign is defined everywhere and continuous for x ~= 0
  discontinuous = not (issingleton (result));
  result.dec(discontinuous) = min (result.dec(discontinuous), _def ());

  onlyrestrictioncontinuous = inf (x) == 0 & sup (x) == 0;
  result.dec(onlyrestrictioncontinuous) = ...
  min (result.dec(onlyrestrictioncontinuous), _dac ());

  result.dec = min (result.dec, x.dec);

endfunction

%!# from the documentation string
%!assert (isequal (sign (infsupdec (2, 3)), infsupdec (1)));
%!assert (isequal (sign (infsupdec (0)), infsupdec (0, "dac")));
%!assert (isequal (sign (infsupdec (0, 5)), infsupdec (0, 1, "def")));
%!assert (isequal (sign (infsupdec (-17)), infsupdec (-1)));

%!shared testdata
%! # Load compiled test data (from src/test/*.itl)
%! testdata = load (file_in_loadpath ("test/itl.mat"));

%!test
%! # Scalar evaluation
%! testcases = testdata.NoSignal.infsupdec.sign;
%! for testcase = [testcases]'
%!   assert (isequaln (...
%!     sign (testcase.in{1}), ...
%!     testcase.out));
%! endfor

%!test
%! # Vector evaluation
%! testcases = testdata.NoSignal.infsupdec.sign;
%! in1 = vertcat (vertcat (testcases.in){:, 1});
%! out = vertcat (testcases.out);
%! assert (isequaln (sign (in1), out));

%!test
%! # N-dimensional array evaluation
%! testcases = testdata.NoSignal.infsup.sign;
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
%! assert (isequaln (sign (in1), out));
