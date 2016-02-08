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
## @defmethod {@@infsup} prod (@var{X})
## @defmethodx {@@infsup} prod (@var{X}, @var{DIM})
## 
## Product of elements along dimension @var{DIM}.  If @var{DIM} is omitted, it
## defaults to the first non-singleton dimension.
##
## Accuracy: The result is a valid enclosure.
##
## @example
## @group
## prod (infsup (1 : 4))
##   @result{} ans = [24]
## @end group
## @end example
## @seealso{@@infsup/sum}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2015-10-23

function result = prod (x, dim)

if (nargin > 2)
    print_usage ();
    return
endif

if (nargin < 2)
    ## Try to find non-singleton dimension
    dim = find (size (x.inf) > 1, 1);
    if (isempty (dim))
        dim = 1;
    endif
endif

switch (dim)
    case 1
        result = infsup (ones (1, max (1, size (x.inf, 2))));
    case 2
        result = infsup (ones (max (1, size (x.inf, 1)), 1));
    otherwise
        error ("interval:InvalidOperand", ...
               "prod: DIM must be a valid dimension");
endswitch

## Short circuit in simple cases
emptyresult = any (isempty (x), dim);
result.inf (emptyresult) = +inf;
result.sup (emptyresult) = -inf;
zeroresult = not (emptyresult) & any (x.inf == 0 & x.sup == 0, dim);
result.inf (zeroresult) = -0;
result.sup (zeroresult) = +0;
entireresult = not (emptyresult | zeroresult) & any (isentire (x), dim);
result.inf (entireresult) = -inf;
result.sup (entireresult) = +inf;

idx.type = "()";
idx.subs = {":", ":"};
idx.subs{3 - dim} = not (emptyresult | zeroresult | entireresult);
if (any (idx.subs{3 - dim}))
    idx.subs{dim} = 1;
    result2 = subsref (result, idx);
    for i = 1 : size (x.inf, dim)
        idx.subs{dim} = i;
        result2 = times (result2, subsref (x, idx));
    endfor
    idx.subs{dim} = 1;
    result = subsasgn (result, idx, result2);
endif

endfunction

%!test "from the documentation string";
%! assert (prod (infsup (1 : 4)) == 24);
%!assert (prod (infsup ([])) == 1);
