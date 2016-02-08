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
## @defmethod {@@infsupdec} linspace (@var{BASE}, @var{LIMIT})
## @defmethodx {@@infsupdec} linspace (@var{BASE}, @var{LIMIT}, @var{N})
## 
## Return a row vector of @var{N} linearly spaced members between @var{BASE}
## and @var{LIMIT}.
##
## If @var{BASE} is greater than @var{LIMIT}, members are returned in
## decreasing order.  The default value for @var{N} is 100.
##
## If either @var{BASE} or @var{LIMIT} is not a scalar, the result is a matrix.
##
## Accuracy: The result is an accurate enclosure.
##
## @example
## @group
## transpose (linspace (infsupdec (0), infsupdec (10), 4))
##   @result{} ans ⊂ 4×1 interval vector
##   
##                     [0]_com
##        [3.3333, 3.3334]_com
##        [6.6666, 6.6667]_com
##                    [10]_com
## @end group
## @end example
## @seealso{linspace}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2015-07-19

function result = linspace (base, limit, n)

if (nargin < 2 || nargin > 3)
    print_usage ();
    return
endif
if (not (isa (base, "infsupdec")))
    base = infsupdec (base);
endif
if (not (isa (limit, "infsupdec")))
    limit = infsupdec (limit);
endif
if (nargin < 3)
    n = 100;
endif

if (isnai (base))
    result = base;
    return
endif
if (isnai (limit))
    result = limit;
    return
endif

result = newdec (linspace (intervalpart (base), intervalpart (limit), n));
## linspace is defined and continuous everywhere
result.dec = min (result.dec, min (base.dec, limit.dec));

endfunction

%!xtest assert (isequal (linspace (infsupdec (0), infsupdec (10), 9), infsupdec (linspace (0, 10, 9))));
