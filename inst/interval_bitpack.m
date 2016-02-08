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
## @defun interval_bitpack (@var{X})
## 
## Decode an interval from its interchange format.
##
## The input must either be a matrix of n × 128 bits for n bare intervals, or a
## matrix of n × 136 bits for n decorated intervals.  Bits are in increasing
## order.  Byte order depends on the system's endianness.  First 8 bytes are
## used for the lower interval boundary, next 8 bytes are used for the upper
## interval boundary, (optionally) last byte is used for the decoration.
##
## The result is a row vector of intervals.
##
## Accuracy: For all valid interchange encodings the following equation holds:
## @code{@var{X} == bitunpack (interval_bitpack (@var{X}))}.
##
## @seealso{@@infsup/bitunpack, @@infsupdec/bitunpack}
## @end defun

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-12-23

function result = interval_bitpack (x)

if (nargin ~= 1)
    print_usage ();
    return
endif
if (not (islogical (x)))
    ## Built-in function bitpack will fail on other data types
    error ("interval:InvalidOperand", ...
           ['interval_bitpack: parameter must be a bool matrix, ' ...
            'was: ' typeinfo(x)])
endif

switch size (x, 2)
    case 128 # (inf, sup)
        l = bitpack (x (:, 1 : 64)' (:), 'double');
        u = bitpack (x (:, 65 : 128)' (:), 'double');
        result = infsup (l, u);
    
    case 136 # (inf, sup, dec)
        l = bitpack (x (:, 1 : 64)' (:), 'double');
        u = bitpack (x (:, 65 : 128)' (:), 'double');
        d = bitpack (x (:, 129 : 136)' (:), 'uint8');
        
        dec = cell (size (x, 1), 1);
        dec (d == 4) = 'trv';
        dec (d == 8) = 'def';
        dec (d == 12) = 'dac';
        dec (d == 16) = 'com';
        
        result = infsupdec (l, u, dec);
        
    otherwise
        error ("interval:InvalidOperand", ...
               ['interval_bitpack: invalid bit-length, ' ...
                'expected: 128 or 136, ' ...
                'was: ' num2str(size (x, 2))])
endswitch

endfunction
%!test "bare";
%!  littleendian = bitunpack (uint16 (1))(1);
%!  b = zeros (1, 128);
%!  if (littleendian)
%!    b([52, 63, 117, 127]) = 1;
%!  else
%!    b([7, 12, 71, 77]) = 1;
%!  endif
%!  decoded = interval_bitpack (logical (b));
%!  assert (eq (decoded, infsup (3, 4)));
%!test "decorated";
%!  littleendian = bitunpack (uint16 (1))(1);
%!  b = zeros (1, 136);
%!  if (littleendian)
%!    b([52, 63, 117, 127, 133]) = 1;
%!  else
%!    b([7, 12, 71, 77, 133]) = 1;
%!  endif
%!  decoded = interval_bitpack (logical (b));
%!  assert (eq (decoded, infsupdec (3, 4)));
