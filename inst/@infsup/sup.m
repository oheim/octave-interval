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
## @deftypefn {Interval Numeric} {@var{Y} =} sup (@var{X})
## @cindex IEEE1788 sup
## 
## Get the (least) upper boundary for all numbers of interval @var{X}.
##
## If @var{X} is empty, @code{sup (@var{X})} is negative infinity.
##
## Accuracy: The result is exact.
##
## @example
## @group
## sup (infsup (2.5, 3.5))
##   @result{} 3.5
## @end group
## @end example
## @seealso{inf, mid}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-09-27

function supremum = sup (interval)

if (isa (interval, "infsupdec"))
    ## We cannot override this function in infsupdec, because that would create
    ## an infinite loop.
    if (isnai (interval))
        error ("NaI has no supremum")
    endif
endif

supremum = interval.sup;
return