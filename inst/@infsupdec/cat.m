## Copyright 2016 Oliver Heimlich
## Copyright 2017 Joel Dahne
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
## @defmethod {@@infsupdec} cat (@var{DIM}, @var{ARRAY1}, @var{ARRAY2}, @dots{})
##
## Return the concatenation of N-D interval arrays @var{ARRAY1}, @var{ARRAY2},
## … along dimension @var{DIM}.
##
## @example
## @group
## cat (2, infsupdec (magic (3)), infsupdec (pascal (3)))
##   @result{} 3×6 interval matrix
##
##      [8]_com   [1]_com   [6]_com   [1]_com   [1]_com   [1]_com
##      [3]_com   [5]_com   [7]_com   [1]_com   [2]_com   [3]_com
##      [4]_com   [9]_com   [2]_com   [1]_com   [3]_com   [6]_com
## @end group
## @end example
## @seealso{@@infsup/horzcat, @@infsup/vertcat}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2016-10-09

function result = cat (dim, varargin)

  if (isa (dim, "infsup"))
    print_usage ();
    return
  endif

  ## Conversion of non-interval and undecorated parameters to decorated intervals
  decorated_interval_idx = cellfun ("isclass", varargin, "infsupdec");
  to_convert_idx = not (decorated_interval_idx);
  varargin(to_convert_idx) = cellfun (@infsupdec, ...
                                      varargin(to_convert_idx), ...
                                      "UniformOutput", false);

  ## Stack intervals along dimension dim
  s = cellfun ("struct", varargin); # struct array
  result = infsupdec ();
  result.infsup = cat (dim, s.infsup);
  result.dec = cat (dim, s.dec);

endfunction

%!assert (size (cat (1, infsupdec ([]), infsupdec ([]))), [0 0]);
%!assert (isequal (cat (1, infsupdec (1), infsupdec (2)), infsupdec (cat (1, 1, 2))));
%!assert (isequal (cat (2, infsupdec (1), infsupdec (2)), infsupdec (cat (2, 1, 2))));

%!assert (isequal (horzcat (infsupdec (1), infsupdec (2)), infsupdec (horzcat (1, 2))));
%!test
%! a = infsupdec (2, 5);
%! assert (isequal (horzcat (a, a, a), infsupdec ([2, 2, 2], [5, 5, 5])));

%!assert (isequal (vertcat (infsupdec (1), infsupdec (2)), infsupdec (vertcat (1, 2))));
%!test
%! a = infsupdec (2, 5);
%! assert (isequal (vertcat (a, a, a), infsupdec ([2; 2; 2], [5; 5; 5])));

%!assert (isequal (cat (5, infsupdec (1), infsupdec (2)), infsupdec (cat (5, 1, 2))));
%!assert (isequal (cat (1, infsupdec (zeros (2, 2, 2)), infsupdec (ones (2, 2, 2))), infsupdec (cat (1, zeros (2, 2, 2), ones (2, 2, 2)))));
