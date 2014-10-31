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
## @deftypefn {Interval Function} {} asin (@var{X})
## @cindex IEEE1788 asin
## 
## Compute the inverse sine in radians (arcsine) for each number in
## interval @var{X}.
##
## Accuracy: The result is an accurate enclosure.
##
## @example
## @group
## asin (infsup (.5))
##   @result{} [.5235987755982988, .5235987755982991]
## @end group
## @end example
## @seealso{sin}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-06

function result = asin (x)

l = ulpadd (real (asin (x.inf)), -1);
u = ulpadd (real (asin (x.sup)), 1);

## Make the function tightest for some parameters
pi = infsup ("pi");
l (x.inf <= -1) = inf (-pi) / 2;
nonnegative = (x.inf >= 0);
l (nonnegative) = max (0, l (nonnegative));
u (x.sup >= 1) = sup (pi) / 2;
nonpositive = (x.sup <= 0);
u (nonpositive) = min (0, u (nonpositive));

emptyresult = isempty (x) | x.inf > 1 | x.sup < -1;
l (emptyresult) = inf;
u (emptyresult) = -inf;

result = infsup (l, u);

endfunction