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
## @defmethod {@@infsup} resize (@var{X}, @var{M})
## @defmethodx {@@infsup} resize (@var{X}, @var{M}, @var{N})
## @defmethodx {@@infsup} resize (@var{X}, [@var{M} @var{N}])
##
## Resize interval matrix @var{X} cutting off elements as necessary.
##
## In the result, element with certain indices is equal to the corresponding
## element of @var{X} if the indices are within the bounds of @var{X};
## otherwise, the element is set to the empty interval.
##
## If only @var{M} is supplied, and it is a scalar, the dimension of the result
## is @var{M}-by-@var{M}.  If @var{M} and @var{N} are all scalars, then the
## dimensions of the result are @var{M}-by-@var{N}.  If given a vector as
## input, then the dimensions of the result are given by the elements of that
## vector.
##
## @example
## @group
## resize (infsup (magic (3)), 4, 2)
##   @result{} ans = 4×2 interval matrix
##          [8]       [1]
##          [3]       [5]
##          [4]       [9]
##      [Empty]   [Empty]
## @end group
## @end example
## @seealso{@@infsup/reshape, @@infsup/cat, @@infsup/postpad, @@infsup/prepad}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2015-04-19

function result = resize (x, m, n)

switch nargin
    case 2
        if (isempty (m))
            m = n = 0;
        elseif (isscalar (m))
            n = m;
        elseif (numel (m) > 2)
            error ("interval:InvalidOperand", ...
                   "resize: no more than 2 dimensions are supported")
        else
            n = m (2);
            m = m (1);
        endif
    case 3
        ## Nothing to do
    otherwise
        print_usage ();
        return
endswitch

if (not (isa (x, "infsup")))
    print_usage ();
    return
endif

l = resize (x.inf, m, n);
u = resize (x.sup, m, n);

## Implicit new elements in the matrices take the value 0. We can detect them
## in the inf matrix, because zeros in the inf matrix are set to -0 by the
## infsup constructor.

newelements = not (signbit (l)) & (l == 0);

## Set the implicit new elements to [Empty].
l (newelements) = inf;
u (newelements) = -inf;

result = infsup (l, u);

endfunction

%!assert (resize (infsup (magic (3)), 4, 2) == [infsup([8, 1; 3, 5; 4, 9]); infsup([inf, inf], [-inf, -inf])]);
