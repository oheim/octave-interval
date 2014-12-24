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
## @deftypefn {Interval Constant} {} empty ()
## @deftypefnx {Interval Constant} {} empty (@var{N})
## @deftypefnx {Interval Constant} {} empty (@var{N}, @var{M})
## @cindex IEEE1788 empty
## 
## Return the empty interval.
##
## The empty interval contains no real numbers.  All interval functions return
## an empty result if the input is either empty or outside of the function's
## domain.
##
## Accuracy: The representation of the empty interval is exact.
##
## @example
## @group
## x = empty ()
##   @result{} [Empty]_trv
## inf (x)
##   @result{} Inf
## sup (x)
##   @result{} -Inf
## @end group
## @end example
## @seealso{isempty, entire}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-09-27

function interval = empty (n, m)

switch nargin
    case 0
        interval = infsupdec ();
    case 1
        interval = infsupdec (inf (n), -inf (n));
    case 2
        interval = infsupdec (inf (n, m), -inf (n, m));
    otherwise
        print_usage();
        return
endswitch

endfunction
%!assert (inf (empty ()), inf);
%!assert (sup (empty ()), -inf);
%!assert (decorationpart (empty ()), {"trv"});
%!assert (inf (empty (5)), inf (5));
%!assert (sup (empty (5)), -inf (5));
%!assert (strcmp (decorationpart (empty (5)), "trv"), true (5));
%!assert (inf (empty (5, 6)), inf (5, 6));
%!assert (sup (empty (5, 6)), -inf (5, 6));
%!assert (strcmp (decorationpart (empty (5, 6)), "trv"), true (5, 6));
