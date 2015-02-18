## Copyright 2015 Oliver Heimlich
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
## @deftypefn {Function File} {} {[@var{L}, @var{U}] = } lu (@var{A})
## @deftypefnx {Function File} {} {[@var{L}, @var{U}, @var{P}] = } lu (@var{A})
## 
## Compute the LU decomposition of @var{A}.
##
## @var{A} will be a subset of @var{L} * @var{U}.
##
## The result is returned in a permuted form, according to the optional return
## value @var{P}.
##
## Accuracy: The result is a valid enclosure.
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2015-02-18

function [L, U, P] = lu (x)

if (nargin ~= 1)
    print_usage ();
    return
endif

P = eye (size (x.dec));
if (isnai (x))
    L = U = x;
    return
endif

if (nargout >= 3)
    [L, U, P] = lu (invervalpart (x));
else
    [L, U] = lu (intervalpart (x));
endif    

## Reverse operations should not carry decoration
L = infsupdec (L, "trv");
U = infsupdec (U, "trv");

endfunction
