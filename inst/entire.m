## Copyright 2014-2016 Oliver Heimlich
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
## @defun entire ()
## @defunx entire (@var{N})
## @defunx entire (@var{N}, @var{M})
## 
## Return the entire set of real numbers.
##
## With additional parameters, create an interval vector/matrix, which
## comprises entire interval entries.
##
## The entire set of real numbers [Entire] is a closed interval.  If used as
## an enclosure for a certain value, it represents a state of minimum
## constraints.  An interval function which evaluates to [Entire] yields no
## information at all if no interval decoration is present.
##
## The special floating-point values -Inf and Inf represent boundaries of the
## entire set of real numbers.  However, they are not members of the interval.
##
## The result of this function carries the defined and continuous @code{dac}
## decoration, which denotes that the interval is not bounded and therefore is
## no common interval.
##
## Accuracy: The representation of the entire set of real numbers is exact.
##
## @example
## @group
## x = entire ()
##   @result{} x = [Entire]_dac
## inf (x)
##   @result{} ans = -Inf
## sup (x)
##   @result{} ans = Inf
## @end group
## @end example
## @seealso{@@infsup/isentire, empty}
## @end defun

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-09-27

function result = entire (varargin)

switch nargin
    case 0
        result = infsupdec (-inf, inf);
    case 1
        result = infsupdec (-inf (varargin {1}), inf (varargin {1}));
    case 2
        result = infsupdec (-inf (varargin {1}, varargin {2}), ...
                            +inf (varargin {1}, varargin {2}));
    otherwise
        print_usage();
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
