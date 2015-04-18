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
## @deftypefn {Function File} {} decorationpart (@var{X})
## 
## Return the decoration of the decorated interval @var{X}.
##
## The decoration is a cell array of character strings and its size equals the
## size of its intervalpart.
##
## @seealso{@@infsupdec/intervalpart}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-12

function dec = decorationpart (x)

if (nargin ~= 1)
    print_usage ();
    return
endif

persistent dec_translation = {...
    "ill", [], [], [], ...
    "trv", [], [], [], ...
    "def", [], [], [], ...
    "dac", [], [], [], ...
    "com"};

dec = cell (size (x.dec));
dec (:) = dec_translation (x.dec (:) + 1);

endfunction

%!assert (decorationpart (infsupdec (3, 4)), {"com"});
%!assert (decorationpart (infsupdec (3, inf)), {"dac"});
%!assert (decorationpart (infsupdec ()), {"trv"});
