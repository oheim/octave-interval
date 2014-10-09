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
## @deftypefn {Interval Constructor} {[@var{X}, @var{ISEXACT}] =} texttointerval (@var{S})
## @cindex IEEE1788 textToInterval
## 
## Create an interval from an interval literal.
##
## Interval literals @var{S} can be special values or in inf-sup form.  Special
## values are: @code{[]} and @code{[empty]} for the empty interval and
## @code{[entire]} for the entire set of real numbers.  Literals in inf-sup
## form must be inside square brackets.  Boundaries in inf-sup form can be a
## [+-]inf[inity] or a decimal number in the form [+-]d[.]d[[eE][+-]d].  In
## inf-sup form it is possible to use @code{[m]} as an abbreviation for
## @code{[m, m]}.
##
## Non-standard behavior: In inf-sup form the following mathematical constants
## may be used as a boundary: @code{pi} (3.14...) and @code{e} (2.71...).
## 
## A second, logical output @var{ISEXACT} indicates whether
## @code{texttointerval (@var{S})} strictly equals the mathematical interval
## denoted by @var{S}.
##
## Accuracy: The interval is a tight enclosure of the decimal numbers used in 
## inf-sup form.  For all intervals @var{X} is an accurate subset of
## @code{texttointerval (intervaltotext (@var{X}))}.
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
##   @result{} [.20999999999999999, .21000000000000002]
## @end group
## @end example
## @seealso{numstointerval, exacttointerval, intervaltotext}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval 
## Created: 2014-09-30

function [x, isexact] = texttointerval (s)

s = strtrim (s);

if (isempty (s) || s(1) ~= "[" || s(end) ~= "]")
    error ("interval literal does not begin/end with square brackets")
endif

## All the logic in the infsup constructor can be used
[x, isexact] = infsup (s);

endfunction
