## Copyright 2015-2016 Oliver Heimlich
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
## @defmethod {@@infsup} log1p (@var{X})
##
## Compute @code{log (1 + @var{X})} accurately in the neighborhood of zero.
##
## The function is only defined where @var{X} is greater than -1.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## log1p (infsup (eps))
##   @result{} ans ⊂ [2.2204e-16, 2.2205e-16]
## @end group
## @end example
## @seealso{@@infsup/exp, @@infsup/log}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2015-02-20

function x = log1p (x)

  if (nargin ~= 1)
    print_usage ();
    return
  endif

  x = intersect (x, infsup (-1, inf));

  ## log is monotonically increasing from (-1, -inf) to (inf, inf)
  if (__check_crlibm__ ())
    l = crlibm_function ('log1p', -inf, x.inf); # this works for empty intervals
    u = crlibm_function ('log1p', +inf, x.sup); # ... this does not
  else
    l = mpfr_function_d ('log1p', -inf, x.inf); # this works for empty intervals
    u = mpfr_function_d ('log1p', +inf, x.sup); # ... this does not
  endif

  l(x.sup == -1) = inf;
  l(l == 0) = -0;
  u(isempty (x) | x.sup == -1) = -inf;

  x.inf = l;
  x.sup = u;

endfunction

%!# from the documentation string
%!assert (log1p (infsup (eps)) == "[0x1.FFFFFFFFFFFFFp-53, 0x1p-52]");

%!# correct use of signed zeros
%!test
%! x = log1p (infsup (0));
%! assert (signbit (inf (x)));
%! assert (not (signbit (sup (x))));

%!shared testdata
%! # Load compiled test data (from src/test/*.itl)
%! testdata = load (file_in_loadpath ("test/itl.mat"));

%!test
%! # Scalar evaluation
%! testcases = testdata.NoSignal.infsup.logp1;
%! for testcase = [testcases]'
%!   assert (isequaln (...
%!     log1p (testcase.in{1}), ...
%!     testcase.out));
%! endfor

%!test
%! # Vector evaluation
%! testcases = testdata.NoSignal.infsup.logp1;
%! in1 = vertcat (vertcat (testcases.in){:, 1});
%! out = vertcat (testcases.out);
%! assert (isequaln (log1p (in1), out));

%!test
%! # N-dimensional array evaluation
%! testcases = testdata.NoSignal.infsup.logp1;
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
%! assert (isequaln (log1p (in1), out));
