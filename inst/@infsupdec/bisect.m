## Copyright 2015-2016 Oliver Heimlich
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
## @deftypemethod {@@infsupdec} {[@var{A}, @var{B}] =} bisect (@var{X})
##
## Bisect an interval into two intervals, which contain half the amount of
## binary64 numbers each.
##
## Instead of bisecting the values of numbers in the interval at
## @code{mid (@var{X})}, this function bisects a function that counts them.  In
## a bisect method this eliminates exactly half of the solutions and avoids
## slow convergence speeds in extreme cases.
##
## If all numbers in interval @var{X} are of equal sign, the pivot element used
## for bisection is @code{pow2 (mid (log2 (abs (@var{X}))))}.  If @var{X} is no
## empty interval, the intervals @var{A} and @var{B} are non-empty and satisfy
## @code{@var{A}.sup == @var{B}.inf}.
##
## @comment DO NOT SYNCHRONIZE DOCUMENTATION STRING
## The function is a set operation and the result carries the @code{trv}
## decoration at best.
##
## @example
## @group
## [a, b] = bisect (infsupdec (2, 32))
##   @result{} 
##     a = [2, 8]_trv
##     b = [8, 32]_trv
## @end group
## @end example
## @seealso{@@infsupdec/nextout}
## @end deftypemethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2015-05-25

function [a, b] = bisect (x)

if (nargin > 1)
    print_usage ();
    return
endif

if (isnai (x))
    a = x;
    b = x;
    return
endif

## bisect must not retain any useful decoration
[a, b] = bisect (intervalpart (x));
a = infsupdec (a, "trv");
b = infsupdec (b, "trv");

endfunction

%!test "from the documentation string";
%! [a, b] = bisect (infsupdec (2, 32));
%! assert (a == infsupdec (2, 8, "trv"));
%! assert (b == infsupdec (8, 32, "trv"));
