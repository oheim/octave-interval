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

function result = and (a, b)

warning ("interval:deprecated", "The and function/operator is deprecated, use intersect instead");
result = intersect (a, b);

endfunction

%!warning "Empty interval";
%! assert (and (infsup (), infsup ()) == infsup ());
%! assert (and (infsup (), infsup (1)) == infsup ());
%! assert (and (infsup (0), infsup ()) == infsup ());
%! assert (and (infsup (-inf, inf), infsup ()) == infsup ());
%!warning "Singleton intervals";
%! assert (and (infsup (0), infsup (1)) == infsup ());
%! assert (and (infsup (0), infsup (0)) == infsup (0));
%!warning "Bounded intervals";
%! assert (and (infsup (1, 2), infsup (3, 4)) == infsup ());
%! assert (and (infsup (1, 2), infsup (2, 3)) == infsup (2));
%! assert (and (infsup (1, 2), infsup (1.5, 2.5)) == infsup (1.5, 2));
%! assert (and (infsup (1, 2), infsup (1, 2)) == infsup (1, 2));
%!warning "Unbounded intervals";
%! assert (and (infsup (0, inf), infsup (-inf, 0)) == infsup (0));
%! assert (and (infsup (1, inf), infsup (-inf, -1)) == infsup ());
%! assert (and (infsup (-1, inf), infsup (-inf, 1)) == infsup (-1, 1));
%! assert (and (infsup (-inf, inf), infsup (42)) == infsup (42));
%! assert (and (infsup (42), infsup (-inf, inf)) == infsup (42));
%! assert (and (infsup (-inf, 0), infsup (-inf, inf)) == infsup (-inf, 0));
%! assert (and (infsup (-inf, inf), infsup (-inf, inf)) == infsup (-inf, inf));
%!warning "from the documentation string";
%! assert (and (infsup (1, 3), infsup (2, 4)) == infsup (2, 3));
%!warning "from the documentation string";
%! assert (isequal (and (infsupdec (1, 3), infsupdec (2, 4)), infsupdec (2, 3, "trv")));
