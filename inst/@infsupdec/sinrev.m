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
## @deftypemethod {@@infsupdec} {@var{X} =} sinrev (@var{C}, @var{X})
## @deftypemethodx {@@infsupdec} {@var{X} =} sinrev (@var{C})
##
## Compute the reverse sine function.
##
## That is, an enclosure of all @code{x ∈ @var{X}} where
## @code{sin (x) ∈ @var{C}}.
##
## Accuracy: The result is a valid enclosure.
##
## @comment DO NOT SYNCHRONIZE DOCUMENTATION STRING
## No one way of decorating this operations gives useful information in all
## contexts.  Therefore, the result will carry a @code{trv} decoration at best.
##
## @example
## @group
## sinrev (infsupdec (-1), infsupdec (0, 6))
##   @result{} ans ⊂ [4.7123, 4.7124]_trv
## @end group
## @end example
## @seealso{@@infsupdec/sin}
## @end deftypemethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-19

function result = sinrev (c, x)

  if (nargin > 2)
    print_usage ();
    return
  endif

  if (nargin < 2)
    x = infsupdec (-inf, inf);
  endif
  if (not (isa (c, "infsupdec")))
    c = infsupdec (c);
  endif
  if (not (isa (x, "infsupdec")))
    x = infsupdec (x);
  endif

  result = infsupdec (sinrev (c.infsup, x.infsup), "trv");
  result.dec(isnai (c) | isnai (x)) = _ill ();

endfunction

%!# from the documentation string
%!assert (isequal (sinrev (infsupdec (-1), infsupdec (0, 6)), infsupdec ("[0x1.2D97C7F3321D2p2, 0x1.2D97C7F3321D3p2]_trv")));

%!shared testdata
%! # Load compiled test data (from src/test/*.itl)
%! testdata = load (file_in_loadpath ("test/itl.mat"));

%!test
%! # Scalar evaluation
%! testcases = testdata.NoSignal.infsupdec.sinRev;
%! for testcase = [testcases]'
%!   assert (isequaln (...
%!     sinrev (testcase.in{1}), ...
%!     testcase.out));
%! endfor

%!test
%! # Vector evaluation
%! testcases = testdata.NoSignal.infsupdec.sinRev;
%! in1 = vertcat (vertcat (testcases.in){:, 1});
%! out = vertcat (testcases.out);
%! assert (isequaln (sinrev (in1), out));

%!test
%! # N-dimensional array evaluation
%! testcases = testdata.NoSignal.infsupdec.sinRev;
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
%! assert (isequaln (sinrev (in1), out));

%!test
%! # Scalar evaluation
%! testcases = testdata.NoSignal.infsupdec.sinRevBin;
%! for testcase = [testcases]'
%!   assert (isequaln (...
%!     sinrev (testcase.in{1}, testcase.in{2}), ...
%!     testcase.out));
%! endfor

%!test
%! # Vector evaluation
%! testcases = testdata.NoSignal.infsupdec.sinRevBin;
%! in1 = vertcat (vertcat (testcases.in){:, 1});
%! in2 = vertcat (vertcat (testcases.in){:, 2});
%! out = vertcat (testcases.out);
%! assert (isequaln (sinrev (in1, in2), out));

%!test
%! # N-dimensional array evaluation
%! testcases = testdata.NoSignal.infsupdec.sinRevBin;
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
%! assert (isequaln (sinrev (in1, in2), out));
