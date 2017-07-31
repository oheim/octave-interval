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
## @defmethod {@@infsup} sec (@var{X})
##
## Compute the secant in radians, that is the reciprocal cosine.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## sec (infsup (1))
##   @result{} ans ⊂ [1.8508, 1.8509]
## @end group
## @end example
## @seealso{@@infsup/cos, @@infsup/csc, @@infsup/cot}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2015-03-15

function x = sec (x)

  if (nargin ~= 1)
    print_usage ();
    return
  endif

  l = u = derivl = derivu = zeros (size (x.inf));

  ## Check, if wid (x) is certainly greater than 2*pi. This can save the
  ## computation if some values.
  width = mpfr_function_d ('minus', -inf, x.sup, x.inf);
  persistent pi = infsup ("pi");
  certainlysingularity = width >= sup (pi);

  ## We simply compute the secant for both endpoints.
  select = not (certainlysingularity);
  l(select) = min (...
                    mpfr_function_d ('sec', -inf, x.inf(select)), ...
                    mpfr_function_d ('sec', -inf, x.sup(select)));
  u(select) = max (...
                    mpfr_function_d ('sec', inf, x.inf(select)), ...
                    mpfr_function_d ('sec', inf, x.sup(select)));

  ## A change of sign is a sufficient singularity indicator
  certainlysingularity = certainlysingularity | (select & sign (l) ~= sign (u));
  l(certainlysingularity) = -inf;
  u(certainlysingularity) = inf;

  ## Check, whether the interval contains a local extremum using the derivative
  select = not (certainlysingularity);
  derivl(select) = mpfr_function_d ('sec', 0, x.inf(select)) .* ...
                   mpfr_function_d ('tan', 0, x.inf(select));
  derivu(select) = mpfr_function_d ('sec', 0, x.sup(select)) .* ...
                   mpfr_function_d ('tan', 0, x.sup(select));
  hasextremum = select & ((derivl <= 0 & derivu >= 0) | ...
                          (derivl >= 0 & derivu <= 0));
  l(hasextremum & l > 0) = 1;
  u(hasextremum & u < 0) = -1;

  emptyresult = isempty (x);
  l(emptyresult) = inf;
  u(emptyresult) = -inf;

  x.inf = l;
  x.sup = u;

endfunction

%!# from the documentation string
%!assert (sec (infsup (1)) == "[0x1.D9CF0F125CC29, 0x1.D9CF0F125CC2A]");

%!shared testdata
%! # Load compiled test data (from src/test/*.itl)
%! testdata = load (file_in_loadpath ("test/itl.mat"));

%!test
%! # Scalar evaluation
%! testcases = testdata.NoSignal.infsup.sec;
%! for testcase = [testcases]'
%!   assert (isequaln (...
%!     sec (testcase.in{1}), ...
%!     testcase.out));
%! endfor

%!test
%! # Vector evaluation
%! testcases = testdata.NoSignal.infsup.sec;
%! in1 = vertcat (vertcat (testcases.in){:, 1});
%! out = vertcat (testcases.out);
%! assert (isequaln (sec (in1), out));

%!test
%! # N-dimensional array evaluation
%! testcases = testdata.NoSignal.infsup.sec;
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
%! assert (isequaln (sec (in1), out));
