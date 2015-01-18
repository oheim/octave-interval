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
## @documentencoding utf-8
## @deftypefn {Function File} {@var{S} =} intervaltotext (@var{X})
## @deftypefnx {Function File} {@var{S} =} intervaltotext (@var{X}, @var{FORMAT})
## 
## Build an approximate representation of the interval @var{X}.
## 
## The interval boundaries are stored in binary floating point format and are
## converted to decimal or hexadecimal format with possible precision loss.  If
## output is not exact, the boundaries are rounded accordingly (e. g. the upper
## boundary is rounded towards infinite for output representation).
## 
## Enough digits are used to ensure separation of subsequent floting point
## numbers.  The exact decimal format may produce a lot of digits.
##
## Possible values for @var{FORMAT} are: @code{decimal} (default),
## @code{exact decimal}, @code{exact hexadecimal}
## 
## @comment DO NOT SYNCHRONIZE DOCUMENTATION STRING
## Accuracy: For all intervals @var{X} is an accurate subset of
## @code{infsupdec (intervaltotext (@var{X}))}.
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-12

function [s, isexact] = intervaltotext (x, format)

if (nargin < 2)
    format = "decimal";
endif

if (isnai (x))
    s = "[NaI]";
    isexact = true ();
else
    ## Using intervalpart we can call the superclass' method.
    ## In later GNU Octave versions it is also possible to call
    ## intervaltotext@infsup (x, format);
    [s, isexact] = intervaltotext (intervalpart (x), format);
    s = strcat (s, "_", x.dec {1});
endif

endfunction