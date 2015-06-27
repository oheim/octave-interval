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
## @deftypefnx {Function File} {} plot3 (@var{X}, @var{Y}, @var{Z}, @var{COLOR}, @var{EDGECOLOR})
## 
## Create a 3D-plot of intervals.
##
## If either of @var{X}, @var{Y} or @var{Z} is an empty interval, nothing is
## plotted.  If all are singleton intervals, a single point is plotted.  If
## two intervals are a singleton interval, a line is plotted.  If one interval
## is a singleton interval, a rectangle is plotted.  If neither of @var{X},
## @var{Y} and @var{Z} is a singleton interval, a cuboid is plotted.
##
## When interval matrices of equal size are given, each triple of elements is
## printed separately.
##
## No connection of the interval areas is plotted, because that kind of
## interpolation would be wrong in general (in the sense that the actual values
## are enclosed by the plot).
##
## If an optional parameter @var{EDGECOLOR} is given, rectangles and cuboids
## will have visible edges in a distinct color.
##
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2015-05-17

function plot3 (x, y, z, color, edgecolor)

if (nargin > 5)
    print_usage ();
    return
endif

warning ("off", "interval:ImplicitPromote", "local");
if (not (isa (x, "infsupdec")))
    x = infsupdec (x);
endif
if (not (isa (y, "infsupdec")))
    y = infsupdec (y);
endif
if (not (isa (z, "infsupdec")))
    z = infsupdec (z);
endif

if (isnai (x) || isnai (y) || isnai (z))
    error ("interval:NaI", "Cannot plot3 NaIs");
    return
endif

if (nargin < 4)
    color = 'b';
endif

if (nargin < 5)
    edgecolor = color;
endif

oldhold = ishold ();
if (not (oldhold))
    clf
    hold on
endif

pointsize = 3;
edgewidth = 2;

unwind_protect

    empty = isempty (x) | isempty (y) | isempty (z);
    number_of_singletons = issingleton (x) + issingleton (y) + issingleton (z);
    points = number_of_singletons == 3;
    lines = number_of_singletons == 2 & not (empty);
    boxes = number_of_singletons <= 1 & not (empty);
    
    if (any (any (points)))
        scatter3 (x.inf (points), y.inf (points), z.inf (points), ...
                  pointsize, ...
                  edgecolor, ...
                  'filled');
    endif
    
    if (any (any (lines)))
        x_line = [vec(x.inf (lines)), vec(x.sup (lines))]';
        y_line = [vec(y.inf (lines)), vec(y.sup (lines))]';
        z_line = [vec(z.inf (lines)), vec(z.sup (lines))]';
        plot3 (x_line, y_line, z_line, ...
               'linewidth', edgewidth, ...
               'color', edgecolor);
    endif
    
    ##                 + z
    ##                 | 
    ##
    ##                 B--------D
    ##                /|       /|
    ##               / |      / |   
    ##              /  A-----/--C  -+
    ##             F--------H  /    y
    ##             | /      | /
    ##             |/       |/
    ##             E--------G
    ##
    ##           /
    ##          + x
    
    ## The variables A through H help indexing the relevant rows in vertices.
    [A, B, C, D, E, F, G, H] = num2cell ((0 : 7) * sum (sum (boxes))) {:};
    vertices = [vec(x.inf (boxes)), vec(y.inf (boxes)), vec(z.inf (boxes)); ...
                vec(x.inf (boxes)), vec(y.inf (boxes)), vec(z.sup (boxes)); ...
                vec(x.inf (boxes)), vec(y.sup (boxes)), vec(z.inf (boxes)); ...
                vec(x.inf (boxes)), vec(y.sup (boxes)), vec(z.sup (boxes)); ...
                vec(x.sup (boxes)), vec(y.inf (boxes)), vec(z.inf (boxes)); ...
                vec(x.sup (boxes)), vec(y.inf (boxes)), vec(z.sup (boxes)); ...
                vec(x.sup (boxes)), vec(y.sup (boxes)), vec(z.inf (boxes)); ...
                vec(x.sup (boxes)), vec(y.sup (boxes)), vec(z.sup (boxes))];
    
    if (any (any (boxes))) 
        if (not (isempty (color)))
            faces = zeros (0, 3);
            ## x-y rectangle at z.inf
            select = vec (find (x.inf (boxes) < x.sup (boxes) & ...
                                y.inf (boxes) < y.sup (boxes)));
            faces = [faces; ...
                     A+select, G+select, E+select; ...
                     A+select, C+select, G+select];
            ## x-z rectangle at y.inf
            select = vec (find (x.inf (boxes) < x.sup (boxes) & ...
                                z.inf (boxes) < z.sup (boxes)));
            faces = [faces; ...
                     A+select, E+select, F+select; ...
                     A+select, F+select, B+select];
            ## y-z rectangle at x.inf
            select = vec (find (y.inf (boxes) < y.sup (boxes) & ...
                                z.inf (boxes) < z.sup (boxes)));
            faces = [faces; ...
                     A+select, D+select, C+select; ...
                     A+select, B+select, D+select];
        
            ## The cuboids have 6 sides instead of only one
            select = vec (find (x.inf (boxes) < x.sup (boxes) & ...
                                y.inf (boxes) < y.sup (boxes) & ...
                                z.inf (boxes) < z.sup (boxes)));
            faces = [faces; ...
                     ## x-y rectangle at z.sup
                     B+select, H+select, D+select; ...
                     B+select, F+select, H+select; ...
                     ## x-z rectangle at y.sup
                     C+select, H+select, G+select; ...
                     C+select, D+select, H+select; ...
                     ## y-z rectangle at x.inf
                     E+select, H+select, F+select; ...
                     E+select, G+select, H+select];
            
            patch ('Vertices', vertices, ...
                   'Faces', faces, ...
                   'edgecolor', 'none', ...
                   'facecolor', color);
        endif
        
        if (nargin >= 5 && any (any (boxes)))
            ## Also plot edges
            
            xy_rect = vec (find (x.inf (boxes) < x.sup (boxes) & ...
                                 y.inf (boxes) < y.sup (boxes) & ...
                                 z.inf (boxes) == z.sup (boxes)));
            if (not (isempty (xy_rect)))
                path = [A+xy_rect E+xy_rect G+xy_rect C+xy_rect A+xy_rect]';
                plot3 (reshape (vertices (path, 1), size (path)), ...
                       reshape (vertices (path, 2), size (path)), ...
                       reshape (vertices (path, 3), size (path)), ...
                       'color', edgecolor, ...
                       'linewidth', edgewidth);
            endif
            
            yz_rect = vec (find (x.inf (boxes) == x.sup (boxes) & ...
                                 y.inf (boxes) < y.sup (boxes) & ...
                                 z.inf (boxes) < z.sup (boxes)));
            if (not (isempty (yz_rect)))
                path = [A+yz_rect C+yz_rect D+yz_rect B+yz_rect A+yz_rect]';
                plot3 (reshape (vertices (path, 1), size (path)), ...
                       reshape (vertices (path, 2), size (path)), ...
                       reshape (vertices (path, 3), size (path)), ...
                       'color', edgecolor, ...
                       'linewidth', edgewidth);
            endif
            
            xz_rect = vec (find (x.inf (boxes) < x.sup (boxes) & ...
                                 y.inf (boxes) == y.sup (boxes) & ...
                                 z.inf (boxes) < z.sup (boxes)));
            if (not (isempty (xz_rect)))
                path = [A+xz_rect E+xz_rect F+xz_rect B+xz_rect A+xz_rect]';
                plot3 (reshape (vertices (path, 1), size (path)), ...
                       reshape (vertices (path, 2), size (path)), ...
                       reshape (vertices (path, 3), size (path)), ...
                       'color', edgecolor, ...
                       'linewidth', edgewidth);
            endif
            
            cuboids = vec (find (x.inf (boxes) < x.sup (boxes) & ...
                                 y.inf (boxes) < y.sup (boxes) & ...
                                 z.inf (boxes) < z.sup (boxes)));
            if (not (isempty (cuboids)))
                path = [A+cuboids B+cuboids D+cuboids C+cuboids ...
                        A+cuboids E+cuboids F+cuboids B+cuboids]';
                plot3 (reshape (vertices (path, 1), size (path)), ...
                       reshape (vertices (path, 2), size (path)), ...
                       reshape (vertices (path, 3), size (path)), ...
                       'color', edgecolor, ...
                       'linewidth', edgewidth);
                path = [H+cuboids G+cuboids C+cuboids D+cuboids, ...
                        H+cuboids F+cuboids E+cuboids G+cuboids]';
                plot3 (reshape (vertices (path, 1), size (path)), ...
                       reshape (vertices (path, 2), size (path)), ...
                       reshape (vertices (path, 3), size (path)), ...
                       'color', edgecolor, ...
                       'linewidth', edgewidth);
            endif
        endif
    endif

unwind_protect_cleanup
    ## Reset hold state
    if (not (oldhold))
        hold off
    endif
end_unwind_protect

endfunction

%!test "this test is rather pointless";
%!  clf
%!  plot3 (empty (), empty (), empty ());
%!  close

%!demo
%!  clf
%!  hold on
%!  t = 0 : .1 : 10;
%!  x = infsup (sin (t)) + "0.01?";
%!  y = infsup (cos (t)) + "0.1?";
%!  z = infsup (t) + (infsup ("[-1, 1]") .* sin (t) .^ 2);
%!  blue = [38 139 210]/255; red = [220 50 47]/255; green = [133 153 0]/255;
%!  yellow = [181 137 0]/255; base0 = [131 148 150]/255;
%!  base1 = [147 161 161]/255; base2 = [238 232 213]/255;
%!  plot3 (x, y, z, blue);
%!  plot3 (infsup ("0?"), infsup ("0?"), infsup (-1, 9), base2, green);
%!  plot3 (1.5, infsup ("[-1.5, 1.5]"), infsup (0, 10), base0, yellow);
%!  plot3 (infsup ("[-1.5, 1.5]"), 1.5, infsup (0, 10), base1, yellow);
%!  plot3 (0, 0, infsup (-4, 12), red);
%!  view (300, 30)
%!  hold off
