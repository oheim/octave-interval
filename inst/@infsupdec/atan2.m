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
## @deftypefn {Interval Function} {@var{Z} =} atan2 (@var{Y}, @var{X})
## @cindex IEEE1788 atan2
## 
## Compute the inverse tangent with two arguments for each pair of numbers from
## intervals @var{Y} and @var{X}.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## atan2 (infsupdec (1), infsupdec (-1))
##   @result{} [2.3561944901923448, 2.3561944901923453]_com
## @end group
## @end example
## @seealso{tan}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-06

function result = atan2 (y, x)

assert (nargin == 2);

## Convert first parameter into interval, if necessary
if (not (isa (y, "infsupdec)))
    y = infsupdec (y);
endif

## Convert second parameter into interval, if necessary
if (not (isa (x, "infsupdec")))
    x = infsupdec (x);
endif

result = atan2 (intervalpart (y), intervalpart (x));

if (ismember (0, y))
    if (ismember (0, x))
        ## The only undefined input is <0,0>
        result = decorateresult (result, {y, x}, "trv");
        return
    elseif (x.inf < 0)
        ## The function is discontinuous for x <= 0 and y == 0
        result = decorateresult (result, {y, x}, "def");
        return
    endif
endif

## The function is defined and continuous everywhere else.
result = decorateresult (result, {y, x});

endfunction