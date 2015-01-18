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
## @deftypefn {Function File} {@var{XD} =} setdec (@var{X}, @var{D})
## 
## Create a decorated interval from a bare interval and a decoration if this is
## a valid combination.
##
## @example
## @group
## setdec (entire (), "com")
##   @result{} [Entire]_dac
## @end group
## @end example
## @seealso{@@infsupdec/infsupdec}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-12

function xd = setdec (x, d)

if (nargin ~= 2)
    print_usage ();
    return
endif

if (isempty (x))
    if (max (strcmpi (d, {"def", "dac", "com"})))
        d = "trv";
    endif
elseif (not (isfinite (x.inf) && isfinite (x.sup)))
    if (strcmpi (d, "com"))
        d = "dac";
    endif
endif

xd = infsupdec (x.inf, x.sup, d);

endfunction