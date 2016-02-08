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
## @documentencoding utf-8
## @defun ctc_union (@var{C1}, @var{Y1}, @var{C2}, @var{Y2})
## @defunx ctc_union (@var{C1}, @var{C2})
##
## Return a contractor function for the union of two sets.
##
## Functions @var{C1} and @var{C2} define two sets @code{S1 = @{@var{x} |
## @var{C1} (@var{x}) ∈ @var{Y1}@}} and @code{S2 = @{@var{x} |
## @var{C2} (@var{x}) ∈ @var{Y2}@}}.  The return value is a contractor function
## for the set @code{S1 ∪ S2 = @{@var{x} | @var{C1} (@var{x}) ∈ @var{Y1} or
## @var{C2} (@var{x}) ∈ @var{Y2}@}}.
##
## Parameters @var{C1} and @var{C2} must be function handles and must accept
## the same number of parameters.  See @command{@@infsup/fsolve} for how to
## define contractor functions.  The user manual also contains an example on
## how to use this function.
##
## Instead of solving @code{@var{C1} (@var{x}) ∈ @var{Y1}} and
## @code{@var{C2} (@var{x}) ∈ @var{Y2}} separately and then compute an union of
## the result, you can solve @code{ctc_union (@var{C1}, @var{Y1}, @var{C2},
## @var{Y2}) = 0}.
##
## @seealso{@@infsup/fsolve, ctc_intersect}
## @end defun

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2015-12-20

function c = ctc_union (ctc1, y1, ctc2, y2)

## Reorder parameters
switch (nargin)
    case 2
        ctc2 = y1;
        y1 = y2 = 0;
    case 3
        if (is_function_handle (y1))
            y2 = ctc2;
            ctc2 = y1;
            y1 = 0;
        else
            y2 = 0;
        endif
    case 4
        ...
    otherwise
        print_usage ();
endswitch

## Check parameters
if (not (isa (y1, "infsup")))
    y1 = infsup (y1);
endif
if (not (isa (y2, "infsup")))
    y2 = infsup (y2);
endif

if (not (is_function_handle (ctc1)) && not (ischar (ctc1)))
    error ("interval:InvalidOperand", ...
           "ctc_union: Parameter C1 is no function handle")
endif
if (not (is_function_handle (ctc2)) && not (ischar (ctc2)))
    error ("interval:InvalidOperand", ...
           "ctc_union: Parameter C2 is no function handle")
endif

c = @(varargin) ctc_union_eval (ctc1, y1, ctc2, y2, varargin{:});

endfunction


function varargout = ctc_union_eval (ctc1, y1, ctc2, y2, varargin)

y = varargin{1};
x = varargin(2 : end);

## Evaluate each contractor function
fval_and_contractions1 = nthargout (1 : nargout, ctc1, y1, x{:});
fval_and_contractions2 = nthargout (1 : nargout, ctc2, y2, x{:});

## Compute fval = y if either function value is inside of its constraints
fval1 = fval_and_contractions1{1};
fval2 = fval_and_contractions2{1};
fval1 = y + y_dist (y1, fval1);
fval2 = y + y_dist (y2, fval2);
varargout{1} = union (fval1, fval2);
## It suffices, if one contractor is a subset of y.
varargout{1}(fval1 == y | fval2 == y) = y;

## Unite the contractions
for i = 2 : nargout
    varargout{i} = union (fval_and_contractions1{i}, ...
                          fval_and_contractions2{i});
endfor

endfunction


function d = y_dist (y, fval)
d = infsup (idist (y, fval), hdist (y, fval));
d(subset (fval, y) & not (isempty (fval))) = 0;
if (columns (y) == 1)
    d = sum (d, 1);
elseif (rows (y) == 1)
    d = sum (d, 2);
else
    d = sum (sum (d));
endif
endfunction

%!function [fval, cx] = ctc_sin (y, x)
%!  fval = sin (x);
%!  y = intersect (y, fval);
%!  cx = sinrev (y, x);
%!endfunction
%!function [fval, cx] = ctc_cos (y, x)
%!  fval = cos (x);
%!  y = intersect (y, fval);
%!  cx = cosrev (y, x);
%!endfunction
%!shared c
%!  c = ctc_union (@ctc_sin, 0, @ctc_cos, 0);
%!test
%!  x = infsup (0);
%!  y = infsup (0);
%!  [fval, cx] = c (y, x);
%!  assert (fval == 0);
%!  assert (cx == 0)
%!test
%!  x = infsup ("pi") / 2;
%!  y = infsup (0);
%!  [fval, cx] = c (y, x);
%!  assert (fval == "[0, 1]");
%!  assert (cx == x);
%!test
%!  x = infsup ("pi") / 4;
%!  y = infsup (0);
%!  [fval, cx] = c (y, x);
%!  assert (fval > 0);
%!  assert (isempty (cx));
%!test
%!  x = infsup (0, eps);
%!  y = infsup (0);
%!  [fval, cx] = c (y, x);
%!  assert (fval == "[0, 1]");
%!  assert (cx == 0);
%!test
%!  x = infsup ("[0, pi]") / 2;
%!  y = infsup (0);
%!  [fval, cx] = c (y, x);
%!  assert (fval == "[0, 1]");
%!  assert (cx == x);
