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
if (not (isa (x, "infsupdec")))
    x = infsupdec (x);
endif
if (nargin >= 2 && not (isa (y, "infsupdec")))
    y = infsupdec (y);
endif
if (nargin >= 3 && not (isa (z, "infsupdec")))
    z = infsupdec (z);
endif

if (isnai (x))
    xx = yy = zz = x;
    return
endif
if (nargin >= 2 && isnai (y))
    xx = yy = zz = y;
    return
endif
if (nargin >= 3 && isnai (z))
    xx = yy = zz = z;
    return
endif

switch (nargin)
    case 1
        if (nargout >= 3)
            [xx, yy, zz] = meshgrid (intervalpart (x));
            [dxx, dyy, dzz] = meshgrid (x.dec);
        else
            [xx, yy] = meshgrid (intervalpart (x));
            [dxx, dyy] = meshgrid (x.dec);
        endif
    case 2
        if (nargout >= 3)
            [xx, yy, zz] = meshgrid (intervalpart (x), intervalpart (y));
            [dxx, dyy, dzz] = meshgrid (x.dec, y.dec);
        else
            [xx, yy] = meshgrid (intervalpart (x), intervalpart (y));
            [dxx, dyy] = meshgrid (x.dec, y.dec);
        endif
    case 3
        [xx, yy, zz] = meshgrid (intervalpart (x), ...
                                 intervalpart (y), ...
                                 intervalpart (z));
        [dxx, dyy, dzz] = meshgrid (x.dec, y.dec, z.dec);
endswitch

xx = newdec (xx);
xx.dec = min (xx.dec, dxx);
yy = newdec (yy);
yy.dec = min (yy.dec, dyy);
if (nargout >= 3 || nargin >= 3)
    zz = newdec (zz);
    zz.dec = min (zz.dec, dzz);
endif

endfunction

%!assert (isequal (meshgrid (infsupdec (0 : 3)), infsupdec (meshgrid (0 : 3))));
