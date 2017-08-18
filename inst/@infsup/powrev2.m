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
## @deftypemethod {@@infsup} {@var{Y} =} powrev2 (@var{A}, @var{C}, @var{Y})
## @deftypemethodx {@@infsup} {@var{Y} =} powrev2 (@var{A}, @var{C})
##
## Compute the reverse power function for the second parameter.
##
## That is, an enclosure of all @code{y ∈ @var{Y}} where
## @code{pow (a, y) ∈ @var{C}} for any @code{a ∈ @var{A}}.
##
## Accuracy: The result is a valid enclosure.
##
## @example
## @group
## powrev2 (infsup (2, 5), infsup (3, 6))
##   @result{} ans ⊂ [0.6826, 2.585]
## @end group
## @end example
## @seealso{@@infsup/pow}
## @end deftypemethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2011

function y = powrev2 (a, c, y)

  if (nargin < 2 || nargin > 3)
    print_usage ();
    return
  endif
  if (nargin < 3)
    y = infsup (-inf, inf);
  endif
  if (not (isa (a, "infsup")))
    a = infsup (a);
  endif
  if (not (isa (c, "infsup")))
    c = infsup (c);
  endif
  if (not (isa (y, "infsup")))
    y = infsup (y);
  endif

  a = intersect (a, infsup (0, inf));
  c = intersect (c, infsup (0, inf));

  ## Resize, if broadcasting is needed
  if (not (size_equal (a.inf, c.inf)))
    a.inf = ones (size (c.inf)) .* a.inf;
    a.sup = ones (size (c.inf)) .* a.sup;
    c.inf = ones (size (a.inf)) .* c.inf;
    c.sup = ones (size (a.inf)) .* c.sup;
  endif
  if (not (size_equal (a.inf, y.inf)))
    a.inf = ones (size (y.inf)) .* a.inf;
    a.sup = ones (size (y.inf)) .* a.sup;
    c.inf = ones (size (y.inf)) .* c.inf;
    c.sup = ones (size (y.inf)) .* c.sup;
    y.inf = ones (size (a.inf)) .* y.inf;
    y.sup = ones (size (a.inf)) .* y.sup;
  endif

  l = y.inf;
  u = y.sup;
  emptyresult = isempty (a) | isempty (c) ...
                | (a.sup == 0 & (y.sup <= 0 | c.inf > 0)) ...
                | (y.sup <= 0 & ((a.sup <= 1 & c.sup < 1) | ...
                                 (a.inf > 1 & c.inf > 1))) ...
                | (y.inf >= 0 & ((a.sup <= 1 & c.inf > 1) | ...
                                 (a.inf > 1 & c.sup < 1))) ...
                | (((a.inf == 1 & a.sup == 1) | (y.inf == 0 & y.sup == 0)) ...
                   & (c.sup < 1 | c.inf > 1));
  l(emptyresult) = inf;
  u(emptyresult) = -inf;

  ## Implements Table B.2 in
  ## Heimlich, Oliver. 2011. “The General Interval Power Function.”
  ## Diplomarbeit, Institute for Computer Science, University of Würzburg.
  ## http://exp.ln0.de/heimlich-power-2011.htm.

  ## x overlaps/starts/containedBy [0, 1] ======================================
  x = a.sup < 1;

  select = a.sup == 0 & l < 0;
  l(select) = 0;

  z = c.sup <= 1;
  select = x & z & (a.inf == 0 | c.sup == 1) & l < 0;
  l(select) = 0;

  z = c.sup > 1 & c.sup < inf;
  select = x & z & l < 0;
  if (any (select(:)))
    l(select) = max (l(select), ...
                     powrev2rounded (a.sup(select), c.sup(select), -inf));
  endif

  z = c.inf >= 1;
  select = x & z & (a.inf == 0 | c.inf == 1) & u > 0;
  u(select) = 0;

  z = c.inf > 0 & c.inf < 1;
  select = x & z & u > 0;
  if (any (select(:)))
    u (select) = min (u (select), powrev2rounded (a.sup, c.inf, +inf)(select));
  endif

  ## x containedBy/finishes [0, 1] =============================================
  x = a.inf > 0 & a.inf < 1 & a.sup <= 1;

  z = c.sup < 1 & c.sup > 0;
  select = x & z & l < inf;
  if (any (select(:)))
    l(select) = max (l(select), ...
                     powrev2rounded (a.inf(select), c.sup(select), -inf));
  endif

  z = c.inf > 1 & c.sup < inf;
  select = x & z & u > -inf;
  if (any (select(:)))
    u(select) = min (u(select), ...
                     powrev2rounded (a.inf(select), c.inf (select), +inf));
  endif

  ## ismember (1, x) ===========================================================
  x = a.sup >= 1 & a.inf <= 1;

  z = c.inf == 0 & c.sup == 0;
  select = x & z & l < 0;
  l(select) = 0;

  z = c.sup == inf & c.inf > 1;
  select = x & z & u > 0 & a.sup <= 1;
  u(select) = 0;

  gap.inf = -inf (size (l));
  gap.sup = +inf (size (u));

  z = c.sup < 1;
  select = x & z & a.inf == 0;
  gap.sup(select) = 0;
  select = x & z & a.sup > 1;
  if (any (select(:)))
    gap.inf(select) = powrev2rounded (a.sup(select), c.sup(select), +inf);
  endif
  select = x & z & a.inf > 0 & a.inf < 1 & a.sup > 1;
  if (any (select(:)))
    gap.sup(select) = powrev2rounded(a.inf(select), c.sup(select), -inf);
  endif

  z = c.inf > 1;
  select = x & z & a.inf == 0;
  gap.inf(select) = 0;
  select = x & z & a.sup > 1;
  if (any (select(:)))
    gap.sup(select) = powrev2rounded (a.sup(select), c.inf(select), -inf);
  endif
  select = x & z & a.inf > 0 & a.inf < 1 & a.sup > 1;
  if (any (select(:)))
    gap.inf(select) = powrev2rounded (a.inf(select), c.inf(select), +inf);
  endif

  z = c.sup < 1 | c.inf > 1;
  select = x & z & (l > gap.inf | gap.inf == -inf | (gap.inf == 0 & l == 0)) ...
           & (a.inf >= 1 | a.sup > 1 | a.inf <= 0);
  l(select) = max (l(select), gap.sup(select));
  select = x & z & (u < gap.sup | gap.sup == inf | (gap.sup == 0 & u == 0)) ...
           & (a.inf >= 1 | a.sup > 1 | a.inf <= 0);
  u(select) = min (u(select), gap.inf(select));

  ## x after [0, 1] ============================================================
  x = a.inf > 1;

  z = c.sup < 1;
  select = x & z & u > -inf;
  if (any (select(:)))
    u(select) = min (u(select), ...
                     powrev2rounded (a.sup(select), c.sup(select), +inf));
  endif

  z = c.inf > 0 & c.inf < 1;
  select = x & z & l < 0;
  if (any (select(:)))
    l(select) = max (l(select), ...
                     powrev2rounded (a.inf(select), c.inf(select), -inf));
  endif

  z = c.inf == 1;
  select = x & z & l < 0;
  l(select) = 0;

  z = c.inf > 1;
  select = x & z & l < inf;
  if (any (select(:)))
    l(select) = max (l(select), ...
                     powrev2rounded (a.sup(select), c.inf(select), -inf));
  endif

  z = c.sup == 1;
  select = x & z & u > 0;
  u(select) = 0;

  z = c.sup > 1 & c.sup < inf;
  select = x & z & u > 0;
  if (any (select(:)))
    u(select) = min (u(select), ...
                     powrev2rounded (a.inf(select), c.sup(select), +inf));
  endif

  ## ===========================================================================

  emptyresult = l > u | l == inf | u == -inf;
  l(emptyresult) = inf;
  u(emptyresult) = -inf;

  l(l == 0) = -0;

  y.inf = l;
  y.sup = u;

endfunction

function y = powrev2rounded (x, z, direction)
  ## Return y = log z / log x with directed rounding and limit values

  y = nominator = denominator = zeros (size (x));

  y(z == inf & x < 1) = -inf;
  y(z == inf & x > 1 & x < inf) = inf;

  ## We do not use log here, because log2 is able to produce some
  ## results without rounding errors.

  rnd_log_numerator_up = (direction > 0) == (sign (x - 1) == sign (z - 1));
  select = isfinite (x) & isfinite (z) & rnd_log_numerator_up;
  if (any (select(:)))
    denominator(select) = mpfr_function_d ('log2', -inf, x(select));
    nominator(select) = mpfr_function_d ('log2', +inf, z(select));
  endif
  select = isfinite (x) & isfinite (z) & not (rnd_log_numerator_up);
  if (any (select(:)))
    denominator(select) = mpfr_function_d ('log2', +inf, x(select));
    nominator(select) = mpfr_function_d ('log2', -inf, z(select));
  endif
  select = isfinite (x) & isfinite (z);
  if (any (select(:)))
    y(select) = mpfr_function_d ('rdivide', direction, ...
                                 nominator(select), ...
                                 denominator(select));
  endif

endfunction

%!# from the documentation string
%!assert (powrev2 (infsup (2, 5), infsup (3, 6)) == "[0x1.5D7E8F22BA886p-1, 0x1.4AE00D1CFDEB5p1]");

%!shared testdata
%! # Load compiled test data (from src/test/*.itl)
%! testdata = load (file_in_loadpath ("test/itl.mat"));

%!test
%! # Scalar evaluation
%! testcases = testdata.NoSignal.infsup.powRev2;
%! for testcase = [testcases]'
%!   assert (isequaln (...
%!     powrev2 (testcase.in{1}, testcase.in{2}, testcase.in{3}), ...
%!     testcase.out));
%! endfor

%!test
%! # Vector evaluation
%! testcases = testdata.NoSignal.infsup.powRev2;
%! in1 = vertcat (vertcat (testcases.in){:, 1});
%! in2 = vertcat (vertcat (testcases.in){:, 2});
%! in3 = vertcat (vertcat (testcases.in){:, 3});
%! out = vertcat (testcases.out);
%! assert (isequaln (powrev2 (in1, in2, in3), out));

%!test
%! # N-dimensional array evaluation
%! testcases = testdata.NoSignal.infsup.powRev2;
%! in1 = vertcat (vertcat (testcases.in){:, 1});
%! in2 = vertcat (vertcat (testcases.in){:, 2});
%! in3 = vertcat (vertcat (testcases.in){:, 3});
%! out = vertcat (testcases.out);
%! # Reshape data
%! i = -1;
%! do
%!   i = i + 1;
%!   testsize = factor (numel (in1) + i);
%! until (numel (testsize) > 2)
%! in1 = reshape ([in1; in1(1:i)], testsize);
%! in2 = reshape ([in2; in2(1:i)], testsize);
%! in3 = reshape ([in3; in3(1:i)], testsize);
%! out = reshape ([out; out(1:i)], testsize);
%! assert (isequaln (powrev2 (in1, in2, in3), out));
