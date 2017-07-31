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
## @defmethod {@@infsup} cot (@var{X})
##
## Compute the cotangent in radians, that is the reciprocal tangent.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## cot (infsup (1))
##   @result{} ans ⊂ [0.64209, 0.6421]
## @end group
## @end example
## @seealso{@@infsup/tan, @@infsup/csc, @@infsup/sec}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2015-03-15

function x = cot (x)

  if (nargin ~= 1)
    print_usage ();
    return
  endif

  l = u = zeros (size (x));

  ## Check, if wid (x) is certainly greater than pi. This may save computation of
  ## some cotangent values.
  width = mpfr_function_d ('minus', -inf, x.sup, x.inf);
  persistent pi = infsup ("pi");
  certainlyfullperiod = width >= sup (pi);

  possiblynotfullperiod = not (certainlyfullperiod);
  l(possiblynotfullperiod) = ...
  mpfr_function_d ('cot', -inf, x.sup(possiblynotfullperiod));
  u(possiblynotfullperiod) = ...
  mpfr_function_d ('cot', +inf, x.inf(possiblynotfullperiod));

  l(x.sup == 0) = -inf;
  u(x.inf == 0) = +inf;

  singularity = certainlyfullperiod | ...
                l > u | (...
                          width > 2 & (...
                                        sign (l) == sign (u) | ...
                                        max (abs (l), abs (u)) < 1));

  l(singularity) = -inf;
  u(singularity) = inf;

  emptyresult = isempty (x) | (x.inf == 0 & x.sup == 0);
  l(emptyresult) = inf;
  u(emptyresult) = -inf;

  x.inf = l;
  x.sup = u;

endfunction

%!# from the documentation string
%!assert (cot (infsup (1)) == "[0x1.48C05D04E1CFDp-1, 0x1.48C05D04E1CFEp-1]");

%!shared testdata
%! # Load compiled test data (from src/test/*.itl)
%! testdata = load (file_in_loadpath ("test/itl.mat"));

%!test
%! # Scalar evaluation
%! testcases = testdata.NoSignal.infsup.cot;
%! for testcase = [testcases]'
%!   assert (isequaln (...
%!     cot (testcase.in{1}), ...
%!     testcase.out));
%! endfor

%!test
%! # Vector evaluation
%! testcases = testdata.NoSignal.infsup.cot;
%! in1 = vertcat (vertcat (testcases.in){:, 1});
%! out = vertcat (testcases.out);
%! assert (isequaln (cot (in1), out));

%!test
%! # N-dimensional array evaluation
%! testcases = testdata.NoSignal.infsup.cot;
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
%! assert (isequaln (cot (in1), out));
