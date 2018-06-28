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
## @deftypemethod {@@infsupdec} {@var{X} =} mulrev (@var{B}, @var{C}, @var{X})
## @deftypemethodx {@@infsupdec} {@var{X} =} mulrev (@var{B}, @var{C})
## @deftypemethodx {@@infsupdec} {[@var{U}, @var{V}] =} mulrev (@var{B}, @var{C})
## @deftypemethodx {@@infsupdec} {[@var{U}, @var{V}] =} mulrev (@var{B}, @var{C}, @var{X})
##
## Compute the reverse multiplication function or the two-output division.
##
## That is, an enclosure of all @code{x ∈ @var{X}} where
## @code{x .* b ∈ @var{C}} for any @code{b ∈ @var{B}}.
##
## This function is similar to interval division @code{@var{C} ./ @var{B}}.
## However, it treats the case 0/0 as “any real number” instead of “undefined”.
##
## Interval division, considered as a set, can have zero, one or two disjoint
## connected components as a result.  If called with two output parameters,
## this function returns the components separately.  @var{U} contains the
## negative or unique component, whereas @var{V} contains the positive
## component in cases with two components.
##
## Accuracy: The result is a tight enclosure.
##
## @comment DO NOT SYNCHRONIZE DOCUMENTATION STRING
## No one way of decorating this operations gives useful information in all
## contexts.  Therefore, the result will carry a @code{trv} decoration at best.
##
## @example
## @group
## c = infsupdec (1);
## b = infsupdec (-inf, inf);
## [u, v] = mulrev (b, c)
##   @result{}
##     u = [-inf, 0]_trv
##     v = [0, inf]_trv
## @end group
## @end example
## @seealso{@@infsupdec/times}
## @end deftypemethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-19

function [u, v] = mulrev (b, c, x)

  if (nargin < 2 || nargin > 3)
    print_usage ();
    return
  endif

  if (nargin < 3)
    x = infsupdec (-inf, inf);
  endif
  if (not (isa (b, "infsupdec")))
    b = infsupdec (b);
  endif
  if (not (isa (c, "infsupdec")))
    c = infsupdec (c);
  endif
  if (not (isa (x, "infsupdec")))
    x = infsupdec (x);
  endif

  if (nargout < 2)
    u = mulrev (b.infsup, c.infsup, x.infsup);
    u = infsupdec (u, "trv");
    u.dec(isnai (x) | isnai (b) | isnai (c)) = _ill ();
  else
    [u, v] = mulrev (b.infsup, c.infsup, x.infsup);
    u = newdec (u);
    u.dec(isempty (b) | isempty (c) | ismember (0, b)) = _trv ();
    u.dec = min (u.dec, min (b.dec, c.dec));
    u.dec(isnai (x)) = _ill ();

    v = infsupdec (v, "trv");
    v.dec(isnai (x) | isnai (b) | isnai (c)) = _ill ();
  endif

endfunction

%!# IEEE Std 1788-2015 mulRevToPair examples
%!test
%!  [u, v] = mulrev (infsupdec (0), infsupdec (1, 2));
%!  assert (isempty (u) & isempty (v));
%!test
%!  [u, v] = mulrev (infsupdec (0), infsupdec (0, 1));
%!  assert (isentire (u) & isempty (v));
%!test
%!  [u, v] = mulrev (infsupdec (1), infsupdec (1, 2));
%!  assert (isequal (u, infsupdec (1, 2)) & isempty (v));
%!test
%!  [u, v] = mulrev (infsupdec (1, inf), infsupdec (1));
%!  assert (isequal (u, infsupdec (0, 1, "dac")) & isempty (v));
%!test
%!  [u, v] = mulrev (infsupdec (-1, 1), infsupdec (1, 2));
%!  assert (isequal (u, infsupdec (-inf, -1, "trv")) & isequal (v, infsupdec (1, inf, "trv")));
%!test
%!  [u, v] = mulrev (infsupdec (-inf, inf), infsupdec (1));
%!  assert (isequal (u, infsupdec (-inf, 0, "trv")) & isequal (v, infsupdec (0, inf, "trv")));

%!shared testdata
%! # Load compiled test data (from src/test/*.itl)
%! testdata = load (file_in_loadpath ("test/itl.mat"));

%!test
%! # Scalar evaluation
%! testcases = testdata.NoSignal.infsupdec.mulRevToPair1;
%! for testcase = [testcases]'
%!   assert (isequaln (...
%!     nthargout (1, 2, @mulrev, testcase.in{1}, testcase.in{2}), ...
%!     testcase.out));
%! endfor

%!test
%! # Vector evaluation
%! testcases = testdata.NoSignal.infsupdec.mulRevToPair1;
%! in1 = vertcat (vertcat (testcases.in){:, 1});
%! in2 = vertcat (vertcat (testcases.in){:, 2});
%! out = vertcat (testcases.out);
%! assert (isequaln (nthargout (1, 2, @mulrev, in1, in2), out));

%!test
%! # N-dimensional array evaluation
%! testcases = testdata.NoSignal.infsupdec.mulRevToPair1;
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
%! assert (isequaln (nthargout (1, 2, @mulrev, in1, in2), out));

%!test
%! # Scalar evaluation
%! testcases = testdata.NoSignal.infsupdec.mulRevToPair2;
%! for testcase = [testcases]'
%!   assert (isequaln (...
%!     nthargout (2, @mulrev, testcase.in{1}, testcase.in{2}), ...
%!     testcase.out));
%! endfor

%!test
%! # Vector evaluation
%! testcases = testdata.NoSignal.infsupdec.mulRevToPair2;
%! in1 = vertcat (vertcat (testcases.in){:, 1});
%! in2 = vertcat (vertcat (testcases.in){:, 2});
%! out = vertcat (testcases.out);
%! assert (isequaln (nthargout (2, @mulrev, in1, in2), out));

%!test
%! # N-dimensional array evaluation
%! testcases = testdata.NoSignal.infsupdec.mulRevToPair2;
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
%! assert (isequaln (nthargout (2, @mulrev, in1, in2), out));

%!test
%! # Scalar evaluation
%! testcases = testdata.NoSignal.infsupdec.mulRev;
%! for testcase = [testcases]'
%!   assert (isequaln (...
%!     mulrev (testcase.in{1}, testcase.in{2}), ...
%!     testcase.out));
%! endfor

%!test
%! # Vector evaluation
%! testcases = testdata.NoSignal.infsupdec.mulRev;
%! in1 = vertcat (vertcat (testcases.in){:, 1});
%! in2 = vertcat (vertcat (testcases.in){:, 2});
%! out = vertcat (testcases.out);
%! assert (isequaln (mulrev (in1, in2), out));

%!test
%! # N-dimensional array evaluation
%! testcases = testdata.NoSignal.infsupdec.mulRev;
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
%! assert (isequaln (mulrev (in1, in2), out));

%!test
%! # Scalar evaluation
%! testcases = testdata.NoSignal.infsupdec.mulRevTen;
%! for testcase = [testcases]'
%!   assert (isequaln (...
%!     mulrev (testcase.in{1}, testcase.in{2}, testcase.in{3}), ...
%!     testcase.out));
%! endfor

%!test
%! # Vector evaluation
%! testcases = testdata.NoSignal.infsupdec.mulRevTen;
%! in1 = vertcat (vertcat (testcases.in){:, 1});
%! in2 = vertcat (vertcat (testcases.in){:, 2});
%! in3 = vertcat (vertcat (testcases.in){:, 3});
%! out = vertcat (testcases.out);
%! assert (isequaln (mulrev (in1, in2, in3), out));

%!test
%! # N-dimensional array evaluation
%! testcases = testdata.NoSignal.infsupdec.mulRevTen;
%! in1 = vertcat (vertcat (testcases.in){:, 1});
%! in2 = vertcat (vertcat (testcases.in){:, 2});
%! in3 = vertcat (vertcat (testcases.in){:, 3});
%! out = vertcat (testcases.out);
%! # Reshape data
%! i = -1;
%! do
%!   i = i + 1;
%!   testsize = factor (numel (in1) + i);
%! until (numel (testsize) > 2)
%! in1 = reshape ([in1; in1(1:i)], testsize);
%! in2 = reshape ([in2; in2(1:i)], testsize);
%! in3 = reshape ([in3; in3(1:i)], testsize);
%! out = reshape ([out; out(1:i)], testsize);
%! assert (isequaln (mulrev (in1, in2, in3), out));
