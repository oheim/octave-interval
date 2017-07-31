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
## @defop Method {@@infsupdec} rdivide (@var{X}, @var{Y})
## @defopx Operator {@@infsupdec} {@var{X} ./ @var{Y}}
##
## Divide all numbers of interval @var{X} by all numbers of @var{Y}.
##
## For @var{X} = 1 compute the reciprocal of @var{Y}.  Thus this function can
## compute @code{recip} as defined by IEEE Std 1788-2015.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## x = infsupdec (2, 3);
## y = infsupdec (1, 2);
## x ./ y
##   @result{} ans = [1, 3]_com
## @end group
## @end example
## @seealso{@@infsupdec/mtimes}
## @end defop

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-13

function result = rdivide (x, y)

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

  result = newdec (rdivide (x.infsup, y.infsup));

  divisionbyzero = ismember (0, y);
  if (not (size_equal (x.dec, y.dec)))
    divisionbyzero = divisionbyzero & true (size (x.dec));
  endif
  result.dec(divisionbyzero) = _trv ();

  result.dec = min (result.dec, min (x.dec, y.dec));

endfunction

%!# from the documentation string
%!assert (isequal (infsupdec (2, 3) ./ infsupdec (1, 2), infsupdec (1, 3)));

%!assert (1 ./ infsupdec (1, 4) == infsupdec (0.25, 1));

%!shared testdata
%! # Load compiled test data (from src/test/*.itl)
%! testdata = load (file_in_loadpath ("test/itl.mat"));

%!test
%! # Scalar evaluation
%! testcases = testdata.NoSignal.infsupdec.div;
%! for testcase = [testcases]'
%!   assert (isequaln (...
%!     rdivide (testcase.in{1}, testcase.in{2}), ...
%!     testcase.out));
%! endfor

%!test
%! # Vector evaluation
%! testcases = testdata.NoSignal.infsupdec.div;
%! in1 = vertcat (vertcat (testcases.in){:, 1});
%! in2 = vertcat (vertcat (testcases.in){:, 2});
%! out = vertcat (testcases.out);
%! assert (isequaln (rdivide (in1, in2), out));

%!test
%! # N-dimensional array evaluation
%! testcases = testdata.NoSignal.infsupdec.div;
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
%! assert (isequaln (rdivide (in1, in2), out));

%!test
%! # Scalar evaluation
%! testcases = testdata.NoSignal.infsupdec.recip;
%! for testcase = [testcases]'
%!   assert (isequaln (...
%!     rdivide (1, testcase.in{1}), ...
%!     testcase.out));
%! endfor

%!test
%! # Vector evaluation
%! testcases = testdata.NoSignal.infsupdec.recip;
%! in1 = vertcat (vertcat (testcases.in){:, 1});
%! out = vertcat (testcases.out);
%! assert (isequaln (rdivide (1, in1), out));

%!test
%! # N-dimensional array evaluation
%! testcases = testdata.NoSignal.infsupdec.recip;
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
%! assert (isequaln (rdivide (1, in1), out));
