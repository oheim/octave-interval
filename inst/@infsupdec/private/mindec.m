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
## @deftypefn {Function File} {} mindec (@var{DECORATIONS}…)
## 
## For a list of arrays of decorations, determine the worst (minimum)
## decoration for each element.
##
## @example
## @group
## mindec ({"com", "dac", "def"}, "dac", {"com", "com", "trv"})
##   @result{} {"dac", "dac", "trv"}
## @end group
## @end example
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-11-02

function decoration = mindec (varargin)

decoration = varargin {1};

## Determine and apply the minimum decoration
for i = 2 : nargin
    if (iscell (varargin {i}) && not (isempty (varargin {i})))
        otherdecoration = varargin {i} {1};
    else
        otherdecoration = varargin {i};
    endif

    ## Only check distinct elements
    for n = find (not (strcmp (decoration, varargin {i}))) (:)'
        if (iscell (varargin {i}) && not (isscalar (varargin {i})))
            otherdecoration = varargin {i} {n};
        else
            ## Scalars broadcast into the whole cell array. The value is set
            ## once before the inner for loop.
        endif

        ## Because of the simple propagation order com > dac > def > trv, we
        ## can use string comparison order.
        if (sign ((decoration {n}) - otherdecoration) * [4; 2; 1] < 0)
            decoration {n} = otherdecoration;
        endif
    endfor
endfor

endfunction