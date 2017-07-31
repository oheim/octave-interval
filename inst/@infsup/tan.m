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
## @defmethod {@@infsup} tan (@var{X})
##
## Compute the tangent in radians.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## tan (infsup (1))
##   @result{} ans ⊂ [1.5574, 1.5575]
## @end group
## @end example
## @seealso{@@infsup/atan, @@infsup/tanh}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-06

function x = tan (x)

  if (nargin ~= 1)
    print_usage ();
    return
  endif

  l = u = zeros (size (x));

  ## Check, if wid (x) is certainly greater than pi. This may save
  ## computation of some tangent values.
  width = mpfr_function_d ('minus', -inf, x.sup, x.inf);
  persistent pi = infsup ("pi");
  certainlyfullperiod = width >= sup (pi);

  possiblynotfullperiod = not (certainlyfullperiod);
  if (__check_crlibm__ ())
    l(possiblynotfullperiod) = crlibm_function ('tan', -inf, ...
                                                x.inf(possiblynotfullperiod));
    u(possiblynotfullperiod) = crlibm_function ('tan', inf, ...
                                                x.sup(possiblynotfullperiod));
  else
    l(possiblynotfullperiod) = mpfr_function_d ('tan', -inf, ...
                                                x.inf(possiblynotfullperiod));
    u(possiblynotfullperiod) = mpfr_function_d ('tan', inf, ...
                                                x.sup(possiblynotfullperiod));
  endif

  singularity = certainlyfullperiod | ...
                l > u | (...
                          width > 2 & (...
                                        sign (l) == sign (u) | ...
                                        max (abs (l), abs (u)) < 1));

  l(singularity) = -inf;
  u(singularity) = inf;

  emptyresult = isempty (x);
  l(emptyresult) = inf;
  u(emptyresult) = -inf;

  l(l == 0) = -0;

  x.inf = l;
  x.sup = u;

endfunction

%!# from the documentation string
%!assert (tan (infsup (1)) == "[0x1.8EB245CBEE3A5, 0x1.8EB245CBEE3A6]");

%!# correct use of signed zeros
%!test
%! x = tan (infsup (0));
%! assert (signbit (inf (x)));
%! assert (not (signbit (sup (x))));

%!shared testdata
%! # Load compiled test data (from src/test/*.itl)
%! testdata = load (file_in_loadpath ("test/itl.mat"));

%!test
%! # Scalar evaluation
%! testcases = testdata.NoSignal.infsup.tan;
%! for testcase = [testcases]'
%!   assert (isequaln (...
%!     tan (testcase.in{1}), ...
%!     testcase.out));
%! endfor

%!test
%! # Vector evaluation
%! testcases = testdata.NoSignal.infsup.tan;
%! in1 = vertcat (vertcat (testcases.in){:, 1});
%! out = vertcat (testcases.out);
%! assert (isequaln (tan (in1), out));

%!test
%! # N-dimensional array evaluation
%! testcases = testdata.NoSignal.infsup.tan;
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
%! assert (isequaln (tan (in1), out));
