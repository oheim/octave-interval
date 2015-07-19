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
## @deftypefn {Function File} {[@var{XX}, @var{YY}] =} meshgrid (@var{X}, @var{Y})
## @deftypefnx {Function File} {[@var{XX}, @var{YY}, @var{ZZ}] =} meshgrid (@var{X}, @var{Y}, @var{Z})
## @deftypefnx {Function File} {[@var{XX}, @var{YY}] =} meshgrid (@var{X})
## @deftypefnx {Function File} {[@var{XX}, @var{YY}, @var{ZZ}] =} meshgrid (@var{X})
## 
## Given vectors of @var{X} and @var{Y} coordinates, return matrices @var{XX}
## and @var{YY} corresponding to a full 2-D grid.
##
## @end deftypefn

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

xx = infsup (lxx, uxx);
yy = infsup (lyy, uyy);
if (nargout >= 3)
    zz = infsup (lzz, uzz);
endif

endfunction

%!assert (isequal (meshgrid (infsup (0 : 3)), infsup (meshgrid (0 : 3))));
