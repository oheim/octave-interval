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
## @deftypefn {Interval Function} {@var{Y} =} powrev2 (@var{A}, @var{C}, @var{Y})
## @deftypefnx {Interval Function} {@var{Y} =} powrev2 (@var{A}, @var{C})
## @cindex IEEE1788 powRev2
## 
## Compute the reverse power function with
## @code{pow (@var{A}, @var{Y}) = @var{C}}.
##
## Accuracy: The result is a valid enclosure.
##
## @example
## @group
## powrev2 (infsup (2, 5), infsup (3, 6))
##   @result{} [.6826061944859851, 2.584962500721157]
## @end group
## @end example
## @seealso{pow}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2011

function result = powrev2 (a, c, y)

assert (nargin >= 2)

if (nargin < 3)
    y = infsup (-inf, inf);
endif

## Convert first parameter into interval, if necessary
if (not (isa (a, "infsup")))
    a = infsup (a);
endif

## Convert second parameter into interval, if necessary
if (not (isa (c, "infsup")))
    c = infsup (c);
endif

## Convert third parameter into interval, if necessary
if (not (isa (y, "infsup")))
    y = infsup (y);
endif

if (isempty (y) || isempty (a) || isempty (c) || a.sup <= 0 || c.sup <= 0)
    result = infsup ();
    return
endif

## Implements Table B.2 in
## Heimlich, Oliver. 2011. “The General Interval Power Function.”
## Diplomarbeit, Institute for Computer Science, University of Würzburg.
## http://exp.ln0.de/heimlich-power-2011.htm.

switch [overlap(c, infsup (0, 1)) '-' overlap(a, infsup (0, 1))]
    case {'overlaps-overlaps', ...
          'overlaps-starts', ...
          'overlaps-equal', ...
          'overlaps-finishedBy', ...
          'starts-overlaps', ...
          'starts-starts', ...
          'starts-equal', ...
          'starts-finishedBy', ...
          'containedBy-equal', ...
          'containedBy-finishedBy'}
        if (y.sup <= 0)
            result = infsup ();
        else
            result = y & infsup (0, inf);
        endif
    case {'overlaps-containedBy', ...
          'starts-containedBy'}
        if (y.sup <= 0)
            result = infsup ();
        else
            result = y & infsup (powrev2rounded (a.inf, c.sup, -inf), inf);
        endif
    case {'overlaps-finishes', ...
          'starts-finishes', ...
          'containedBy-finishes'}
        if (a.inf < 1 && y.sup > 0)
            result = y & infsup (powrev2rounded (a.inf, c.sup, -inf), inf);
        else
            result = infsup ();
        endif
    case {'overlaps-contains', ...
          'overlaps-startedBy', ...
          'starts-contains', ...
          'starts-startedBy', ...
          'containedBy-contains', ...
          'containedBy-startedBy'}
        result = y & infsup (-inf, powrev2rounded (a.sup, c.sup, inf));
        if (y.sup > 0)
            result = result | (y & infsup (0, inf));
        endif
    case {'overlaps-overlappedBy', ...
          'starts-overlappedBy', ...
          'containedBy-overlappedBy'}
        result = (y & infsup (-inf, powrev2rounded (a.sup, c.sup, inf))) | ...
                 (y & infsup (powrev2rounded (a.inf, c.sup, -inf), inf));
    case {'overlaps-metBy', ...
          'overlaps-after', ...
          'starts-metBy', ...
          'starts-after', ...
          'containedBy-metBy'}
        if (y.inf >= 0)
            result = infsup ();
        else
            result = y & infsup (-inf, powrev2rounded (a.sup, c.sup, inf));
        endif
    case {'containedBy-overlaps', ...
          'containedBy-starts'}
        if (y.sup <= 0)
            result = infsup ();
        else
            result = y & infsup (0, powrev2rounded (a.sup, c.inf, inf));
        endif
    case {'containedBy-containedBy'}
        if (y.sup <= 0)
            result = infsup ();
        else
            result = y & infsup (powrev2rounded (a.inf, c.sup, -inf), ...
                                 powrev2rounded (a.sup, c.inf, inf));
        endif
    case {'containedBy-after'}
        if (y.inf >= 0)
            result = infsup ();
        else
            result = y & infsup (powrev2rounded (a.inf, c.inf, -inf), ...
                                 powrev2rounded (a.sup, c.sup, inf));
        endif
    case {'finishes-overlaps', ...
          'finishes-starts', ...
          'finishes-containedBy'}
        result = y & infsup (0, powrev2rounded (a.sup, c.inf, inf));
    case {'finishes-finishes', ...
          'finishes-equal', ...
          'finishes-finishedBy', ...
          'finishes-contains', ...
          'finishes-startedBy', ...
          'finishes-overlappedBy', ...
          'finishes-metBy', ...
          'equal-finishes', ...
          'equal-equal', ...
          'equal-finishedBy', ...
          'equal-contains', ...
          'equal-startedBy', ...
          'equal-overlappedBy', ...
          'equal-metBy', ...
          'finishedBy-finishes', ...
          'finishedBy-equal', ...
          'finishedBy-finishedBy', ...
          'finishedBy-contains', ...
          'finishedBy-startedBy', ...
          'finishedBy-overlappedBy', ...
          'finishedBy-metBy', ...
          'contains-finishes', ...
          'contains-equal', ...
          'contains-finishedBy', ...
          'contains-contains', ...
          'contains-startedBy', ...
          'contains-overlappedBy', ...
          'contains-metBy', ...
          'startedBy-finishes', ...
          'startedBy-equal', ...
          'startedBy-finishedBy', ...
          'startedBy-contains', ...
          'startedBy-startedBy', ...
          'startedBy-overlappedBy', ...
          'startedBy-metBy', ...
          'overlappedBy-finishes', ...
          'overlappedBy-equal', ...
          'overlappedBy-finishedBy', ...
          'overlappedBy-contains', ...
          'overlappedBy-startedBy', ...
          'overlappedBy-overlappedBy', ...
          'overlappedBy-metBy', ...
          'metBy-finishes', ...
          'metBy-equal', ...
          'metBy-finishedBy', ...
          'metBy-contains', ...
          'metBy-startedBy', ...
          'metBy-overlappedBy', ...
          'metBy-metBy'}
        result = y;
    case {'finishes-after'}
        result = y & infsup (powrev2rounded (a.inf, c.inf, -inf), 0);
    case {'equal-overlaps', ...
          'equal-starts', ...
          'equal-containedBy', ...
          'finishedBy-overlaps', ...
          'finishedBy-starts', ...
          'finishedBy-containedBy'}
        result = y & infsup (0, inf);
    case {'equal-after', ...
          'finishedBy-after'}
        result = y & infsup (-inf, 0);
    case {'contains-overlaps', ...
          'contains-starts', ...
          'contains-containedBy', ...
          'startedBy-overlaps', ...
          'startedBy-starts', ...
          'startedBy-containedBy'}
        result = y & infsup (powrev2rounded (a.sup, c.sup, -inf), inf);
    case {'contains-after', ...
          'startedBy-after'}
        result = y & infsup (-inf, powrev2rounded (a.inf, c.sup, inf));
    case {'overlappedBy-overlaps', ...
          'overlappedBy-starts', ...
          'overlappedBy-containedBy'}
        result = y & infsup (powrev2rounded (a.sup, c.sup, -inf), ...
                             powrev2rounded (a.sup, c.inf, inf));
    case {'overlappedBy-after'}
        result = y & infsup (powrev2rounded (a.inf, c.inf, -inf), ...
                             powrev2rounded (a.inf, c.sup, inf));
    case {'metBy-overlaps', ...
          'metBy-starts', ...
          'metBy-containedBy'}
        result = y & infsup (powrev2rounded (a.sup, c.sup, -inf), 0);
    case {'metBy-after'}
        result = y & infsup (0, powrev2rounded (a.inf, c.sup, inf));
    case {'after-overlaps', ...
          'after-starts'}
        if (y.inf >= 0)
            result = infsup ();
        else
            result = y & infsup (powrev2rounded (a.sup, c.sup, -inf), 0);
        endif
    case {'after-containedBy'}
        if (y.inf >= 0)
            result = infsup ();
        else
            result = y & infsup (powrev2rounded (a.sup, c.sup, -inf), ...
                                 powrev2rounded (a.inf, c.inf, inf));
        endif
    case {'after-finishes'}
        if (a.inf < 1 && y.inf < 0)
            result = y & infsup (-inf, powrev2rounded (x.inf, z.inf, inf));
        else
            result = infsup ();
        endif
    case {'after-equal', ...
          'after-finishedBy'}
        if (y.inf >= 0)
            result = infsup ();
        else
            result = y & infsup (-inf, 0);
        endif
    case {'after-contains', ...
          'after-startedBy'}
        if (y.inf >= 0)
            result = infsup ();
        else
            result = y & infsup (-inf, 0);
        endif
        if (y.sup > 0)
            result = result | ...
                     (y & infsup (powrev2rounded (a.sup, c.inf, -inf), inf));
        endif
    case {'after-overlappedBy'}
        if (y.inf >= 0)
            result = infsup ();
        else
            result = y & infsup (-inf, powrev2rounded (a.inf, c.inf, inf));
        endif
        if (y.sup > 0)
            result = result | ...
                     (y & infsup (powrev2rounded (a.sup, c.inf, -inf), inf));
        endif
    case {'after-metBy'}
        if (y.sup <= 0)
            result = infsup ();
        else
            result = y & infsup (powrev2rounded (a.sup, c.inf, -inf), inf);
        endif
    case {'after-after'}
        if (y.sup <= 0)
            result = infsup ();
        else
            result = y & infsup (powrev2rounded (a.sup, c.inf, -inf), ...
                                 powrev2rounded (a.inf, c.sup, inf));
        endif
    otherwise
        assert (false);
endswitch
endfunction

function y = powrev2rounded(x, z, direction)
## Return y = log z / log x with directed rounding and limit values
if (x == inf)
    assert (isfinite (z));
    y = 0;
elseif (z == inf)
    assert (x ~= 1 && x > 0);
    if (x < 1)
        y = -inf;
    else
        y = inf;
    endif
else
    if (x == 2)
        y = log2 (infsup (z));
        if (direction > 0)
            y = y.sup;
        else
            y = y.inf;
        endif
    elseif (x == 10)
        y = log10 (infsup (z));
        if (direction > 0)
            y = y.sup;
        else
            y = y.inf;
        endif
    else
        d = log (x);
        n = log (z);
        if ((direction > 0) == (sign (d) == sign (n)))
            d = nextdown (d);
            n = nextup (n);
        else
            d = nextup (d);
            n = nextdown (n);
        endif
        fesetround (direction);
        y = n / d;
        fesetround (0.5);
    endif
endif
endfunction