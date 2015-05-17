## Copyright 2015 Oliver Heimlich
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
## @deftypefn {Function File} {} plot (@var{X}, @var{Y})
## @deftypefnx {Function File} {} plot (@var{Y})
## @deftypefnx {Function File} {} plot (@var{X}, @var{Y}, @var{COLOR})
## 
## Create a 2D-plot of intervals.
##
## If either of @var{X} or @var{Y} is an empty interval, nothing is plotted.
## If both @var{X} and @var{Y} are singleton intervals, a single point is
## plotted.  If only one of @var{X} and @var{Y} is a singleton interval, a
## single line is plotted.  If neither of @var{X} and @var{Y} is a singleton
## interval, a filled rectangle is plotted.
##
## If @var{X} or @var{Y} are matrices, each pair of elements is plotted
## separately.  No connection of the interval areas is plotted, because that
## kind of interpolation would be wrong in general (in the sense that the
## actual values are enclosed by the plot).
##
## Without parameter @var{X}, the intervals in @var{Y} are plotted as points or
## lines, which are parallel to the y axis, at the coordinates
## @code{@var{X} = [1, …, n]}.
##
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2015-05-10

function plot (x, y, color)

if (nargin > 3)
    print_usage ();
    return
endif

warning ("off", "interval:ImplicitPromote", "local");
if (not (isa (x, "infsupdec")))
    x = infsupdec (x);
endif
if (nargin >= 2 && not (isa (y, "infsupdec")))
    y = infsupdec (y);
endif

if (isnai (x) || (nargin >= 2 && isnai (y)))
    error ("interval:NaI", "Cannot plot NaIs");
    return
endif

if (nargin < 2)
    y = x;
    ## x = 1 ... n
    x = infsupdec (reshape (1 : numel (y.inf), size (y.inf)));
endif

if (nargin < 3)
    color = 'b';
endif

oldhold = ishold ();
if (not (oldhold))
    clf
    hold on
endif

unwind_protect

    empty = isempty (x) | isempty (y);
    points = issingleton (x) & issingleton (y);
    lines = xor (issingleton (x), issingleton (y)) & not (empty);
    boxes = not (points | lines | empty);
    
    arrayfun (@(x, y) plot (x, y, color), x.inf (points), y.inf (points));
    
    x_line = [vec(x.inf (lines)), vec(x.sup (lines))]';
    y_line = [vec(y.inf (lines)), vec(y.sup (lines))]';
    plot (x_line, y_line, color, 'linewidth', 2, 'color', color);
    
    x_box = [vec(x.inf (boxes)), vec(x.sup (boxes))] (:, [1 2 2 1])';
    y_box = [vec(y.inf (boxes)), vec(y.sup (boxes))] (:, [1 1 2 2])';
    fill (x_box, y_box, color, 'linewidth', 0, 'edgecolor', color);

unwind_protect_cleanup
    ## Reset hold state
    if (not (oldhold))
        hold off
    endif
end_unwind_protect

endfunction

%!test
%!  clf
%!  hold on
%!  plot (infsup (0), infsup (0));
%!  plot (infsup (1, 2), infsup (0));
%!  plot (infsup (0), infsup (1, 2));
%!  plot (infsup (1, 2), infsup (1, 2));
%!  axis ([-.5, 2.5, -.5, 2.5]);
%!  hold off
%!  close

%!test
%!  clf
%!  plot (infsup (-rand (50, 1), +rand (50, 1)));
%!  close

%!demo
%!  clf
%!  hold on
%!  axis off
%!  range = infsup (0, 9);
%!  x = linspace (inf (range), sup (range), 250);
%!  X = infsup (inf (range) : sup (range) - 1, ...
%!              inf (range) + 1 : sup (range));
%!  f = @ (x) 0.5 * sin (x) .* x .^ 2;
%!  y = f (x);
%!  Y = f (X);
%!  plot (range, f (range), [42 161 152]/255);
%!  plot (X, Y, [238 232 213]/255);
%!  plot (x, y, 'color', [220 50 47]/255, 'linewidth', 2);
%!  hold off
