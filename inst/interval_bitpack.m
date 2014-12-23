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
## @deftypefn {Interchange encoding} {} interval_bitpack (@var{X})
## 
## Convert bit encoding @var{X} into interval.
##
## The encoding is in big-endian byte order.  However, bits are in increasing
## order.
##
## @seealso{bitunpack}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-12-23

function result = interval_bitpack (x)

switch size (x, 2)
    case 128 # (inf, sup)
        u = bitpack (x (:, 1 : 64)' (:), 'double');
        l = bitpack (x (:, 65 : 128)' (:), 'double');
        result = infsup (l, u);
    
    case 136 # (inf, sup, dec)
        d = bitpack (x (:, 1 : 8)' (:), 'uint8');
        u = bitpack (x (:, 9 : 72)' (:), 'double');
        l = bitpack (x (:, 73 : 136)' (:), 'double');
        
        dec = cell (size (x, 1), 1);
        dec (d == 4) = 'trv';
        dec (d == 8) = 'def';
        dec (d == 12) = 'dac';
        dec (d == 16) = 'com';
        
        result = infsupdec (l, u, dec);
            
    otherwise
        error ('interval_bitpack: invalid bit-length, expected: 128 or 136')
endswitch

endfunction
