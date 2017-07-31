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
## @defmethod {@@infsup} asin (@var{X})
##
## Compute the inverse sine in radians (arcsine).
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## asin (infsup (.5))
##   @result{} ans ⊂ [0.52359, 0.5236]
## @end group
## @end example
## @seealso{@@infsup/sin}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-06

function x = asin (x)

  if (nargin ~= 1)
    print_usage ();
    return
  endif

  persistent domain = infsup (-1, 1);
  x = intersect (x, domain);

  ## asin is monotonically increasing from (-1, -pi/2) to (1, pi/2)
  if (__check_crlibm__ ())
    l = crlibm_function ('asin', -inf, x.inf);
    u = crlibm_function ('asin', +inf, x.sup);
  else
    l = mpfr_function_d ('asin', -inf, x.inf);
    u = mpfr_function_d ('asin', +inf, x.sup);
  endif
  l(l == 0) = -0;

  emptyresult = isempty (x);
  l(emptyresult) = inf;
  u(emptyresult) = -inf;

  x.inf = l;
  x.sup = u;

endfunction

%!# Empty interval
%!assert (asin (infsup ()) == infsup ());

%!# from the documentation string
%!assert (asin (infsup (.5)) == "[0x1.0C152382D7365p-1, 0x1.0C152382D7366p-1]");

%!# correct use of signed zeros
%!test
%! x = asin (infsup (0));
%! assert (signbit (inf (x)));
%! assert (not (signbit (sup (x))));

%!shared testdata
%! # Load compiled test data (from src/test/*.itl)
%! testdata = load (file_in_loadpath ("test/itl.mat"));

%!test
%! # Scalar evaluation
%! testcases = testdata.NoSignal.infsup.asin;
%! for testcase = [testcases]'
%!   assert (isequaln (...
%!     asin (testcase.in{1}), ...
%!     testcase.out));
%! endfor

%!test
%! # Vector evaluation
%! testcases = testdata.NoSignal.infsup.asin;
%! in1 = vertcat (vertcat (testcases.in){:, 1});
%! out = vertcat (testcases.out);
%! assert (isequaln (asin (in1), out));

%!test
%! # N-dimensional array evaluation
%! testcases = testdata.NoSignal.infsup.asin;
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
%! assert (isequaln (asin (in1), out));
