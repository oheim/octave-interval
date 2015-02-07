## Copyright 2014 Oliver Heimlich
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
## @documentencoding utf-8
## @deftypefn {Function File} {@var{X} =} mulrev (@var{B}, @var{C}, @var{X})
## @deftypefnx {Function File} {@var{X} =} mulrev (@var{B}, @var{C})
## @deftypefnx {Function File} {[@var{U}, @var{V}] =} mulrev (@var{B}, @var{C})
## @deftypefnx {Function File} {[@var{U}, @var{V}] =} mulrev (@var{B}, @var{C}, @var{X})
## 
## Compute the reverse multiplication function or the two-output division.
##
## That is, an enclosure of all @code{x ∈ @var{X}} where
## @code{x .* b ∈ @var{C}} for any @code{b ∈ @var{B}}.
##
## This function is similar to interval division @code{@var{C} ./ @var{B}}.
## However, it treats the case 0/0 as “any real number” instead of “undefined”.
##
## Interval division, considered as a set, can have zero, one or two disjoint
## connected components as a result.  If called with two output parameters,
## this function returns the components separately.  @var{U} contains the
## negative or unique component, whereas @var{V} contains the positive
## component in cases with two components.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## c = infsup (1);
## b = infsup (-inf, inf);
## [u, v] = mulrev (b, c)
##   @result{} [-Inf, 0]
##   @result{} [0, Inf]
## @end group
## @end example
## @seealso{@@infsup/times}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-13

function [u, v] = mulrev (b, c, x)

if (nargin < 2 || nargin > 3)
    print_usage ();
    return
endif
if (nargin < 3)
    x = infsup (-inf, inf);
endif
if (not (isa (b, "infsup")))
    b = infsup (b);
endif
if (not (isa (c, "infsup")))
    c = infsup (c);
endif
if (not (isa (x, "infsup")))
    x = infsup (x);
endif

## Resize, if scalar × matrix
if (isscalar (b.inf) ~= isscalar (c.inf))
    b.inf = ones (size (c.inf)) .* b.inf;
    b.sup = ones (size (c.inf)) .* b.sup;
    c.inf = ones (size (b.inf)) .* c.inf;
    c.sup = ones (size (b.inf)) .* c.sup;
endif

u.inf = v.inf = inf (size (b.inf));
u.sup = v.sup = -inf (size (b.inf));

emptyresult = isempty (b) | isempty (c) ...
            | (eq (0, b) & not (ismember (0, c))); # x * 0 ~= 0
twocomponents = interior (0, b) & not (emptyresult) & not (ismember (0, c));
onecomponent = not (twocomponents) & not (emptyresult);

u.inf (twocomponents) = -inf;
v.sup (twocomponents) = inf;
dom = twocomponents & ismember (0, c);
u.sup (dom) = v.inf (dom) = 0;
dom = twocomponents & (c > 0);
u.sup (dom) = mpfr_function_d ('rdivide', +inf, c.inf (dom), b.inf (dom));
v.inf (dom) = mpfr_function_d ('rdivide', -inf, c.inf (dom), b.sup (dom));
dom = twocomponents & (c < 0);
u.sup (dom) = mpfr_function_d ('rdivide', +inf, c.sup (dom), b.sup (dom));
v.inf (dom) = mpfr_function_d ('rdivide', -inf, c.sup (dom), b.inf (dom));

dom = onecomponent & (b >= 0) & (c >= 0);
b.inf (dom) = abs (b.inf);
c.inf (dom) = abs (c.inf);
u.inf (dom) = mpfr_function_d ('rdivide', -inf, c.inf (dom), b.sup (dom));
u.sup (dom) = mpfr_function_d ('rdivide', +inf, c.sup (dom), b.inf (dom));
dom = onecomponent & (b <= 0) & (c >= 0);
b.sup (dom) = -abs (b.sup);
c.inf (dom) = abs (c.inf);
u.inf (dom) = mpfr_function_d ('rdivide', -inf, c.sup (dom), b.sup (dom));
u.sup (dom) = mpfr_function_d ('rdivide', +inf, c.inf (dom), b.inf (dom));
dom = onecomponent & (b >= 0) & (c <= 0);
b.inf (dom) = abs (b.inf);
c.sup (dom) = -abs (c.sup);
u.inf (dom) = mpfr_function_d ('rdivide', -inf, c.inf (dom), b.inf (dom));
u.sup (dom) = mpfr_function_d ('rdivide', +inf, c.sup (dom), b.sup (dom));
dom = onecomponent & (b <= 0) & (c <= 0);
b.sup (dom) = -abs (b.sup);
c.sup (dom) = -abs (c.sup);
u.inf (dom) = mpfr_function_d ('rdivide', -inf, c.sup (dom), b.inf (dom));
u.sup (dom) = mpfr_function_d ('rdivide', +inf, c.inf (dom), b.sup (dom));
dom = onecomponent & interior (0, c) & (b > 0);
u.inf (dom) = mpfr_function_d ('rdivide', -inf, c.inf (dom), b.inf (dom));
u.sup (dom) = mpfr_function_d ('rdivide', +inf, c.sup (dom), b.inf (dom));
dom = onecomponent & interior (0, c) & (b < 0);
u.inf (dom) = mpfr_function_d ('rdivide', -inf, c.sup (dom), b.sup (dom));
u.sup (dom) = mpfr_function_d ('rdivide', +inf, c.inf (dom), b.sup (dom));
dom = onecomponent & ismember (0, b) & ismember (0, c); # x * 0 == 0
u.inf (dom) = -inf;
u.sup (dom) = inf;

u = x & infsup (u.inf, u.sup);
v = x & infsup (v.inf, v.sup);

if (nargout < 2)
    u.inf (twocomponents) = min (u.inf (twocomponents), v.inf (twocomponents));
    u.sup (twocomponents) = max (u.sup (twocomponents), v.sup (twocomponents));
else
    ## It can happen that the twocomponents result has only one component,
    ## because x is positive for example.  Then, only one component shall be
    ## returned
    swap = twocomponents & isempty (u) & not (isempty (v));
    [u.inf(swap), u.sup(swap), v.inf(swap), v.sup(swap)] = deal (...
        v.inf (swap), v.sup (swap), u.inf (swap), u.sup (swap));
endif

endfunction

%!test "IEEE 1788 mulRevToPair examples";
%!  [u, v] = mulrev (infsup (0), infsup (1, 2));
%!  assert (isempty (u) & isempty (v));
%!  [u, v] = mulrev (infsup (0), infsup (0, 1));
%!  assert (isentire (u) & isempty (v));
%!  [u, v] = mulrev (infsup (1), infsup (1, 2));
%!  assert (eq (u, infsup (1, 2)) & isempty (v));
%!  [u, v] = mulrev (infsup (1, inf), infsup (1));
%!  assert (eq (u, infsup (0, 1)) & isempty (v));
%!  [u, v] = mulrev (infsup (-1, 1), infsup (1, 2));
%!  assert (eq (u, infsup (-inf, -1)) & eq (v, infsup (1, inf)));
%!  [u, v] = mulrev (infsup (-inf, inf), infsup (1));
%!  assert (eq (u, infsup (-inf, 0)) & eq (v, infsup (0, inf)));
