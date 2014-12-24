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
## @deftypefn {Interval Constructor} {} exacttointerval (@var{S})
## @cindex IEEE1788 exactToInterval
## 
## Create an interval from an interval literal.  Fail, if the interval cannot
## exactly represent the input S.
##
## Accuracy: The equation @code{@var{X} == exacttointerval (intervaltoexact (@var{X}))}
## holds for all intervals.
##
## @example
## @group
## w = exacttointerval ("[ ]")
##   @result{} [Empty]
## x = exacttointerval ("[2, 3]")
##   @result{} [2, 3]
## y = exacttointerval ("[,]")
##   @result{} [Entire]
## z = exacttointerval ("[2.1e-1]")
##   @result{} error: rounding occurred during interval construction
## @end group
## @end example
## @seealso{intervaltoexact}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-01

function x = exacttointerval (s)

[x, exactconversion] = infsupdec (s);

if (not (exactconversion))
    error ("UndefinedOperation: interval construction can't be exact")
endif

endfunction
%!assert (isempty (exacttointerval ("[Empty]")));
%!assert (isentire (exacttointerval ("[Entire]")));
%!test "common interval";
%! y = exacttointerval ("[0, 1]");
%! assert (inf (y), 0);
%! assert (sup (y), 1);
%! assert (decorationpart (y), {"com"});
%!test "point interval";
%! y = exacttointerval ("[42]");
%! assert (inf (y), 42);
%! assert (sup (y), 42);
%! assert (decorationpart (y), {"com"});
%!test "unbound interval";
%! y = exacttointerval ("[-4, Infinity]");
%! assert (inf (y), -4);
%! assert (sup (y), inf);
%! assert (decorationpart (y), {"dac"});
%!error exacttointerval ("[0, 0.1]");
%!error exacttointerval ("[1, 0]");
