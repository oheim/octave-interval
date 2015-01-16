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
## @deftypefn {Function File} {@var{X} =} powrev1 (@var{B}, @var{C}, @var{X})
## @deftypefnx {Function File} {@var{X} =} powrev1 (@var{B}, @var{C})
## 
## Compute the reverse power function with
## @code{pow (@var{X}, @var{B}) = @var{C}}.
##
## Accuracy: The result is a valid enclosure.
##
## @example
## @group
## powrev1 (infsup (2, 5), infsup (3, 6))
##   @result{} [1.2457309396155171, 2.4494897427831784]
## @end group
## @end example
## @seealso{pow}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2011

function result = powrev1 (b, c, x)

if (nargin < 2)
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

assert (isscalar (b) && isscalar (c) && isscalar (x), ...
        "only implemented for interval scalars");

if (isempty (x) || isempty (b) || isempty (c) || x.sup <= 0 || c.sup <= 0)
    result = infsup ();
    return
endif

## Implements Table B.1 in
## Heimlich, Oliver. 2011. “The General Interval Power Function.”
## Diplomarbeit, Institute for Computer Science, University of Würzburg.
## http://exp.ln0.de/heimlich-power-2011.htm.

switch [overlap(c, infsup (0, 1)) '-' overlap(b, infsup (0))]
    case {'overlaps-before', ...
          'starts-before', ...
          'overlaps-finishedBy', ...
          'starts-finishedBy', ...
          'containedBy-finishedBy'}
        result = x & infsup (powrev1rounded (c.sup, b.inf, -inf), inf);
    case {'overlaps-equal', ...
          'starts-equal', ...
          'containedBy-equal', ...
          'after-equal'}
        result = infsup ();
    case {'overlaps-contains', ...
          'starts-contains', ...
          'containedBy-contains'}
        if (x.inf >= 1)
            result = infsup ();
        else
            result = x & infsup (0, powrev1rounded (c.sup, b.sup, inf));
        endif
        if (x.sup > 1)
            result = result | ...
                     (x & infsup (powrev1rounded (c.sup, b.inf, -inf), inf));
        endif
    case {'overlaps-startedBy', ...
          'starts-startedBy', ...
          'overlaps-after', ...
          'starts-after', ...
          'containedBy-startedBy'}
        if (x.inf >= 1)
            result = infsup ();
        else
            result = x & infsup (0, powrev1rounded (c.sup, b.sup, inf));
        endif
    case {'containedBy-before'}
        if (x.sup <= 1)
            result = infsup ();
        else
            result = x & infsup (powrev1rounded (c.sup, b.inf, -inf), ...
                                 powrev1rounded (c.inf, b.sup, inf));
        endif
    case {'containedBy-after'}
        if (x.inf >= 1)
            result = infsup ();
        else
            result = x & infsup (powrev1rounded (c.inf, b.inf, -inf), ...
                                 powrev1rounded (c.sup, b.sup, inf));
        endif
    case {'finishes-before'}
        result = x & infsup (1, powrev1rounded (c.inf, b.sup, inf));
    case {'finishes-equal', ...
          'finishes-finishedBy', ...
          'finishes-contains', ...
          'finishes-startedBy', ...
          'equal-equal', ...
          'equal-finishedBy', ...
          'equal-contains', ...
          'equal-startedBy', ...
          'finishedBy-equal', ...
          'finishedBy-finishedBy', ...
          'finishedBy-contains', ...
          'finishedBy-startedBy', ...
          'contains-equal', ...
          'contains-finishedBy', ...
          'contains-contains', ...
          'contains-startedBy', ...
          'startedBy-equal', ...
          'startedBy-finishedBy', ...
          'startedBy-contains', ...
          'startedBy-startedBy', ...
          'overlappedBy-equal', ...
          'overlappedBy-finishedBy', ...
          'overlappedBy-contains', ...
          'overlappedBy-startedBy', ...
          'metBy-equal', ...
          'metBy-finishedBy', ...
          'metBy-contains', ...
          'metBy-startedBy'}
        result = x & infsup (0, inf);
    case {'finishes-after'}
        result = x & infsup (powrev1rounded (c.inf, b.inf, -inf), 1);
    case {'equal-before', ...
          'finishedBy-before'}
        result = x & infsup (1, inf);
    case {'equal-after', ...
          'finishedBy-after'}
        result = x & infsup (0, 1);
    case {'contains-before', ...
          'startedBy-before'}
        result = x & infsup (powrev1rounded (c.sup, b.sup, -inf), inf);
    case {'contains-after', ...
          'startedBy-after'}
        result = x & infsup (0, powrev1rounded (c.sup, b.inf, inf));
    case {'overlappedBy-before'}
        result = x & infsup (powrev1rounded (c.sup, b.sup, -inf), ...
                             powrev1rounded (c.inf, b.sup, inf));
    case {'overlappedBy-after'}
        result = x & infsup (powrev1rounded (c.inf, b.inf, -inf), ...
                             powrev1rounded (c.sup, b.inf, inf));
    case {'metBy-before'}
        result = x & infsup (powrev1rounded (c.sup, b.sup, -inf), 1);
    case {'metBy-after'}
        result = x & infsup (1, powrev1rounded (c.sup, b.inf, inf));
    case {'after-before'}
        result = x & infsup (powrev1rounded (c.sup, b.sup, -inf), ...
                             powrev1rounded (c.inf, b.inf, inf));
    case {'after-finishedBy'}
        if (x.inf >= 1)
            result = infsup ();
        else
            result = x & infsup (0, powrev1rounded (c.inf, b.inf, inf));
        endif
    case {'after-contains'}
        if (x.inf >= 1)
            result = infsup ();
        else
            result = x & infsup (0, powrev1rounded (c.inf, b.inf, inf));
        endif
        if (x.sup > 1)
            result = result | ...
                     (x & infsup (powrev1rounded (c.inf, b.sup, -inf), inf));
        endif
    case {'after-startedBy'}
        if (x.sup <= 1)
            result = infsup ();
        else
            result = x & infsup (powrev1rounded (c.inf, b.sup, -inf), inf);
        endif
    case {'after-after'}
        if (x.sup <= 1)
            result = infsup ();
        else
            result = x & infsup (powrev1rounded (c.inf, b.sup, -inf), ...
                                 powrev1rounded (c.sup, b.inf, inf));
        endif
    otherwise
        assert (false);
endswitch

endfunction

function x = powrev1rounded (z, y, direction)
## Return x = z ^ (1 / y) with directed rounding and limit values

if (not (isfinite (y)))
	assert (isfinite (z));
	x = 1;
elseif (z == inf)
	assert (isfinite (y) && y ~= 0);
	if (y < 0)
		x = 0;
	else
		x = inf;
	endif
elseif (z == 1)
    x = 1;
elseif (fix (y) == y)
    x = pownrev (infsup (z), infsup (0, inf), y);
    if (direction > 0)
        x = x.sup;
    else
        x = x.inf;
    endif
else
    if (z > 1)
        y = mpfr_function_d ('rdivide', direction, 1, y);
    else
        y = mpfr_function_d ('rdivide', -direction, 1, y);
    endif
    x = mpfr_function_d ('pow', direction, z, y);
endif
endfunction