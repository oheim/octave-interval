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

## @deftypefn {Interval Constructor} {} subsref (@var{A}, @var{IDX})
##
## Perform the subscripted element selection operation according to the
## subscript specified by @var{IDX}.
##
## The subscript @var{IDX} is expected to be a structure array with fields
## @code{type} and @code{subs}.  Only valid value for @var{type} is
## @code{"()"}.  The @code{subs} field may be either @code{":"} or a cell array
## of index values.
## @seealso{subsasgn}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-11-02

function result = subsref (A, S)

if (nargin ~= 2)
    print_usage ();
    return
endif

x = subsref (intervalpart (A), S);
dx = subsref (A.dec, S);

result = infsupdec (x, dx);

endfunction