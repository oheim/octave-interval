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
## @defop Method {@@infsup} ne (@var{A}, @var{B})
## @defopx Operator {@@infsup} {@var{A} ~= @var{B}}
## @defopx Operator {@@infsup} {@var{A} != @var{B}}
## 
## Compare intervals @var{A} and @var{B} for inequality.
##
## True, if @var{A} contains a number which is not a member in @var{B} or vice
## versa.  False, if all numbers from @var{A} are also contained in @var{B} and
## vice versa.
##
## @seealso{@@infsup/eq, @@infsup/subset, @@infsup/interior, @@infsup/disjoint}
## @end defop

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-09-30

function result = ne (a, b)

if (nargin ~= 2)
    print_usage ();
    return
endif

result = not (eq (a, b));

endfunction

%!assert (ne (infsup (1, 2), infsup (1, 3)));
