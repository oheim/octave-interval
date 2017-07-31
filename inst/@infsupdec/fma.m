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
## @defmethod {@@infsupdec} fma (@var{X}, @var{Y}, @var{Z})
##
## Fused multiply and add @code{@var{X} * @var{Y} + @var{Z}}.
##
## This function is semantically equivalent to evaluating multiplication and
## addition separately, but in addition guarantees a tight enclosure of the
## result.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## output_precision (16, 'local')
## fma (infsupdec (1+eps), infsupdec (7), infsupdec ("0.1"))
##   @result{} ans ⊂ [7.100000000000001, 7.100000000000003]_com
## infsupdec (1+eps) * infsupdec (7) + infsupdec ("0.1")
##   @result{} ans ⊂ [7.1, 7.100000000000003]_com
## @end group
## @end example
## @seealso{@@infsupdec/plus, @@infsupdec/mtimes}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-13

function result = fma (x, y, z)

  if (nargin ~= 3)
    print_usage ();
    return
  endif

  if (not (isa (x, "infsupdec")))
    x = infsupdec (x);
  endif
  if (not (isa (y, "infsupdec")))
    y = infsupdec (y);
  endif
  if (not (isa (z, "infsupdec")))
    z = infsupdec (z);
  endif

  result = newdec (fma (x.infsup, y.infsup, z.infsup));
  ## fma is defined and continuous everywhere
  result.dec = min (result.dec, min (x.dec, min (y.dec, z.dec)));

endfunction

%!# from the documentation string
%!assert (isequal (fma (infsupdec (1+eps), infsupdec (7), infsupdec ("0.1")), infsupdec ("[0x1.C666666666668p2, 0x1.C666666666669p2]")));

%!shared testdata
%! # Load compiled test data (from src/test/*.itl)
%! testdata = load (file_in_loadpath ("test/itl.mat"));

%!test
%! # Scalar evaluation
%! testcases = testdata.NoSignal.infsupdec.fma;
%! for testcase = [testcases]'
%!   assert (isequaln (...
%!     fma (testcase.in{1}, testcase.in{2}, testcase.in{3}), ...
%!     testcase.out));
%! endfor

%!test
%! # Vector evaluation
%! testcases = testdata.NoSignal.infsupdec.fma;
%! in1 = vertcat (vertcat (testcases.in){:, 1});
%! in2 = vertcat (vertcat (testcases.in){:, 2});
%! in3 = vertcat (vertcat (testcases.in){:, 3});
%! out = vertcat (testcases.out);
%! assert (isequaln (fma (in1, in2, in3), out));

%!test
%! # N-dimensional array evaluation
%! testcases = testdata.NoSignal.infsupdec.fma;
%! in1 = vertcat (vertcat (testcases.in){:, 1});
%! in2 = vertcat (vertcat (testcases.in){:, 2});
%! in3 = vertcat (vertcat (testcases.in){:, 3});
%! out = vertcat (testcases.out);
%! # Reshape data
%! i = -1;
%! do
%!   i = i + 1;
%!   testsize = factor (numel (in1) + i);
%! until (numel (testsize) > 2 | i == numel (in1))
%! in1 = reshape ([in1; in1(1:i)], testsize);
%! in2 = reshape ([in2; in2(1:i)], testsize);
%! in3 = reshape ([in3; in3(1:i)], testsize);
%! out = reshape ([out; out(1:i)], testsize);
%! assert (isequaln (fma (in1, in2, in3), out));
