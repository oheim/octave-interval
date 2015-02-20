## Copyright 2014-2015 Oliver Heimlich
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
## @deftypefn {Function File} {} log10 (@var{X})
## 
## Compute the decimal (base-10) logarithm.
##
## The function is only defined where @var{X} is positive.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## log10 (infsupdec (2))
##   @result{} [.30102999566398114, .3010299956639812]_com
## @end group
## @end example
## @seealso{@@infsupdec/pow10, @@infsupdec/log, @@infsupdec/log2}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-13

function result = log10 (x)

if (nargin ~= 1)
    print_usage ();
    return
endif

if (isnai (x))
    result = x;
    return
endif

result = infsupdec (log10 (intervalpart (x)));
result.dec = mindec (result.dec, x.dec);

## log10 is continuous everywhere, but defined for x > 0 only
result.dec (not (interior (x, infsup(0, inf)))) = "trv";

endfunction

%!test "from the documentation string";
%! assert (isequal (log10 (infsupdec (2)), infsupdec ("[0x1.34413509F79FEp-2, 0x1.34413509F79FFp-2]")));
