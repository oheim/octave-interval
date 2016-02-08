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
## @defop Method {@@infsup} lt (@var{A}, @var{B})
## @defopx Operator {@@infsup} {@var{A} < @var{B}}
## 
## Compare intervals @var{A} and @var{B} for strictly less.
##
## True, if all numbers from @var{A} are strict less than at least one number
## in @var{B}.  False, if @var{A} contains a number which is greater than all
## numbers in @var{B} or is equal to the greatest number of @var{B}.
##
## Evaluated on interval matrices, this functions is applied element-wise.
##
## @seealso{@@infsup/eq, @@infsup/le, @@infsup/gt, @@infsup/subset, @@infsup/interior, @@infsup/disjoint}
## @end defop

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-07

function result = lt (a, b)

if (nargin ~= 2)
    print_usage ();
    return
endif
if (not (isa (a, "infsup")))
    a = infsup (a);
endif
if (not (isa (b, "infsup")))
    b = infsup (b);
elseif (isa (b, "infsupdec"))
    ## Workaround for bug #42735
    result = lt (a, b);
    return
endif

result = ((a.inf < b.inf | (a.inf == -inf & b.inf == -inf)) & ...
          (a.sup < b.sup | (a.sup == inf & b.sup == inf)));

result (isempty (a) & isempty (b)) = true ();

endfunction

%!assert (not (lt (infsup (1, 3), infsup (3))));
%!assert (lt (infsup (1, 3), infsup (3.1)));
