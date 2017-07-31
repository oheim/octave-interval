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
## @defmethod {@@infsup} sinh (@var{X})
##
## Compute the hyperbolic sine.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## sinh (infsup (1))
##   @result{} ans ⊂ [1.1752, 1.1753]
## @end group
## @end example
## @seealso{@@infsup/asinh, @@infsup/csch, @@infsup/cosh, @@infsup/tanh}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-06

function x = sinh (x)

  if (nargin ~= 1)
    print_usage ();
    return
  endif

  if (__check_crlibm__ ())
    l = crlibm_function ('sinh', -inf, x.inf);
    u = crlibm_function ('sinh', +inf, x.sup);
  else
    l = mpfr_function_d ('sinh', -inf, x.inf);
    u = mpfr_function_d ('sinh', +inf, x.sup);
  endif

  emptyresult = isempty (x);
  l(emptyresult) = inf;
  u(emptyresult) = -inf;

  l(l == 0) = -0;

  x.inf = l;
  x.sup = u;

endfunction

%!# from the documentation string
%!assert (sinh (infsup (1)) == "[0x1.2CD9FC44EB982, 0x1.2CD9FC44EB983]");

%!# correct use of signed zeros
%!test
%! x = sinh (infsup (0));
%! assert (signbit (inf (x)));
%! assert (not (signbit (sup (x))));

%!shared testdata
%! # Load compiled test data (from src/test/*.itl)
%! testdata = load (file_in_loadpath ("test/itl.mat"));

%!test
%! # Scalar evaluation
%! testcases = testdata.NoSignal.infsup.sinh;
%! for testcase = [testcases]'
%!   assert (isequaln (...
%!     sinh (testcase.in{1}), ...
%!     testcase.out));
%! endfor

%!test
%! # Vector evaluation
%! testcases = testdata.NoSignal.infsup.sinh;
%! in1 = vertcat (vertcat (testcases.in){:, 1});
%! out = vertcat (testcases.out);
%! assert (isequaln (sinh (in1), out));

%!test
%! # N-dimensional array evaluation
%! testcases = testdata.NoSignal.infsup.sinh;
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
%! assert (isequaln (sinh (in1), out));
