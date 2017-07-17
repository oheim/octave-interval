## Copyright 2015-2016 Oliver Heimlich
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
## @defmethod {@@infsupdec} gammaln (@var{X})
##
## Compute the logarithm of the gamma function for positive arguments.
##
## @tex
## $$
##  {\rm gammaln} (x) = \log \int_0^\infty t^{x-1} \exp (-t) dt
## $$
## @end tex
## @ifnottex
## @group
## @verbatim
##                    ∞
##                   /
## gammaln (x) = log | t^(x-1) exp (-t) dt
##                   /
##                  0
## @end verbatim
## @end group
## @end ifnottex
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## gammaln (infsupdec (1.5))
##   @result{} ans ⊂ [-0.12079, -0.12078]_com
## @end group
## @end example
## @seealso{@@infsupdec/psi, @@infsupdec/gamma, @@infsupdec/factorial}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2015-02-28

function result = gammaln (x)

  if (nargin ~= 1)
    print_usage ();
    return
  endif

  result = newdec (gammaln (x.infsup));

  ## gammaln is continuous everywhere, but defined for x > 0 only
  persistent domain_hull = infsup (0, inf);
  result.dec(not (interior (x.infsup, domain_hull))) = _trv ();

  result.dec = min (result.dec, x.dec);

endfunction

%!assert (isequal (gammaln (infsupdec (-inf, inf)), infsupdec ("[-0x1.F19B9BCC38A42p-4, +Inf]_trv")));

%!# from the documentation string
%!assert (isequal (gammaln (infsupdec (1.5)), infsupdec ("[-0x1.EEB95B094C192p-4, -0x1.EEB95B094C191p-4]_com")));
