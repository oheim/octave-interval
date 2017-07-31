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
## @defmethod {@@infsup} acos (@var{X})
##
## Compute the inverse cosine in radians (arccosine).
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## acos (infsup (.5))
##   @result{} ans ⊂ [1.0471, 1.0472]
## @end group
## @end example
## @seealso{@@infsup/cos}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-06

function x = acos (x)

  if (nargin ~= 1)
    print_usage ();
    return
  endif

  persistent domain = infsup (-1, 1);
  x = intersect (x, domain);

  ## acos is monotonically decreasing from (-1, pi) to (+1, 0)
  if (__check_crlibm__ ())
    l = crlibm_function ('acos', -inf, x.sup);
    u = crlibm_function ('acos', +inf, x.inf);
  else
    l = mpfr_function_d ('acos', -inf, x.sup);
    u = mpfr_function_d ('acos', +inf, x.inf);
  endif
  l(l == 0) = -0;

  emptyresult = isempty (x);
  l(emptyresult) = inf;
  u(emptyresult) = -inf;

  x.inf = l;
  x.sup = u;

endfunction

%!# Empty interval
%!assert (acos (infsup ()) == infsup ());

%!# Singleton intervals
%!assert (acos (infsup (-1)) == infsup ("pi"));
%!assert (subset (acos (infsup (-.5)), union ((infsup ("pi") / 2), infsup ("pi"))));
%!assert (acos (infsup (0)) == infsup ("pi") / 2);
%!assert (subset (acos (infsup (.5)), union ((infsup ("pi") / 2), infsup (0))));
%!assert (acos (infsup (1)) == infsup (0));

%!# Bounded intervals
%!assert (acos (infsup (-1, 0)) == union ((infsup ("pi") / 2), infsup ("pi")));
%!assert (acos (infsup (0, 1)) == union ((infsup ("pi") / 2), infsup (0)));
%!assert (acos (infsup (-1, 1)) == infsup (0, "pi"));
%!assert (acos (infsup (-2, 2)) == infsup (0, "pi"));

%!# Unbounded intervals
%!assert (acos (infsup (0, inf)) == union ((infsup ("pi") / 2), infsup (0)));
%!assert (acos (infsup (-inf, 0)) == union ((infsup ("pi") / 2), infsup ("pi")));
%!assert (acos (infsup (-inf, inf)) == infsup (0, "pi"));

%!# from the documentation string
%!assert (acos (infsup (.5)) == "[0x1.0C152382D7365, 0x1.0C152382D7366]");

%!# correct use of signed zeros
%!test
%! x = acos (infsup (1));
%! assert (signbit (inf (x)));
%! assert (not (signbit (sup (x))));

%!shared testdata
%! # Load compiled test data (from src/test/*.itl)
%! testdata = load (file_in_loadpath ("test/itl.mat"));

%!test
%! # Scalar evaluation
%! testcases = testdata.NoSignal.infsup.acos;
%! for testcase = [testcases]'
%!   assert (isequaln (...
%!     acos (testcase.in{1}), ...
%!     testcase.out));
%! endfor

%!test
%! # Vector evaluation
%! testcases = testdata.NoSignal.infsup.acos;
%! in1 = vertcat (vertcat (testcases.in){:, 1});
%! out = vertcat (testcases.out);
%! assert (isequaln (acos (in1), out));

%!test
%! # N-dimensional array evaluation
%! testcases = testdata.NoSignal.infsup.acos;
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
%! assert (isequaln (acos (in1), out));
