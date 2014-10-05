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

## -- IEEE 1788 interval constant:  entire ()
##
## Return the entire set of real numbers.
##
## See also:
##  empty
##
## Example:
##  i = entire ();
##  if (isentire (i))
##    display ("success");
##  endif

## Author: Oliver Heimlich
## Keywords: interval constant
## Created: 2014-09-27

function interval = entire ()

interval = infsup (-inf, inf);
return