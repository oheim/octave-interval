## Copyright 2014 Oliver Heimlich
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
## @deftypefn {Interval Comparison} {} ismember (@var{M}, @var{X})
## @cindex IEEE1788 isMember
## 
## Check if the interval @var{X} contains the number @var{M}.
##
## The number can be a numerical data type or a string representation of a 
## decimal number.
##
## @seealso{eq, isentire, issingleton, isempty}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-13

function result = ismember (real, interval)

if (nargin ~= 2)
    print_usage ();
    return
endif
if (not (isa (interval, "infsupdec")))
    interval = infsupdec (interval);
endif

if (isnai (interval))
    error ("interval comparison with NaI")
endif

result = ismember (real, intervalpart (interval));

return