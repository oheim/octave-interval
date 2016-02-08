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
## @defmethod {@@infsup} ismember (@var{M}, @var{X})
## 
## Check if the interval @var{X} contains the number @var{M}.
##
## The number can be a numerical data type or a string representation of a 
## decimal number.
##
## Evaluated on interval matrices, this functions is applied element-wise.
##
## @seealso{@@infsup/eq, @@infsup/isentire, @@infsup/issingleton, @@infsup/isempty}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-13

function result = ismember (real, interval)

if (nargin ~= 2)
    print_usage ();
    return
endif
if (not (isa (interval, "infsup")))
    interval = infsup (interval);
endif

if (isreal (real) && isfloat (real))
    ## Simple checking is only possible with floating point numbers
    result = isfinite (real) & interval.inf <= real & real <= interval.sup;
else
    ## Mixed mode comparison between integers and floats can be problematic
    ## as well as comparison with decimal numbers
    result = subset (infsup (real), interval);
endif

endfunction

%!assert (ismember (0, entire ()));
%!assert (ismember (0, intervalpart (entire ())));

%!assert (not (ismember (0, empty ())));
%!assert (not (ismember (0, intervalpart (empty ()))));

%!warning assert (not (ismember (0, infsupdec (2, 1))));
