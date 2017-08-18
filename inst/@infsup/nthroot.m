## Copyright 2015-2016 Oliver Heimlich
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
## @defmethod {@@infsup} nthroot (@var{X}, @var{N})
##
## Compute the real n-th root of @var{X}.
##
## Accuracy: The result is a valid enclosure.  The result is a tight
## enclosure for @var{n} ≥ -2.  The result also is a tight enclosure if the
## reciprocal of @var{n} can be computed exactly in double-precision.
## @seealso{@@infsup/pown, @@infsup/pownrev, @@infsup/realsqrt, @@infsup/cbrt}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2015-02-20

function x = nthroot (x, n)

  if (nargin ~= 2)
    print_usage ();
    return
  endif
  if (not (isa (x, "infsup")))
    x = infsup (x);
  endif

  if (not (isnumeric (n)) || any ((fix (n) ~= n)(:)))
    error ("interval:InvalidOperand", "nthroot: degree is not an integer");
  endif

  if (any ((n == 0)(:)))
    error ("interval:InvalidOperand", ...
           "nthroot: degree must be nonzero");
  endif

  ## Resize, if broadcasting is needed
  if (not (size_equal (x.inf, n)))
    x.inf = ones (size (n)) .* x.inf;
    x.sup = ones (size (n)) .* x.sup;
    n = ones (size (x.inf)) .* n;
  endif

  even = mod (n, 2) == 0;
  odd = not (even);

  idx.type = "()";
  idx.subs = {even};
  x = subsasgn (x, idx, intersect (subsref (x, idx), infsup (0, inf)));

  positive = n > 0;
  negative = not (positive);
  emptyresult = isempty (x) ...
                | (even & negative & x.sup <= 0) ...
                | (negative & x.inf == 0 & x.sup == 0);

  ## Don't have to calculate empty results
  even = even & not (emptyresult);
  odd = odd & not (emptyresult);
  positive = positive & not (emptyresult);
  negative = negative & not (emptyresult);

  l = zeros (size (x.inf));
  u = inf (size (x.inf));

  ## Positive n
  l(positive) = mpfr_function_d ('nthroot', -inf, x.inf(positive), n(positive));
  u(positive) = mpfr_function_d ('nthroot', +inf, x.sup(positive), n(positive));

  ## Negative and even n
  select = even & negative & x.inf > 0 & isfinite (x.inf);
  u(select) = invrootrounded (x.inf(select), -n(select), +inf);

  select = even & negative & x.sup > 0 & isfinite (x.sup);
  l(select) = invrootrounded (x.sup(select), -n(select), -inf);

  ## Negative and odd n
  ## The result is computed as the union of the nthroot of the negative
  ## part and the positive part of x
  oddandnegative = odd & negative;

  ## Positive part of x
  l_positivepart = zeros (size (x.inf));
  u_positivepart = inf (size (x.inf));

  select = oddandnegative & x.inf > 0 & isfinite (x.inf);
  u_positivepart(select) = invrootrounded (x.inf(select), -n(select), +inf);

  select = oddandnegative & x.sup > 0 & isfinite (x.sup);
  l_positivepart(select) = invrootrounded (x.sup(select), -n(select), -inf);

  l_positivepart(x.sup <= 0) = inf;
  u_positivepart(x.sup <= 0) = -inf;

  l(l == 0) = -0;

  ## Negative part of x
  l_negativepart = zeros (size (x.inf));
  u_negativepart = inf (size (x.inf));

  select = oddandnegative & x.sup < 0 & isfinite (x.sup);
  u_negativepart(select) = invrootrounded (-x.sup(select), -n(select), +inf);

  select = oddandnegative & x.inf < 0 & isfinite (x.inf);
  l_negativepart(select) = invrootrounded (-x.inf(select), -n(select), -inf);


  l_negativepart(x.inf >= 0) = inf;
  u_negativepart(x.inf >= 0) = -inf;

  u(u == 0) = +0;

  ## Compute the union
  l(oddandnegative) = min (l_positivepart(oddandnegative), ...
                           -u_negativepart(oddandnegative));
  u(oddandnegative) = max (u_positivepart(oddandnegative), ...
                           -l_negativepart(oddandnegative));

  l(emptyresult) = inf;
  u(emptyresult) = -inf;

  u(u == 0) = +0;
  l(l == 0) = -0;

  x.inf = l;
  x.sup = u;

endfunction

function x = invrootrounded (z, n, direction)
  ## We cannot compute the inverse of the n-th root of z in a single step.
  ## Thus, we use three different ways for computation, each of which has an
  ## intermediate result with possible rounding errors and can't guarantee to
  ## produce a correctly rounded result.
  ## When we finally merge the 3 results, it is still not guaranteed to be
  ## correctly rounded. However, chances are good that one of the three ways
  ## produced a “relatively good” result.
  ##
  ## x1:  z ^ (- 1 / n)
  ## x2:  1 / root (z, n)
  ## x3:  root (1 / z, n)

  inv_n = 1 ./ infsup (n);
  if (direction > 0)
    x1 = z;
    select = z > 1;
    x1(select) = mpfr_function_d ('pow', direction, z(select), ...
                                  -inv_n.inf(select));
    select = z < 1;
    x1(select) = mpfr_function_d ('pow', direction, z(select), ...
                                  -inv_n.sup(select));
  else
    x1 = z;
    select = z > 1;
    x1(select) = mpfr_function_d ('pow', direction, z(select), ...
                                  -inv_n.sup(select));
    select = z < 1;
    x1(select) = mpfr_function_d ('pow', direction, z(select), ...
                                  -inv_n.inf(select));
  endif

  exact = issingleton (inv_n);

  x = z;
  x(exact) = x1(exact);

  inexact = not (exact);

  if (any (inexact(:)))
    x2 = mpfr_function_d ('rdivide', direction, 1, ...
                          mpfr_function_d ('nthroot', -direction, ...
                                           z(inexact), n(inexact)));
    x3 = mpfr_function_d ('nthroot', direction, ...
                          mpfr_function_d ('rdivide', direction, ...
                                           1, z(inexact)), n(inexact));

    ## Choose the most accurate result
    if (direction > 0)
      x(inexact) = min (min (x1(inexact), x2), x3);
    else
      x(inexact) = max (max (x1(inexact), x2), x3);
    endif
  endif

endfunction

%!assert (nthroot (infsup (25, 36), 2) == infsup (5, 6));

%!# correct use of signed zeros
%!test
%! x = nthroot (infsup (0), 2);
%! assert (signbit (inf (x)));
%! assert (not (signbit (sup (x))));
%!test
%! x = nthroot (infsup (0, inf), -2);
%! assert (signbit (inf (x)));
%!test
%! x = nthroot (infsup (0, inf), -3);
%! assert (signbit (inf (x)));

%!assert (nthroot (infsup (-1, 1), 2) == infsup (0, 1));
%!assert (nthroot (infsup (-1, 1), 3) == infsup (-1, 1));
%!assert (nthroot (infsup (-1, 1), -2) == infsup (1, inf));
%!assert (nthroot (infsup (-1, 1), -3) == infsup (-inf, inf));

%!shared testdata
%! # Load compiled test data (from src/test/*.itl)
%! testdata = load (file_in_loadpath ("test/itl.mat"));

%!test
%! # Scalar evaluation
%! testcases = testdata.NoSignal.infsup.rootn;
%! for testcase = [testcases]'
%!   assert (isequaln (...
%!     nthroot (testcase.in{1}, testcase.in{2}), ...
%!     testcase.out));
%! endfor

%!test
%! # Vector evaluation
%! testcases = testdata.NoSignal.infsup.rootn;
%! in1 = vertcat (vertcat (testcases.in){:, 1});
%! in2 = vertcat (vertcat (testcases.in){:, 2});
%! out = vertcat (testcases.out);
%! assert (isequaln (nthroot (in1, in2), out));

%!test
%! # N-dimensional array evaluation
%! testcases = testdata.NoSignal.infsup.rootn;
%! in1 = vertcat (vertcat (testcases.in){:, 1});
%! in2 = vertcat (vertcat (testcases.in){:, 2});
%! out = vertcat (testcases.out);
%! # Reshape data
%! i = -1;
%! do
%!   i = i + 1;
%!   testsize = factor (numel (in1) + i);
%! until (numel (testsize) > 2)
%! if (i > numel (in1))
%!   i = i - numel (in1);
%!   in1 = [in1; in1];
%!   in2 = [in2; in2];
%!   out = [out; out];
%! endif
%! in1 = reshape ([in1; in1(1:i)], testsize);
%! in2 = reshape ([in2; in2(1:i)], testsize);
%! out = reshape ([out; out(1:i)], testsize);
%! assert (isequaln (nthroot (in1, in2), out));
