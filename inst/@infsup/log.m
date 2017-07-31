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
## @defmethod {@@infsup} log (@var{X})
##
## Compute the natural logarithm.
##
## The function is only defined where @var{X} is positive.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## log (infsup (2))
##   @result{} ans ⊂ [0.69314, 0.69315]
## @end group
## @end example
## @seealso{@@infsup/exp, @@infsup/log2, @@infsup/log10}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-04

function x = log (x)

  if (nargin ~= 1)
    print_usage ();
    return
  endif

  x = intersect (x, infsup (0, inf));

  ## log is monotonically increasing from (0, -inf) to (inf, inf)
  if (__check_crlibm__ ())
    l = crlibm_function ('log', -inf, x.inf); # this works for empty intervals
    u = crlibm_function ('log', +inf, x.sup); # ... this does not
  else
    l = mpfr_function_d ('log', -inf, x.inf); # this works for empty intervals
    u = mpfr_function_d ('log', +inf, x.sup); # ... this does not
  endif

  l(x.sup == 0) = inf;
  l(l == 0) = -0;
  u(isempty (x) | x.sup == 0) = -inf;

  x.inf = l;
  x.sup = u;

endfunction

%!# from the documentation string
%!assert (log (infsup (2)) == "[0x1.62E42FEFA39EFp-1, 0x1.62E42FEFA39Fp-1]");

%!# correct use of signed zeros
%!test
%! x = log (infsup (1));
%! assert (signbit (inf (x)));
%! assert (not (signbit (sup (x))));

%!shared testdata
%! # Load compiled test data (from src/test/*.itl)
%! testdata = load (file_in_loadpath ("test/itl.mat"));

%!test
%! # Scalar evaluation
%! testcases = testdata.NoSignal.infsup.log;
%! for testcase = [testcases]'
%!   assert (isequaln (...
%!     log (testcase.in{1}), ...
%!     testcase.out));
%! endfor

%!test
%! # Vector evaluation
%! testcases = testdata.NoSignal.infsup.log;
%! in1 = vertcat (vertcat (testcases.in){:, 1});
%! out = vertcat (testcases.out);
%! assert (isequaln (log (in1), out));

%!test
%! # N-dimensional array evaluation
%! testcases = testdata.NoSignal.infsup.log;
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
%! assert (isequaln (log (in1), out));
