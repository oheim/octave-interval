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
## @deftypefn {Function File} {} plot3 (@var{X}, @var{Y}, @var{Z})
## @deftypefnx {Function File} {} plot3 (@var{X}, @var{Y}, @var{Z}, @var{COLOR})
## 
## Create a 3D-plot of intervals.
##
## If either of @var{X}, @var{Y} or @var{Z} is an empty interval, nothing is
## plotted.  If all are singleton intervals, a single point is plotted.  If
## only two intervals are a singleton interval, a line is plotted.  If only one
## interval is a singleton interval, a rectangle is plotted.  If neither of
## @var{X}, @var{Y} and @var{Z} is a singleton interval, a cuboid is plotted.
##
## No connection of the interval areas is plotted, because that kind of
## interpolation would be wrong in general (in the sense that the actual values
## are enclosed by the plot).
##
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2015-05-17

function plot3 (x, y, z, color)

if (nargin > 4)
    print_usage ();
    return
endif

if (not (isa (x, "infsup")))
    x = infsup (x);
endif
if (not (isa (y, "infsup")))
    y = infsup (y);
endif
if (not (isa (z, "infsup")))
    z = infsup (z);
endif

if (nargin < 4)
    color = 'b';
endif

oldhold = ishold ();
if (not (oldhold))
    clf
    hold on
endif

unwind_protect

    empty = isempty (x) | isempty (y) | isempty (z);
    number_of_singletons = issingleton (x) + issingleton (y) + issingleton (z);
    points = number_of_singletons == 3;
    lines = number_of_singletons == 2 & not (empty);
    boxes = number_of_singletons <= 1 & not (empty);
    
    arrayfun (@(x, y, z) plot3 (x, y, z, 'marker', '.', 'color', color), ...
              x.inf (points), y.inf (points), z.inf (points));
    
    x_line = [vec(x.inf (lines)), vec(x.sup (lines))]';
    y_line = [vec(y.inf (lines)), vec(y.sup (lines))]';
    z_line = [vec(z.inf (lines)), vec(z.sup (lines))]';
    plot3 (x_line, y_line, z_line, 'linewidth', 2, 'color', color);
    
    vertices = [vec(x.inf (boxes)), ...
                vec(y.inf (boxes)), ...
                vec(z.inf (boxes)); ...

                vec(x.inf (boxes)), ...
                vec(y.inf (boxes)), ...
                vec(z.sup (boxes)); ...

                vec(x.inf (boxes)), ...
                vec(y.sup (boxes)), ...
                vec(z.inf (boxes)); ...

                vec(x.inf (boxes)), ...
                vec(y.sup (boxes)), ...
                vec(z.sup (boxes)); ...

                vec(x.sup (boxes)), ...
                vec(y.inf (boxes)), ...
                vec(z.inf (boxes)); ...

                vec(x.sup (boxes)), ...
                vec(y.inf (boxes)), ...
                vec(z.sup (boxes)); ...

                vec(x.sup (boxes)), ...
                vec(y.sup (boxes)), ...
                vec(z.inf (boxes)); ...

                vec(x.sup (boxes)), ...
                vec(y.sup (boxes)), ...
                vec(z.sup (boxes))];
    
    faces = zeros (0, 3);
    n = numel (boxes);
    
    ## x-y rectangle at z.inf
    select = vec (find (x.inf (boxes) < x.sup (boxes) & ...
                        y.inf (boxes) < y.sup (boxes)));
    faces = [faces; ...
             select, select+6*n, select+4*n; ...
             select, select+2*n, select+6*n];
    ## x-z rectangle at y.inf
    select = vec (find (x.inf (boxes) < x.sup (boxes) & ...
                        z.inf (boxes) < z.sup (boxes)));
    faces = [faces; ...
             select, select+4*n, select+5*n; ...
             select, select+5*n, select+n];
    ## y-z rectangle at x.inf
    select = vec (find (y.inf (boxes) < y.sup (boxes) & ...
                        z.inf (boxes) < z.sup (boxes)));
    faces = [faces; ...
             select, select+3*n, select+2*n; ...
             select, select+n, select+3*n];

    ## The cuboids have 6 sides instead of only one
    select = vec (find (x.inf (boxes) < x.sup (boxes) & ...
                        y.inf (boxes) < y.sup (boxes) & ...
                        z.inf (boxes) < z.sup (boxes)));
    faces = [faces; ...
             ## x-y rectangle at z.sup
             select+n, select+7*n, select+3*n; ...
             select+n, select+5*n, select+7*n; ...
             ## x-z rectangle at y.sup
             select+2*n, select+7*n, select+6*n; ...
             select+2*n, select+3*n, select+7*n; ...
             ## y-z rectangle at x.inf
             select+4*n, select+7*n, select+5*n; ...
             select+4*n, select+6*n, select+7*n];
    
    patch ('Vertices', vertices, 'Faces', faces, 'linewidth', 0, ...
           'edgecolor', color, 'facecolor', color);

unwind_protect_cleanup
    ## Reset hold state
    if (not (oldhold))
        hold off
    endif
end_unwind_protect

endfunction

%!test
%!  clf
%!  plot3 (infsup (0), infsup (0), infsup (0))
%!  close

%!demo
%!  clf
%!  hold on
%!  t = 0 : .1 : 10;
%!  x = infsup (sin (t)) + "0.01?";
%!  y = infsup (cos (t)) + "0.1?";
%!  z = infsup (t) + (infsup ("[-1, 1]") .* sin (t) .^ 2);
%!  plot3 (x, y, z, [38 139 210]/255);
%!  plot3 (infsup ("0?"), infsup ("0?"), infsup (-1, 9), [238 232 213]/255);
%!  plot3 (1.5, infsup ("[-1.5, 1.5]"), infsup (0, 10), [131 148 150]/255);
%!  plot3 (infsup ("[-1.5, 1.5]"), 1.5, infsup (0, 10), [147 161 161]/255);
%!  plot3 (0, 0, infsup (-4, 12), [220  50  47]/255);
%!  view (300, 30)
%!  hold off
