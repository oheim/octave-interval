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
## @defmethod {@@infsup} isentire (@var{X})
## 
## Check if the interval represents the entire set of real numbers.
##
## Evaluated on interval matrices, this functions is applied element-wise.
##
## @seealso{entire, @@infsup/eq, @@infsup/isempty, @@infsup/issingleton}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-09-27

function result = isentire (interval)

if (nargin ~= 1)
    print_usage ();
    return
endif

result = (interval.inf == -inf & interval.sup == inf);

endfunction

%!assert (isentire (entire ()));
%!assert (isentire (intervalpart (entire ())));
%!assert (not (isentire (empty ())));
%!assert (not (isentire (intervalpart (empty ()))));

%!warning assert (not (isentire (infsupdec (2, 1))));
