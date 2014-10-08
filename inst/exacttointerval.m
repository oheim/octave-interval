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
## @deftypefn {Interval Constructor} {@var{X} =} exacttointerval (@var{S})
## @cindex IEEE1788 exactToInterval
## 
## Create an interval from an interval literal.  Fail, if the interval cannot
## exactly represent the input S.
##
## Interval literals @var{S} can be special values or in inf-sup form.  Special
## values are: @code{[]} and @code{[empty]} for the empty interval and
## @code{[entire]} for the entire set of real numbers.  Literals in inf-sup
## form must be inside square brackets.  Boundaries in inf-sup form can be a
## [+-]inf[inity] or a decimal number in the form [+-]d[.]d[[eE][+-]d].  In
## inf-sup form it is possible to use @code{[m]} as an abbreviation for
## @code{[m, m]}.
##
## Accuracy: The equation @code{@var{X} == exacttointerval (intervaltoexact (@var{X}))}
## holds for all intervals.
##
## @example
## @group
## w = texttointerval ("[ ]")
##   @result{} [Empty]
## x = texttointerval ("[2, 3]")
##   @result{} [2, 3]
## y = texttointerval ("[,]")
##   @result{} [Entire]
## z = texttointerval ("[2.1e-1]")
##   @result{} error: rounding occurred during interval construction
## @end group
## @end example
## @seealso{numstointerval, texttointerval, intervaltoexact}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-01

function x = exacttointerval (s)

[x, exactconversion] = texttointerval (s);

if (not (exactconversion))
    error ("rounding occurred during interval construction")
endif

endfunction