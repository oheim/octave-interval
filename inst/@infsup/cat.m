## Copyright 2015-2016 Oliver Heimlich
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
## @defmethod {@@infsup} cat (@var{DIM}, @var{ARRAY1}, @var{ARRAY2}, @dots{})
##
## Return the concatenation of N-D interval arrays @var{ARRAY1}, @var{ARRAY2},
## … along dimension @var{DIM}.
##
## @example
## @group
## cat (2, infsup (magic (3)), infsup (pascal (3)))
##   @result{} 3×6 interval matrix
##
##      [8]   [1]   [6]   [1]   [1]   [1]
##      [3]   [5]   [7]   [1]   [2]   [3]
##      [4]   [9]   [2]   [1]   [3]   [6]
## @end group
## @end example
## @seealso{@@infsup/horzcat, @@infsup/vertcat}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2015-04-19

function result = cat (dim, varargin)

  if (isa (dim, "infsup"))
    print_usage ();
    return
  endif

  ## Conversion of non-interval parameters to intervals
  interval_idx = cellfun ("isclass", varargin, "infsup");
  to_convert_idx = not (interval_idx);
  varargin(to_convert_idx) = cellfun (@infsup, ...
                                      varargin(to_convert_idx), ...
                                      "UniformOutput", false);

  ## Stack intervals along dimension dim
  s = cellfun ("struct", varargin); # struct array
  result = infsup ();
  result.inf = cat (dim, s.inf);
  result.sup = cat (dim, s.sup);

endfunction

%!assert (size (cat (1, infsup ([]), infsup ([]))), [0 0]);
%!assert (cat (1, infsup (1), infsup (2)) == infsup (cat (1, 1, 2)));
%!assert (cat (2, infsup (1), infsup (2)) == infsup (cat (2, 1, 2)));
%!assert (cat (5, infsup (1), infsup (2)) == infsup (cat (5, 1, 2)));
%!assert (cat (1, infsup (zeros (2, 2, 2)), infsup (ones (2, 2, 2))) == infsup (cat (1, zeros (2, 2, 2), ones (2, 2, 2))));
