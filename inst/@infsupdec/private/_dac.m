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
## @defvr Constant _dac
## Return numeric representation of the defined-and-continuous decoration
## @end defvr

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2015-04-18

function d = _dac ()
## See IEEE Std 1788-2015 14.4 Interchange representations and encodings
persistent d = uint8 (12);
endfunction
