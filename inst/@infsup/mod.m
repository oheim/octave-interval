## Copyright 2017 Oliver Heimlich
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
## @defmethod {@@infsup} mod (@var{X}, @var{Y})
##
## Compute the modulus of @var{X} and @var{Y}.
##
## Conceptionally, it is given by the expression
## @code{@var{X} - @var{Y} .* floor (@var{X} ./ @var{Y})}.  This function is
## undefined for @var{Y} = 0.
##
## Accuracy: The result is a valid enclosure.
##
## @example
## @group
## mod (infsup (3), infsup (2))
##   @result{} ans = [1]
## mod (infsup (-3), infsup (2))
##   @result{} ans = [1]
## @end group
## @end example
##
## @seealso{@@infsup/rdivide, @@infsup/rem}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2017-10-02

function [result, d] = mod (x, y)

  if (nargin ~= 2)
    print_usage ();
    return
  endif

  ## Usually, the implementation of an interval arithmetic function is cleanly
  ## split into a bare and a decorated version.  This function's decoration is
  ## quite complicated to be computed and depends on intermediate values that
  ## are used to compute the bare interval result.  Thus, we also compute
  ## decoration information as a second output parameter for @infsupdec.

  if (not (isa (x, "infsup")))
    x = infsup (x);
  endif
  if (not (isa (y, "infsup")))
    y = infsup (y);
  endif

  ## We can exploit the function's symmetric properties and
  ## compute each half-space by projection.
  y_p = intersect (y, infsup (0, inf));
  y_n = intersect (y, infsup (-inf, 0));

  [l1, u1, d1] = mod_positive_halfspace (x, y_p);
  [l2, u2, d2] = mod_positive_halfspace (x, -y_n);
  [l2, u2] = deal (-u2, -l2);

  l = min (l1, l2);
  u = max (u1, u2);

  warning ("off", "interval:UndefinedOperation", "local");
  result = infsup (l, u);

  d = min (d1, d2);

endfunction

function [l, u, d] = mod_positive_halfspace (x, y)

  ##   y = x / -1 *.                  ^ y                .* y = x / 1
  ##                *.      A         |         B      .*
  ##                  *.              |              .*
  ##               A    *.            |            .*    C
  ##   y = x / -2         *.          |          .*         y = x / 2
  ##             **..       *.        |        .*       ..**
  ##                 **..     *.      |      .*     ..**
  ##               A     **..   *.    |    .*   ..**     C
  ##                         **.. *.  |  .* ..**
  ##             (and so on)     **.*.|.*.**     (and so on)
  ##             ---------------------+---------------------> x
  ##
  ## Gradients:
  ##   A: positive x, postitive y
  ##   B: positive x
  ##   C: positive x, negative y
  ##
  ## Limit values:
  ##   x/y -> integer from above          mod (x, y) -> 0 from above
  ##   x   -> 0 from below                mod (x, y) -> y from below
  ##   x/y -> integer n != 0 from below   mod (x, y) -> x/n from below
  ##
  ## How to compute valid boundaries:
  ##   x >= 0: This function is equivalent to rem and can be computed with mpfr
  ##   x < 0: No corresponding mpfr function exists.  For x/y = integer this
  ##   function's value equals zero.  Otherwise it can be computed with
  ##   “rem (x, y) + y”.

  ## Compute fractions x ./ y at four corners of the interval box to detect
  ## cases with y = x ./ n inside the area, where the function is noncontinuous
  ## and takes extreme values.
  ##
  ##   y = x / -1 *.                  ^ y                .* y = x / 1
  ##                *.                |                .*
  ##                  *.        r-----+-----s        .*
  ##                    *.      |     |     |      .*
  ##   y = x / -2         *.    q-----+-----t    .*         y = x / 2
  ##             **..       *.        |        .*       ..**
  ##                 **..     *.      |      .*     ..**
  ##                     **..   *.    |    .*   ..**
  ##                         **.. *.  |  .* ..**
  ##             (and so on)     **.*.|.*.**     (and so on)
  ##             ---------------------+---------------------> x

  div_by_zero_idx = (y.inf == -0);
  y.inf(div_by_zero_idx) = +0;

  q = mpfr_function_d ("rdivide", -inf, x.inf, y.inf);
  r = mpfr_function_d ("rdivide", -inf, x.inf, y.sup);
  s = mpfr_function_d ("rdivide", +inf, x.sup, y.sup);
  t = mpfr_function_d ("rdivide", +inf, x.sup, y.inf);

  r(isnan (r)) = -1; # -inf / inf
  s(isnan (s)) = +1; # +inf / inf

  div_by_zero_idx = (div_by_zero_idx & true (size (x.inf)));

  ## The gradient is always in positive x direction.  Thus, the boundaries for
  ## the range of x/y can easily be computed as [a, b].
  a = min (q, r);
  b = max (s, t);

  ## Check for roots mod (x, y) == 0
  ceil_a = ceil (a);
  x_pos_idx = (x.inf > 0);
  ceil_a(a == 0 & x_pos_idx) = 1; # adjust limit values for y.inf = inf
  floor_b = floor (b);
  x_neg_idx = (x.sup < 0);
  floor_b(b == 0 & x_neg_idx) = -1; # adjust limit values for y.inf = inf
  a_root_idx = (a == ceil_a);
  discontinuity_idx = (ceil_a < floor_b | ...
                      (ceil_a == floor_b & not (a_root_idx)));
  root_idx = (a_root_idx | discontinuity_idx);

  l = u = zeros (size (a));
  d = _com ()(ones (size (a)));
  d(a_root_idx) = _dac ();
  d(discontinuity_idx) = _def ();
  d(div_by_zero_idx) = _trv ();

  ## If the interval box contains no cases with y = x/n, the minimum is
  ## located at x.inf.  Otherwise the minimum is zero.
  select = (not (root_idx) & x_pos_idx);
  l(select) = mpfr_function_d ("rem", -inf, x.inf(select), y.sup(select));
  select = (not (root_idx) & x_neg_idx);
  l(select) = max (0, mpfr_function_d ("plus", -inf, ...
    mpfr_function_d ("rem", -inf, x.inf(select), y.inf(select)), ...
    y.inf(select)));

  ## If the interval box contains no discontinuity, the maximum is located
  ## at x.sup.  Otherwise the maximum is computed below.
  x_nonneg_idx = (x.inf >= 0);
  select = (not (discontinuity_idx) & x_nonneg_idx & not (div_by_zero_idx));
  u(select) = mpfr_function_d ("rem", +inf, x.sup(select), y.inf(select));
  select = (not (discontinuity_idx) & x_neg_idx);
  u(select) = mpfr_function_d ("plus", +inf, ...
    mpfr_function_d ("rem", +inf, x.sup(select), y.sup(select)), ...
    y.sup(select));

  ## Consider the maximum for y = x/n, with n nearest to zero.
  n = zeros (size (u));
  n(x_pos_idx) = ceil_a(x_pos_idx);
  n(x_neg_idx) = floor_b(x_neg_idx);

  ## If x/y = a, the maximum is located at n = a+1
  select = (x_nonneg_idx & a_root_idx);
  n(select) = mpfr_function_d ("plus", 0, n(select), 1);

  ## Case 1: y.sup = x/n
  select = (discontinuity_idx & r <= n & n <= s);
  u(select) = y.sup(select);

  ## Case 2: y = x.sup/n
  select = (discontinuity_idx & n > 0 & s < n);
  u(select) = mpfr_function_d ("rdivide", +inf, x.sup(select), n(select));

  ## Case 3: y = x.inf/n
  select = (discontinuity_idx & n < 0 & n < r);
  u(select) = max (...
    mpfr_function_d ("rdivide", +inf, x.inf(select), n(select)), ...
    mpfr_function_d ("plus", +inf, ...
      mpfr_function_d ("rem", +inf, x.sup(select), y.sup(select)), ...
      y.sup(select)));

  empty_result_idx = y.sup <= 0;
  l(empty_result_idx) = inf;
  u(empty_result_idx) = -inf;
  d(empty_result_idx) = _com ();

endfunction

function d = _com ()
  d = uint8 (16);
endfunction

function d = _dac ()
  d = uint8 (12);
endfunction

function d = _def ()
  d = uint8 (8);
endfunction

function d = _trv ()
  d = uint8 (4);
endfunction

%!assert (mod (infsup (), infsup ()) == infsup ());
%!assert (mod (infsup (0), infsup ()) == infsup ());
%!assert (mod (infsup (), infsup (0)) == infsup ());

%!assert (mod (infsup (0), infsup (0)) == infsup ());
%!assert (mod (infsup (1), infsup (0)) == infsup ());
%!assert (mod (infsup (0, 1), infsup (0)) == infsup ());
%!assert (mod (infsup (1, 2), infsup (0)) == infsup ());
%!assert (mod (infsup (0, inf), infsup (0)) == infsup ());
%!assert (mod (infsup (1, inf), infsup (0)) == infsup ());
%!assert (mod (infsup (realmax, inf), infsup (0)) == infsup ());

%!assert (mod (infsup (0), infsup (1)) == infsup (0));
%!assert (mod (infsup (0), infsup (0, 1)) == infsup (0));
%!assert (mod (infsup (0), infsup (1, 2)) == infsup (0));
%!assert (mod (infsup (0), infsup (0, inf)) == infsup (0));
%!assert (mod (infsup (0), infsup (1, inf)) == infsup (0));
%!assert (mod (infsup (0), infsup (realmax, inf)) == infsup (0));

%!assert (mod (infsup (1), infsup (1)) == infsup (0));
%!assert (mod (infsup (2), infsup (1)) == infsup (0));
%!assert (mod (infsup (4), infsup (2)) == infsup (0));
%!assert (mod (infsup (6), infsup (3)) == infsup (0));
%!assert (mod (infsup (8), infsup (2)) == infsup (0));
%!assert (mod (infsup (9), infsup (3)) == infsup (0));
%!assert (mod (infsup (realmax), infsup (realmax)) == infsup (0));
%!assert (mod (infsup (realmax), infsup (realmax / 2)) == infsup (0));
%!assert (mod (infsup (realmax), infsup (realmax / 4)) == infsup (0));
%!assert (mod (infsup (realmax), infsup (realmax / 8)) == infsup (0));
%!assert (mod (infsup (realmax), infsup (realmax / 16)) == infsup (0));
%!assert (mod (infsup (realmax), infsup (realmax / 32)) == infsup (0));

%!assert (mod (infsup (0.1), infsup (0.1)) == infsup (0));
%!assert (mod (infsup (0.1 * 2), infsup (0.1)) == infsup (0));
%!assert (mod (infsup (0.1 * 4), infsup (0.1)) == infsup (0));
%!assert (mod (infsup (pi), infsup (pi)) == infsup (0));
%!assert (mod (infsup (pi), infsup (pi / 2)) == infsup (0));
%!assert (mod (infsup (pi), infsup (pi / 4)) == infsup (0));

%!assert (mod (infsup (pow2 (-1074)), infsup (pow2 (-1074))) == infsup (0));
%!assert (mod (infsup (pow2 (-1073)), infsup (pow2 (-1074))) == infsup (0));
%!assert (mod (infsup (pow2 (-1072)), infsup (pow2 (-1074))) == infsup (0));

%!assert (mod (infsup (1), infsup (2)) == infsup (1));
%!assert (mod (infsup (0.5), infsup (1)) == infsup (0.5));
%!assert (mod (infsup (pi), infsup (3.15)) == infsup (pi));

%!assert (mod (infsup (1), infsup (2, 3)) == infsup (1));
%!assert (mod (infsup (1), infsup (2, inf)) == infsup (1));
%!assert (mod (infsup (0.5), infsup (1, 2)) == infsup (0.5));
%!assert (mod (infsup (0.5), infsup (1, inf)) == infsup (0.5));
%!assert (mod (infsup (pi), infsup (3.15)) == infsup (pi));
%!assert (mod (infsup (pi), infsup (3.15, inf)) == infsup (pi));

%!assert (mod (infsup (0, 1), infsup (0, 1)) == infsup (0, 1));
%!assert (mod (infsup (0, 2), infsup (0, 1)) == infsup (0, 1));
%!assert (mod (infsup (0, 1), infsup (0, 2)) == infsup (0, 1));
%!assert (mod (infsup (0, realmax), infsup (0, realmax)) == infsup (0, realmax));
%!assert (mod (infsup (realmax, inf), infsup (realmax, inf)) == infsup (0, inf));
%!assert (mod (infsup (0, inf), infsup (0, inf)) == infsup (0, inf));

%!assert (mod (infsup (0), infsup (1)) == infsup (0));
%!assert (mod (infsup (1), infsup (1)) == infsup (0));
%!assert (mod (infsup (0, 1), infsup (1)) == infsup (0, 1));
%!assert (mod (infsup (1, 2), infsup (1)) == infsup (0, 1));
%!assert (mod (infsup (0, inf), infsup (1)) == infsup (0, 1));
%!assert (mod (infsup (1, inf), infsup (1)) == infsup (0, 1));
%!assert (mod (infsup (realmax, inf), infsup (1)) == infsup (0, 1));

%!assert (mod (infsup (1), infsup (1)) == infsup (0));
%!assert (mod (infsup (1), infsup (0, 1)) == infsup (0, 0.5));
%!assert (mod (infsup (1), infsup (1, 2)) == infsup (0, 1));
%!assert (mod (infsup (1), infsup (0, inf)) == infsup (0, 1));
%!assert (mod (infsup (1), infsup (1, inf)) == infsup (0, 1));
%!assert (mod (infsup (1), infsup (2, inf)) == infsup (1));
%!assert (mod (infsup (1), infsup (realmax, inf)) == infsup (1));
