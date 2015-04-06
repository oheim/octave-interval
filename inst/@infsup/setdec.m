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
## @deftypefn {Function File} {} setdec (@var{X}, @var{DX})
## 
## Create a decorated interval with desired decoration.
##
## The decorated interval will carry the decoration @var{DX} at best.
##
## @example
## @group
## setdec (infsup (2, 3), "dac")
##   @result{} [2, 3]_dac
## @end group
## @end example
## @seealso{@@infsupdec/infsupdec, @@infsup/newdec}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2015-04-06

function result = setdec (x, dx)

switch nargin
    case 1
        result = newdec (x);
        return
    case 2
        if (not (isa (x, "infsup")))
            error ("setdec: first argument must be an interval");
        endif
    otherwise
        print_usage ();
        return
endswitch

warning ("off", "interval:FixedDecoration", "local");
result = infsupdec (x, dx);

endfunction

%!test "from the documentation string";
%! assert (isequal (setdec (infsup (2, 3), "dac"), infsupdec (2, 3, "dac")));
%!warning assert (isnai (setdec (infsup (2, 3), "ill")));
%!assert (isequal (setdec (infsupdec (2, 3)), infsupdec (2, 3)));
%!assert (isequal (setdec (infsupdec (1, "trv"), "com"), infsupdec (1, "com")));
