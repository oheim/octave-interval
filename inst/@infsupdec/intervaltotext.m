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
## @deftypemethod {@@infsupdec} {@var{S} =} intervaltotext (@var{X})
## @deftypemethodx {@@infsupdec} {@var{S} =} intervaltotext (@var{X}, @var{FORMAT})
## 
## Build an approximate representation of the interval @var{X}.
##
## Output @var{S} is a simple string for scalar intervals, and a cell array of
## strings for interval matrices.
## 
## The interval boundaries are stored in binary floating point format and are
## converted to decimal or hexadecimal format with possible precision loss.  If
## output is not exact, the boundaries are rounded accordingly (e. g. the upper
## boundary is rounded towards infinite for output representation).
## 
## The exact decimal format may produce a lot of digits.
##
## Possible values for @var{FORMAT} are: @code{decimal} (default),
## @code{exact decimal}, @code{exact hexadecimal}, @code{auto}
## 
## Accuracy: For all intervals @var{X} is an accurate subset of
## @code{infsupdec (intervaltotext (@var{X}))}.
## @end deftypemethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-12

function [s, isexact] = intervaltotext (x, format)

if (nargin > 2)
    print_usage ();
    return
endif
if (nargin < 2)
    format = "decimal";
endif

if (isnai (x))
    s = "[NaI]";
    isexact = true ();
    return
endif

[s, isexact] = intervaltotext (intervalpart (x), format);
s = strcat (s, {"_"}, decorationpart (x));
if (isscalar (s))
    s = s {1};
endif

endfunction

%!assert (intervaltotext (infsupdec (1 + eps), "exact decimal"), "[1.0000000000000002220446049250313080847263336181640625]_com");
%!assert (intervaltotext (infsupdec (1 + eps), "exact hexadecimal"), "[0X1.0000000000001P+0]_com");
%!assert (intervaltotext (infsupdec (1 + eps)), "[1.0000000000000002, 1.000000000000001]_com");
%!assert (intervaltotext (infsupdec (1)), "[1]_com");
