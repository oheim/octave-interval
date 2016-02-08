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
## @defun exacttointerval (@var{S})
## @defunx exacttointerval (@var{L}, @var{U})
## @defunx exacttointerval (@var{M})
## 
## Create a bare interval.  Fail, if the interval cannot exactly represent the
## input.
##
## Typically, this function operates on interval literals @var{S}.  It is also
## possible to pass lower and upper boundaries @var{L} and @var{U}, or create a
## point-interval with a midpoint @var{M}.
##
## All valid input formats of the @code{infsup} class constructor are allowed.
## If this function creates an interval matrix, all interval boundaries must be
## representable with binary64 numbers.
##
## Accuracy: The equation
## @code{@var{X} == exacttointerval (intervaltoexact (@var{X}))} holds for all
## intervals.
##
## @example
## @group
## w = exacttointerval ("[ ]")
##   @result{} w = [Empty]
## x = exacttointerval ("[2, 3]")
##   @result{} x = [2, 3]
## y = exacttointerval ("[,]")
##   @result{} y = [Entire]
## z = exacttointerval ("[21e-1]")
##   @print{} ??? exacttointerval: interval wouldn't be exact
## @end group
## @end example
## @seealso{@@infsup/intervaltoexact, @@infsup/infsup}
## @end defun

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-01

function result = exacttointerval (varargin)

switch (nargin)
    case 0
        [result, exactconversion] = infsup ();
    case 1
        [result, exactconversion] = infsup (varargin {1});
    case 2
        [result, exactconversion] = infsup (varargin {1}, varargin {2});
    otherwise
        print_usage ();
        return
endswitch

if (not (exactconversion))
    error ("interval:UndefinedOperation", ...
           "exacttointerval: interval wouldn't be exact")
endif

endfunction
%!assert (isempty (exacttointerval ("[Empty]")));
%!assert (isentire (exacttointerval ("[Entire]")));
%!test "common interval";
%! y = exacttointerval ("[0, 1]");
%! assert (inf (y), 0);
%! assert (sup (y), 1);
%!test "point interval";
%! y = exacttointerval ("[42]");
%! assert (inf (y), 42);
%! assert (sup (y), 42);
%!test "unbound interval";
%! y = exacttointerval ("[-4, Infinity]");
%! assert (inf (y), -4);
%! assert (sup (y), inf);
%!error exacttointerval ("[0, 0.1]");
%!error exacttointerval ("[1, 0]");
