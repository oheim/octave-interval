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
## @deftypefn {Interval Constructor} {@var{X} =} numstointerval (@var{L}, @var{U})
## @cindex IEEE1788 numsToInterval
## 
## Create an interval from two numeric boundaries.
##
## The lower boundary @var{L} must be less than or equal to the upper boundary
## @var{U}.  The following GNU Octave data types can be used as parameters:
## double, single, [u]int[8,16,32,64].  However, the boundaries of the
## constructed interval are always in double precision.
##
## Interval construction fails if @var{U} is less than @var{L}.  The interval
## may fail to enclose a desired number if the number is given as a numeric
## literal that is not an exact binary floating point in double precision,
## e. g., @code{0.1} should only be used with a string based constructor.
##
## Accuracy: The interval is a tight enclosure of the numbers.
##
## @example
## @group
## x = numstointerval (-2.5, 3)
##   @result{} [-2.5, +3]_com
## y = numstointerval (9, 9)
##   @result{} [9]_com
## z = numstointerval (-inf, inf)
##   @result{} [Entire]_dac
## @end group
## @end example
## @seealso{texttointerval, exacttointerval}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-09-30

function interval = numstointerval (l, u)

## All the logic in the infsupdec constructor can be used
interval = infsupdec (l, u);

endfunction
%!test "double precision";
%! x = numstointerval (-2.5, 3);
%! assert (inf (x) == -2.5);
%! assert (sup (x) == 3);
%!test "single precision";
%! x = numstointerval (single (-2.5), single (3));
%! assert (inf (x) == -2.5);
%! assert (sup (x) == 3);
%!test "integer";
%! x = numstointerval (int16 (-2), int16 (3));
%! assert (inf (x) == -2);
%! assert (sup (x) == 3);
%!test "unsigned integer";
%! x = numstointerval (uint64 (2), uint64 (3));
%! assert (inf (x) == 2);
%! assert (sup (x) == 3);
%!test "empty interval";
%! x = numstointerval (inf, -inf);
%! assert (isempty (x));
%!test "illegal boundaries";
%! x = numstointerval (1, 0);
%! assert (isnai (x));