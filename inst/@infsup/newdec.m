## Copyright 2014-2016 Oliver Heimlich
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
## @defmethod {@@infsup} newdec (@var{X})
## 
## Create a decorated interval from a bare interval.
##
## The decorated interval will carry the best possible decoration, i. e.,
## @code{trv} for empty intervals, @code{dac} for unbound intervals, and
## @code{com} for common intervals.
##
## If @var{X} already is decorated, nothing happens.  In particular, the
## decoration will not be changed in order to not lose any information.
##
## @example
## @group
## newdec (infsup (2, 3))
##   @result{} ans = [2, 3]_com
## @end group
## @end example
## @seealso{@@infsupdec/infsupdec}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-12

function xd = newdec (x)

if (nargin ~= 1)
    print_usage ();
    return
endif

warning ("off", "interval:ImplicitPromote", "local");
xd = infsupdec (x);

endfunction

%!test "from the documentation string";
%! assert (isequal (newdec (infsup (2, 3)), infsupdec (2, 3)));
%!assert (isequal (newdec (infsupdec (2, 3)), infsupdec (2, 3)));
%!assert (isequal (newdec (infsupdec (1, "trv")), infsupdec (1, "trv")));
