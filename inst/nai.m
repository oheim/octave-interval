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
## @defun nai ()
## 
## Return the ill-formed decorated interval, called NaI (Not an Interval).
##
## Ill-formed intervals are the result of an illegal interval creation, e.g.
## @code{[3, 2]}.  They occur if the @code{infsupdec} constructor is called
## with an invalid input and survive through interval arithmetic computations.
## Boolean comparisons on NaIs return @code{false}, i.e. @code{[NaI] == [NaI]}
## is false.
##
## The interval part of NaI is undefined.  The decoration part of NaI is
## @code{ill}.  The size of NaI is one in each dimension.
##
## The infsup constructor will not produce NaIs, but an error instead.
##
## @example
## @group
## x = nai ()
##   @result{} x = [NaI]
## x + 42
##   @result{} ans = [NaI]
## @end group
## @end example
## @seealso{@@infsupdec/infsupdec}
## @end defun

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2015-02-22

function result = nai ()

if (nargin ~= 0)
    print_usage ();
    return
endif

result = infsupdec ("[nai]");

endfunction

%!assert (isnai (nai ()));
%!error (nai (1));
%!error (intervalpart (nai ()));
%!assert (decorationpart (nai ()), {"ill"});
