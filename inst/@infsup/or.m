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

function result = or (a, b)

warning ("interval:deprecated", "The or function/operator is deprecated, use union instead");
result = union (a, b);

endfunction

%!warning "from the documentation string";
%! assert ((infsup (1, 3) | infsup (2, 4)) == infsup (1, 4));
%!warning "from the documentation string";
%! assert (isequal ((infsupdec (1, 3) | infsupdec (2, 4)), infsupdec (1, 4, "trv")));

