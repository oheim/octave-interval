## Copyright 2014-2016 Oliver Heimlich
## Copyright 2017 Joel Dahne
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
## @defmethod {@@infsup} sin (@var{X})
##
## Compute the sine in radians.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## sin (infsup (1))
##   @result{} ans ⊂ [0.84147, 0.84148]
## @end group
## @end example
## @seealso{@@infsup/asin, @@infsup/csc, @@infsup/sinh}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-05

function x = sin (x)

  if (nargin ~= 1)
    print_usage ();
    return
  endif

  l = u = cossignl = cossignu = zeros (size (x.inf));

  ## Check, if wid (x) is certainly greater than 2*pi. This can save the
  ## computation if some sine values.
  width = mpfr_function_d ('minus', -inf, x.sup, x.inf);
  persistent pi = infsup ("pi");
  persistent twopi = 2 .* pi;
  certainlyfullperiod = width >= sup (twopi);
  l(certainlyfullperiod) = -1;
  u(certainlyfullperiod) = 1;

  possiblynotfullperiod = not (certainlyfullperiod);
  if (__check_crlibm__ ())
    l(possiblynotfullperiod) = min (crlibm_function ('sin', -inf, ...
                                                     x.inf(possiblynotfullperiod)), ...
                                    crlibm_function ('sin', -inf, ...
                                                     x.sup(possiblynotfullperiod)));
    u(possiblynotfullperiod) = max (crlibm_function ('sin', inf, ...
                                                     x.inf(possiblynotfullperiod)), ...
                                    crlibm_function ('sin', inf, ...
                                                     x.sup(possiblynotfullperiod)));

    ## We use sign (cos) to know the gradient at the boundaries.
    cossignl(possiblynotfullperiod) = sign (crlibm_function ('cos', .5, ...
                                                             x.inf(possiblynotfullperiod)));
    cossignu(possiblynotfullperiod) = sign (crlibm_function ('cos', .5, ...
                                                             x.sup(possiblynotfullperiod)));
  else
    l(possiblynotfullperiod) = min (mpfr_function_d ('sin', -inf, ...
                                                     x.inf(possiblynotfullperiod)), ...
                                    mpfr_function_d ('sin', -inf, ...
                                                     x.sup(possiblynotfullperiod)));
    u(possiblynotfullperiod) = max (mpfr_function_d ('sin', inf, ...
                                                     x.inf(possiblynotfullperiod)), ...
                                    mpfr_function_d ('sin', inf, ...
                                                     x.sup(possiblynotfullperiod)));

    ## We use sign (cos) to know the gradient at the boundaries.
    cossignl(possiblynotfullperiod) = sign (mpfr_function_d ('cos', .5, ...
                                                             x.inf(possiblynotfullperiod)));
    cossignu(possiblynotfullperiod) = sign (mpfr_function_d ('cos', .5, ...
                                                             x.sup(possiblynotfullperiod)));
  endif

  ## In case of sign (cos) == 0, we conservatively use sign (cos) of nextout.
  cossignl(cossignl == 0) = sign (l(cossignl == 0));
  cossignu(cossignu == 0) = (-1) * sign (u(cossignu == 0));

  containsinf = possiblynotfullperiod & ((cossignl == -1 & cossignu == 1) | ...
                                         (cossignl == cossignu & ...
                                          width >= sup (pi)));
  l(containsinf) = -1;

  containssup = possiblynotfullperiod & ((cossignl == 1 & cossignu == -1) | ...
                                         (cossignl == cossignu & ...
                                          width >= sup (pi)));
  u(containssup) = 1;

  emptyresult = isempty (x);
  l(emptyresult) = inf;
  u(emptyresult) = -inf;

  l(l == 0) = -0;
  u(u == 0) = +0;

  x.inf = l;
  x.sup = u;

endfunction

%!# from the documentation string
%!assert (sin (infsup (1)) == "[0x1.AED548F090CEEp-1, 0x1.AED548F090CEFp-1]");

%!# correct use of signed zeros
%!test
%! x = sin (infsup (0));
%! assert (signbit (inf (x)));
%! assert (not (signbit (sup (x))));

%!# test fix for bug #51283
%!test
%! x = sin (infsup ([0, 0]));
%! assert (signbit (inf (x)));
%! assert (not (signbit (sup (x))));

%!shared testdata
%! # Load compiled test data (from src/test/*.itl)
%! testdata = load (file_in_loadpath ("test/itl.mat"));

%!test
%! # Scalar evaluation
%! testcases = testdata.NoSignal.infsup.sin;
%! for testcase = [testcases]'
%!   assert (isequaln (...
%!     sin (testcase.in{1}), ...
%!     testcase.out));
%! endfor

%!test
%! # Vector evaluation
%! testcases = testdata.NoSignal.infsup.sin;
%! in1 = vertcat (vertcat (testcases.in){:, 1});
%! out = vertcat (testcases.out);
%! assert (isequaln (sin (in1), out));

%!test
%! # N-dimensional array evaluation
%! testcases = testdata.NoSignal.infsup.sin;
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
%! assert (isequaln (sin (in1), out));
