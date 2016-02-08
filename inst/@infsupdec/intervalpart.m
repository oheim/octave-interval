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
## @deftypemethod {@@infsupdec} {@var{S} =} intervalpart (@var{X})
## 
## Return the bare interval for the decorated interval @var{X}.
##
## @seealso{@@infsupdec/decorationpart}
## @end deftypemethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-12

function bare = intervalpart (x)

if (nargin ~= 1)
    print_usage ();
    return
endif

if (isnai (x))
    error ("interval:IntvlPartOfNaI", "intervalpart: NaI has no interval part")
endif

## This also works for the empty interval
bare = infsup (inf (x), sup (x));

endfunction

%!assert (intervalpart (infsupdec (2, 3)) == infsup (2, 3));
