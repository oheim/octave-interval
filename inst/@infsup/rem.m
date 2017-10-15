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
## @defmethod {@@infsup} rem (@var{X}, @var{Y})
##
## Compute the remainder of the division @var{X} by @var{Y}.
##
## Conceptionally, it is given by the expression
## @code{@var{X} - @var{Y} .* fix (@var{X} ./ @var{Y})}.  For negative @var{X},
## the remainder will be either zero or negative.  This function is undefined
## for @var{Y} = 0.
##
## Accuracy: The result is a valid enclosure.
##
## @example
## @group
## rem (infsup (3), infsup (2))
##   @result{} ans = [1]
## rem (infsup (-3), infsup (2))
##   @result{} ans = [-1]
## @end group
## @end example
##
## @seealso{@@infsup/rdivide, @@infsup/mod}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2017-09-02

function [result, d] = rem (x, y)

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
  ## compute each quadrant by projection into the first quadrant.
  x_p = intersect (x, infsup (0, inf));
  x_n = intersect (x, infsup (-inf, 0));
  y_p = intersect (y, infsup (0, inf));
  y_n = intersect (y, infsup (-inf, 0));

  [l1, u1, d1] = rem_quadrant_I (x_p, y_p);
  [l2, u2, d2] = rem_quadrant_I (x_p, -y_n);
  [l3, u3, d3] = rem_quadrant_I (-x_n, y_p);
  [l3, u3] = deal (-u3, -l3);
  [l4, u4, d4] = rem_quadrant_I (-x_n, -y_n);
  [l4, u4] = deal (-u4, -l4);

  l = min (min (l1, l2), min (l3, l4));
  u = max (max (u1, u2), max (u3, u4));

  warning ("off", "interval:UndefinedOperation", "local");
  result = infsup (l, u);

  d = min (min (d1, d2), min (d3, d4));

endfunction

function [l, u, d] = rem_quadrant_I (x, y)

  ## Compute fractions x ./ y at three corners of the interval box to detect
  ## cases with y = x ./ n inside the area, where the function is noncontinuous
  ## and takes extreme values.
  ##
  ##   ^ y                .* y = x / 1
  ##   |                .*
  ##   |     q--------.*-r
  ##   |     |      .*   |
  ##   |     +----.*-----s   y = x / 2
  ##   |        .*       ..**
  ##   |      .*     ..**
  ##   |    .*   ..**
  ##   |  .* ..**
  ##   |.*.**     (and so on)
  ##   +---------------------> x
  q = mpfr_function_d ("rdivide", -inf, x.inf, y.sup);
  r = mpfr_function_d ("rdivide", +inf, x.sup, y.sup);
  s = mpfr_function_d ("rdivide", +inf, x.sup, y.inf);

  ## Fix limit values for corner cases
  unbound_x_idx = (x.sup == inf & true (size (y.sup)));
  r(unbound_x_idx) = s(unbound_x_idx) = inf;
  div_by_zero_idx = (y.inf == 0 & true (size (x.sup)));
  s(div_by_zero_idx) = inf;

  # Cases where rem (x, y) == 0
  q_zero_idx = (q == fix (q) & (q >= 1 | x.sup == 0) & q < inf);
  s_zero_idx = (s == fix (s) & s >= 1);
  inner_zero_idx = (q < s & ceil (q) <= floor (s) & s >= 1);
  zero_idx = (q_zero_idx | s_zero_idx | inner_zero_idx);

  l = u = zeros (size (q));
  d = _com ()(ones (size (q)));
  d(s_zero_idx | (q_zero_idx & q > 1)) = _dac ();
  d(inner_zero_idx) = _def ();
  d(div_by_zero_idx) = _trv ();


  ## If the interval box contains no cases with y = x ./ n, the minimum is
  ## located at (x.inf, y.sup).  Otherwise the minimum is zero.
  select = not (zero_idx);
  l(select) = mpfr_function_d ("rem", -inf, x.inf(select), y.sup(select));

  ## Consider the maximum for y = x ./ n, with the smallest such n.
  q(q_zero_idx) = mpfr_function_d ("plus", -inf, q(q_zero_idx), 1);
  q = ceil (q);

  ## Case 1: y > x
  select = (q <= 0);
  u(select) = min (y.sup (select), x.sup(select));

  ## Case 2: y.sup = x ./ n
  select = ((q > 0) & (q <= r));
  u(select) = y.sup(select);

  ## Case 3: y = x.sup ./ n
  select = ((q > r) & (q <= s));
  u(select) = mpfr_function_d ("rdivide", +inf, x.sup(select), q(select));

  ## Case 4: The maximum is located at (x.sup, y.inf)
  select = (q > s);
  u(select) = mpfr_function_d ("rem", +inf, x.sup(select), y.inf(select));

  empty_result_idx = x.sup < 0 | y.sup <= 0;
  l(empty_result_idx) = inf;
  u(empty_result_idx) = -inf;

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

%!assert (rem (infsup (), infsup ()) == infsup ());
%!assert (rem (infsup (0), infsup ()) == infsup ());
%!assert (rem (infsup (), infsup (0)) == infsup ());

%!assert (rem (infsup (0), infsup (0)) == infsup ());
%!assert (rem (infsup (1), infsup (0)) == infsup ());
%!assert (rem (infsup (0, 1), infsup (0)) == infsup ());
%!assert (rem (infsup (1, 2), infsup (0)) == infsup ());
%!assert (rem (infsup (0, inf), infsup (0)) == infsup ());
%!assert (rem (infsup (1, inf), infsup (0)) == infsup ());
%!assert (rem (infsup (realmax, inf), infsup (0)) == infsup ());

%!assert (rem (infsup (0), infsup (1)) == infsup (0));
%!assert (rem (infsup (0), infsup (0, 1)) == infsup (0));
%!assert (rem (infsup (0), infsup (1, 2)) == infsup (0));
%!assert (rem (infsup (0), infsup (0, inf)) == infsup (0));
%!assert (rem (infsup (0), infsup (1, inf)) == infsup (0));
%!assert (rem (infsup (0), infsup (realmax, inf)) == infsup (0));

%!assert (rem (infsup (1), infsup (1)) == infsup (0));
%!assert (rem (infsup (2), infsup (1)) == infsup (0));
%!assert (rem (infsup (4), infsup (2)) == infsup (0));
%!assert (rem (infsup (6), infsup (3)) == infsup (0));
%!assert (rem (infsup (8), infsup (2)) == infsup (0));
%!assert (rem (infsup (9), infsup (3)) == infsup (0));
%!assert (rem (infsup (realmax), infsup (realmax)) == infsup (0));
%!assert (rem (infsup (realmax), infsup (realmax / 2)) == infsup (0));
%!assert (rem (infsup (realmax), infsup (realmax / 4)) == infsup (0));
%!assert (rem (infsup (realmax), infsup (realmax / 8)) == infsup (0));
%!assert (rem (infsup (realmax), infsup (realmax / 16)) == infsup (0));
%!assert (rem (infsup (realmax), infsup (realmax / 32)) == infsup (0));

%!assert (rem (infsup (0.1), infsup (0.1)) == infsup (0));
%!assert (rem (infsup (0.1 * 2), infsup (0.1)) == infsup (0));
%!assert (rem (infsup (0.1 * 4), infsup (0.1)) == infsup (0));
%!assert (rem (infsup (pi), infsup (pi)) == infsup (0));
%!assert (rem (infsup (pi), infsup (pi / 2)) == infsup (0));
%!assert (rem (infsup (pi), infsup (pi / 4)) == infsup (0));

%!assert (rem (infsup (pow2 (-1074)), infsup (pow2 (-1074))) == infsup (0));
%!assert (rem (infsup (pow2 (-1073)), infsup (pow2 (-1074))) == infsup (0));
%!assert (rem (infsup (pow2 (-1072)), infsup (pow2 (-1074))) == infsup (0));

%!assert (rem (infsup (1), infsup (2)) == infsup (1));
%!assert (rem (infsup (0.5), infsup (1)) == infsup (0.5));
%!assert (rem (infsup (pi), infsup (3.15)) == infsup (pi));

%!assert (rem (infsup (1), infsup (2, 3)) == infsup (1));
%!assert (rem (infsup (1), infsup (2, inf)) == infsup (1));
%!assert (rem (infsup (0.5), infsup (1, 2)) == infsup (0.5));
%!assert (rem (infsup (0.5), infsup (1, inf)) == infsup (0.5));
%!assert (rem (infsup (pi), infsup (3.15)) == infsup (pi));
%!assert (rem (infsup (pi), infsup (3.15, inf)) == infsup (pi));

%!assert (rem (infsup (0, 1), infsup (0, 1)) == infsup (0, 1));
%!assert (rem (infsup (0, 2), infsup (0, 1)) == infsup (0, 1));
%!assert (rem (infsup (0, 1), infsup (0, 2)) == infsup (0, 1));
%!assert (rem (infsup (0, realmax), infsup (0, realmax)) == infsup (0, realmax));
%!assert (rem (infsup (realmax, inf), infsup (realmax, inf)) == infsup (0, inf));
%!assert (rem (infsup (0, inf), infsup (0, inf)) == infsup (0, inf));

%!assert (rem (infsup (0), infsup (1)) == infsup (0));
%!assert (rem (infsup (1), infsup (1)) == infsup (0));
%!assert (rem (infsup (0, 1), infsup (1)) == infsup (0, 1));
%!assert (rem (infsup (1, 2), infsup (1)) == infsup (0, 1));
%!assert (rem (infsup (0, inf), infsup (1)) == infsup (0, 1));
%!assert (rem (infsup (1, inf), infsup (1)) == infsup (0, 1));
%!assert (rem (infsup (realmax, inf), infsup (1)) == infsup (0, 1));

%!assert (rem (infsup (1), infsup (1)) == infsup (0));
%!assert (rem (infsup (1), infsup (0, 1)) == infsup (0, 0.5));
%!assert (rem (infsup (1), infsup (1, 2)) == infsup (0, 1));
%!assert (rem (infsup (1), infsup (0, inf)) == infsup (0, 1));
%!assert (rem (infsup (1), infsup (1, inf)) == infsup (0, 1));
%!assert (rem (infsup (1), infsup (2, inf)) == infsup (1));
%!assert (rem (infsup (1), infsup (realmax, inf)) == infsup (1));
