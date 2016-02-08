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
## @defmethod {@@infsupdec} nextout (@var{X})
## 
## Increases the interval's boundaries in each direction to the next number.
##
## This is the equivalent function to IEEE 754's nextDown and nextUp.
##
## @comment DO NOT SYNCHRONIZE DOCUMENTATION STRING
## The function is a set operation and the result carries the @code{trv}
## decoration at best.
##
## @example
## @group
## x = infsupdec (1);
## nextout (x) == infsupdec (1 - eps / 2, 1 + eps)
##   @result{} ans = 1
## @end group
## @end example
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2015-04-03

function result = nextout (x)

if (nargin ~= 1)
    print_usage ();
    return
endif

if (isnai (x))
    result = x;
    return
endif

result = infsupdec (nextout (intervalpart (x)), "trv");

endfunction

%!test "from the documentation string";
%! x = nextout (infsupdec (1));
%! assert (inf (x), 1 - eps / 2);
%! assert (sup (x), 1 + eps);
%! assert (decorationpart (x), {"trv"});
