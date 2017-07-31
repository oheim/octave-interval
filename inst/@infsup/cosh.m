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
## @defmethod {@@infsup} cosh (@var{X})
##
## Compute the hyperbolic cosine.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## cosh (infsup (1))
##   @result{} ans ⊂ [1.543, 1.5431]
## @end group
## @end example
## @seealso{@@infsup/acosh, @@infsup/sech, @@infsup/sinh, @@infsup/tanh}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-07

function x = cosh (x)

  if (nargin ~= 1)
    print_usage ();
    return
  endif

  ## cosh is symmetric and has its global minimum located at (0, 1).
  if (__check_crlibm__ ())
    l = crlibm_function ('cosh', -inf, mig (x));
    u = crlibm_function ('cosh', +inf, mag (x));
  else
    l = mpfr_function_d ('cosh', -inf, mig (x));
    u = mpfr_function_d ('cosh', +inf, mag (x));
  endif

  emptyresult = isempty (x);
  l(emptyresult) = inf;
  u(emptyresult) = -inf;

  x.inf = l;
  x.sup = u;

endfunction

%!# from the documentation string
%!assert (cosh (infsup (1)) == "[0x1.8B07551D9F55, 0x1.8B07551D9F551]");

%!shared testdata
%! # Load compiled test data (from src/test/*.itl)
%! testdata = load (file_in_loadpath ("test/itl.mat"));

%!test
%! # Scalar evaluation
%! testcases = testdata.NoSignal.infsup.cosh;
%! for testcase = [testcases]'
%!   assert (isequaln (...
%!     cosh (testcase.in{1}), ...
%!     testcase.out));
%! endfor

%!test
%! # Vector evaluation
%! testcases = testdata.NoSignal.infsup.cosh;
%! in1 = vertcat (vertcat (testcases.in){:, 1});
%! out = vertcat (testcases.out);
%! assert (isequaln (cosh (in1), out));

%!test
%! # N-dimensional array evaluation
%! testcases = testdata.NoSignal.infsup.cosh;
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
%! assert (isequaln (cosh (in1), out));
