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
## @defmethod {@@infsupdec} ceil (@var{X})
##
## Round each number in interval @var{X} towards +Inf.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## ceil (infsupdec (2.5, 3.5))
##   @result{} ans = [3, 4]_def
## ceil (infsupdec (-0.5, 5))
##   @result{} ans = [0, 5]_def
## @end group
## @end example
## @seealso{@@infsupdec/floor, @@infsupdec/round, @@infsupdec/roundb, @@infsupdec/fix}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-13

function result = ceil (x)

  if (nargin ~= 1)
    print_usage ();
    return
  endif

  result = newdec (ceil (x.infsup));

  ## Between two integral numbers the function is constant, thus continuous
  discontinuos = not (issingleton (result));
  result.dec(discontinuos) = min (result.dec(discontinuos), _def ());

  onlyrestrictioncontinuous = issingleton (result) & fix (sup (x)) == sup (x);
  result.dec(onlyrestrictioncontinuous) = ...
  min (result.dec(onlyrestrictioncontinuous), _dac ());

  result.dec = min (result.dec, x.dec);

endfunction

%!# from the documentation string
%!assert (isequal (ceil (infsupdec (2.5, 3.5)), infsupdec (3, 4, "def")));
%!assert (isequal (ceil (infsupdec (-.5, 5)), infsupdec (0, 5, "def")));

%!shared testdata
%! # Load compiled test data (from src/test/*.itl)
%! testdata = load (file_in_loadpath ("test/itl.mat"));

%!test
%! # Scalar evaluation
%! testcases = testdata.NoSignal.infsupdec.ceil;
%! for testcase = [testcases]'
%!   assert (isequaln (...
%!     ceil (testcase.in{1}), ...
%!     testcase.out));
%! endfor

%!test
%! # Vector evaluation
%! testcases = testdata.NoSignal.infsupdec.ceil;
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
