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
## @documentencoding utf-8
## @deftypefn {Function File} {} entire ()
## @deftypefnx {Function File} {} entire (@var{N})
## @deftypefnx {Function File} {} entire (@var{N}, @var{M})
## 
## Return the entire set of real numbers.
##
## The entire set of real numbers is a closed interval.  If used as boundaries
## for a certain value, it represents a state of minimum constraints.  An
## interval function which evaluates to [Entire] yields no information at all
## if no interval decoration is present.
##
## Accuracy: The representation of the entire set of real numbers is exact.
##
## @example
## @group
## x = entire ()
##   @result{} [Entire]_dac
## inf (x)
##   @result{} -Inf
## sup (x)
##   @result{} Inf
## @end group
## @end example
## @seealso{isentire, empty}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-09-27

function interval = entire (n, m)

switch nargin
    case 0
        interval = infsupdec (-inf, inf);
    case 1
        interval = infsupdec (-inf (n), inf (n));
    case 2
        interval = infsupdec (-inf (n, m), inf (n, m));
    otherwise
        print_usage();
        return
endswitch

endfunction
%!assert (inf (entire ()), -inf);
%!assert (sup (entire ()), inf);
%!assert (decorationpart (entire ()), {"dac"});
%!assert (inf (entire (5)), -inf (5));
%!assert (sup (entire (5)), inf (5));
%!assert (strcmp (decorationpart (entire (5)), "dac"), true (5));
%!assert (inf (entire (5, 6)), -inf (5, 6));
%!assert (sup (entire (5, 6)), inf (5, 6));
%!assert (strcmp (decorationpart (entire (5, 6)), "dac"), true (5, 6));
