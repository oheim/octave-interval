## Copyright 2015-2016 Oliver Heimlich
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
## @defmethod {@@infsupdec} dot (@var{X}, @var{Y})
## @defmethodx {@@infsupdec} dot (@var{X}, @var{Y}, @var{DIM})
## 
## Compute the dot product of two interval vectors.
## 
## If @var{X} and @var{Y} are matrices, calculate the dot products along the
## first non-singleton dimension.  If the optional argument @var{DIM} is given,
## calculate the dot products along this dimension.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## dot ([infsupdec(1), 2, 3], [infsupdec(2), 3, 4])
##   @result{} ans = [20]_com
## @end group
## @group
## dot (infsupdec ([realmax; realmin; realmax]), [1; -1; -1], 1)
##   @result{} ans ⊂ [-2.2251e-308, -2.225e-308]_com
## @end group
## @end example
## @seealso{@@infsupdec/plus, @@infsupdec/sum, @@infsupdec/times}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2015-01-31

function result = dot (x, y, dim)

if (nargin < 2 || nargin > 3)
    print_usage ();
    return
endif

if (not (isa (x, "infsupdec")))
    x = infsupdec (x);
endif
if (not (isa (y, "infsupdec")))
    y = infsupdec (y);
endif
if (nargin < 3)
    if (isvector (x.dec) && isvector (y.dec))
        ## Align vectors along common dimension
        dim = 1;
        x = vec (x, dim);
        y = vec (y, dim);
    else
        ## Try to find non-singleton dimension
        dim = find (any (size (x.dec), size (y.dec)) > 1, 1);
        if (isempty (dim))
            dim = 1;
        endif
    endif
endif

## null matrix input -> null matrix output
if (isempty (x.dec) || isempty (y.dec))
    result = infsupdec (zeros (min (size (x.dec), size (y.dec))));
    return
endif

## Only the sizes of non-singleton dimensions must agree. Singleton dimensions
## do broadcast (independent of parameter dim).
if ((min (size (x.dec, 1), size (y.dec, 1)) > 1 && ...
        size (x.dec, 1) ~= size (y.dec, 1)) || ...
    (min (size (x.dec, 2), size (y.dec, 2)) > 1 && ...
        size (x.dec, 2) ~= size (y.dec, 2)))
    error ("interval:InvalidOperand", "dot: sizes of X and Y must match")
endif

result = newdec (dot (intervalpart (x), intervalpart (y), dim));
result.dec = min (result.dec, ...
                  min (min (x.dec, [], dim), min (y.dec, [], dim)));

endfunction

%!test "from the documentation string";
%! assert (isequal (dot ([infsupdec(1), 2, 3], [infsupdec(2), 3, 4]), infsupdec (20)));
%! assert (isequal (dot (infsupdec ([realmax; realmin; realmax]), [1; -1; -1], 1), infsupdec (-realmin)));
