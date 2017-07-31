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
## @defmethod {@@infsupdec} atan2 (@var{Y}, @var{X})
##
## Compute the inverse tangent with two arguments.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## atan2 (infsupdec (1), infsupdec (-1))
##   @result{} ans ⊂ [2.3561, 2.3562]_com
## @end group
## @end example
## @seealso{@@infsupdec/tan}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-13

function result = atan2 (y, x)

  if (nargin ~= 2)
    print_usage ();
    return
  endif

  if (not (isa (y, "infsupdec")))
    y = infsupdec (y);
  endif
  if (not (isa (x, "infsupdec")))
    x = infsupdec (x);
  endif

  result = newdec (atan2 (y.infsup, x.infsup));

  ## The function is discontinuous for x <= 0 and y == 0
  discontinuos = inf (y) < 0 & sup (y) >= 0 & inf (x) < 0;
  result.dec(discontinuos) = min (result.dec(discontinuos), _def ());

  ## For y = [0, y.sup] the function is discontinuous, but its
  ## restriction is not
  onlyrestrictioncontinuous = inf (y) == 0 & inf (x) < 0;
  result.dec(onlyrestrictioncontinuous) = ...
  min (result.dec(onlyrestrictioncontinuous), _dac ());

  ## The only undefined input is <0,0>
  result.dec(ismember (0, y) & ismember (0, x)) = _trv ();

  result.dec = min (result.dec, min (y.dec, x.dec));

endfunction

%!# from the documentation string
%!assert (isequal (atan2 (infsupdec (1), infsupdec (-1)), infsupdec ("[0x1.2D97C7F3321D2p1, 0x1.2D97C7F3321D3p1]")));

%!shared testdata
%! # Load compiled test data (from src/test/*.itl)
%! testdata = load (file_in_loadpath ("test/itl.mat"));

%!test
%! # Scalar evaluation
%! testcases = testdata.NoSignal.infsupdec.atan2;
%! for testcase = [testcases]'
%!   assert (isequaln (...
%!     atan2 (testcase.in{1}, testcase.in{2}), ...
%!     testcase.out));
%! endfor

%!test
%! # Vector evaluation
%! testcases = testdata.NoSignal.infsupdec.atan2;
%! in1 = vertcat (vertcat (testcases.in){:, 1});
%! in2 = vertcat (vertcat (testcases.in){:, 2});
%! out = vertcat (testcases.out);
%! assert (isequaln (atan2 (in1, in2), out));

%!test
%! # N-dimensional array evaluation
%! testcases = testdata.NoSignal.infsupdec.atan2;
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
%! assert (isequaln (atan2 (in1, in2), out));
