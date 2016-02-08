## Copyright 2014-2016 Oliver Heimlich
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
## @deftypemethod {@@infsup} {@var{Z} =} cancelplus (@var{X}, @var{Y})
## 
## Recover interval @var{Z} from intervals @var{X} and @var{Y}, given that one
## knows @var{X} was obtained as the difference @var{Z} - @var{Y}.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## cancelplus (infsup (2, 3), infsup (1, 1.5))
##   @result{} ans = [3.5, 4]
## @end group
## @end example
## @seealso{@@infsup/cancelminus}
## @end deftypemethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-19

function result = cancelplus (x, y)

if (nargin ~= 2)
    print_usage ();
    return
endif

result = cancelminus (x, -y);

endfunction

%!test "from the documentation string";
%! assert (cancelplus (infsup (2, 3), infsup (1, 1.5)) == infsup (3.5, 4));
