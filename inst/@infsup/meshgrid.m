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
## @documentencoding UTF-8
## @deftypemethod {@@infsup} {[@var{XX}, @var{YY}] =} meshgrid (@var{X}, @var{Y})
## @deftypemethodx {@@infsup} {[@var{XX}, @var{YY}, @var{ZZ}] =} meshgrid (@var{X}, @var{Y}, @var{Z})
## @deftypemethodx {@@infsup} {[@var{XX}, @var{YY}] =} meshgrid (@var{X})
## @deftypemethodx {@@infsup} {[@var{XX}, @var{YY}, @var{ZZ}] =} meshgrid (@var{X})
## 
## Given vectors of @var{X} and @var{Y} coordinates, return matrices @var{XX}
## and @var{YY} corresponding to a full 2-D grid.
##
## If the optional @var{Z} input is given, or @var{ZZ} is requested, then the
## output will be a full 3-D grid.
##
## Please note that this function does not produce multidimensional arrays in
## the case of 3-D grids like the built-in @code{meshgrid} function.  This is
## because interval matrices currently only support two dimensions.  The 3-D
## grid is reshaped to fit into two dimensions accordingly.
##
## @end deftypemethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2015-07-19

function [xx, yy, zz] = meshgrid (x, y, z)

if (nargin > 3)
    print_usage ();
    return
endif
if (not (isa (x, "infsup")))
    x = infsup (x);
endif
if (nargin >= 2 && not (isa (y, "infsup")))
    y = infsup (y);
endif
if (nargin >= 3 && not (isa (z, "infsup")))
    z = infsup (z);
endif

switch (nargin)
    case 1
        if (nargout >= 3)
            [lxx, lyy, lzz] = meshgrid (x.inf);
            [uxx, uyy, uzz] = meshgrid (x.sup);
        else
            [lxx, lyy] = meshgrid (x.inf);
            [uxx, uyy] = meshgrid (x.sup);
        endif
    case 2
        if (nargout >= 3)
            [lxx, lyy, lzz] = meshgrid (x.inf, y.inf);
            [uxx, uyy, uzz] = meshgrid (x.sup, y.sup);
        else
            [lxx, lyy] = meshgrid (x.inf, y.inf);
            [uxx, uyy] = meshgrid (x.sup, y.sup);
        endif
    case 3
            [lxx, lyy, lzz] = meshgrid (x.inf, y.inf, z.inf);
            [uxx, uyy, uzz] = meshgrid (x.sup, y.sup, z.sup);
endswitch

if (nargout >= 3 || nargin >= 3)
    ## Reshape 3 dimensions into 2 dimensions
    f = @(A) reshape (A, [size(A,1), prod(size (A)(2 : end))]);
    lxx = f (lxx);
    uxx = f (uxx);
    lyy = f (lyy);
    uyy = f (uyy);
    lzz = f (lzz);
    uzz = f (uzz);
endif
xx = infsup (lxx, uxx);
yy = infsup (lyy, uyy);
if (nargout >= 3)
    zz = infsup (lzz, uzz);
endif

endfunction

%!xtest assert (isequal (meshgrid (infsup (0 : 3)), infsup (meshgrid (0 : 3))));

%!demo
%!  clf
%!  blue = [38 139 210] ./ 255;
%!  shade = [238 232 213] ./ 255;
%!  [x, y, z] = meshgrid (midrad (1 : 6, 0.125));
%!  plot3 (x, y, z, shade, blue)
%!  view ([-42.5, 30])
%!  box off
%!  set (gca, "xgrid", "on", "ygrid", "on", "zgrid", "on")
