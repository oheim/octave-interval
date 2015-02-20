##
## Copyright 2015 Oliver Heimlich
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
##
%! ## Test library imports
%!function s = to_string (x)
%!    if (isnumeric (x))
%!        s = num2str (x);
%!    elseif (isa (x, 'infsup'))
%!        s = intervaltotext (x);
%!    else
%!        # x probably is a char.
%!        s = x;
%!    endif
%!endfunction
%
%!function n = decval (dec)
%! n = find (strcmp (dec, {"ill", "trv", "def", "dac", "com"}));
%!endfunction

%!test "minimal.atan2_test";
%! assert (all (eq (...
%!    atan2 (infsup (), infsup ()), ...
%!    infsup ())))
%! assert (all (eq (...
%!    atan2 (infsup (), infsup (-inf, inf)), ...
%!    infsup ())))
%! assert (all (eq (...
%!    atan2 (infsup (-inf, inf), infsup ()), ...
%!    infsup ())))
%! assert (all (eq (...
%!    atan2 (infsup (0.0, 0.0), infsup (0.0, 0.0)), ...
%!    infsup ())))
%! assert (all (eq (...
%!    atan2 (infsup (-inf, inf), infsup (-inf, inf)), ...
%!    infsup ("-0x1.921FB54442D19p1", "+0x1.921FB54442D19p1"))))
%! assert (all (eq (...
%!    atan2 (infsup (0.0, 0.0), infsup (-inf, 0.0)), ...
%!    infsup ("0x1.921FB54442D18p1", "0x1.921FB54442D19p1"))))
%! assert (all (eq (...
%!    atan2 (infsup (0.0, 0.0), infsup (0.0, inf)), ...
%!    infsup (0.0, 0.0))))
%! assert (all (eq (...
%!    atan2 (infsup (0.0, inf), infsup (0.0, 0.0)), ...
%!    infsup ("0x1.921FB54442D18p0", "0x1.921FB54442D19p0"))))
%! assert (all (eq (...
%!    atan2 (infsup (-inf, 0.0), infsup (0.0, 0.0)), ...
%!    infsup ("-0x1.921FB54442D19p0", "-0x1.921FB54442D18p0"))))
%! assert (all (eq (...
%!    atan2 (infsup ("-0x1p-1022", 0.0), infsup ("-0x1p-1022", "-0x1p-1022")), ...
%!    infsup ("-0x1.921FB54442D19p1", "+0x1.921FB54442D19p1"))))
%! assert (all (eq (...
%!    atan2 (infsup (1.0, 1.0), infsup (-1.0, -1.0)), ...
%!    infsup ("0x1.2D97C7F3321D2p1", "0x1.2D97C7F3321D3p1"))))
%! assert (all (eq (...
%!    atan2 (infsup (1.0, 1.0), infsup (1.0, 1.0)), ...
%!    infsup ("0x1.921FB54442D18p-1", "0x1.921FB54442D19p-1"))))
%! assert (all (eq (...
%!    atan2 (infsup (-1.0, -1.0), infsup (1.0, 1.0)), ...
%!    infsup ("-0x1.921FB54442D19p-1", "-0x1.921FB54442D18p-1"))))
%! assert (all (eq (...
%!    atan2 (infsup (-1.0, -1.0), infsup (-1.0, -1.0)), ...
%!    infsup ("-0x1.2D97C7F3321D3p1", "-0x1.2D97C7F3321D2p1"))))
%! assert (all (eq (...
%!    atan2 (infsup ("-0x1p-1022", "0x1p-1022"), infsup ("-0x1p-1022", "-0x1p-1022")), ...
%!    infsup ("-0x1.921FB54442D19p1", "+0x1.921FB54442D19p1"))))
%! assert (all (eq (...
%!    atan2 (infsup ("-0x1p-1022", "0x1p-1022"), infsup ("0x1p-1022", "0x1p-1022")), ...
%!    infsup ("-0x1.921FB54442D19p-1", "+0x1.921FB54442D19p-1"))))
%! assert (all (eq (...
%!    atan2 (infsup ("-0x1p-1022", "-0x1p-1022"), infsup ("-0x1p-1022", "0x1p-1022")), ...
%!    infsup ("-0x1.2D97C7F3321D3p1", "-0x1.921FB54442D18p-1"))))
%! assert (all (eq (...
%!    atan2 (infsup ("0x1p-1022", "0x1p-1022"), infsup ("-0x1p-1022", "0x1p-1022")), ...
%!    infsup ("0x1.921FB54442D18p-1", "0x1.2D97C7F3321D3p1"))))
%! assert (all (eq (...
%!    atan2 (infsup (-2.0, 2.0), infsup (-3.0, -1.0)), ...
%!    infsup ("-0x1.921FB54442D19p1", "+0x1.921FB54442D19p1"))))
%! assert (all (eq (...
%!    atan2 (infsup (0.0, 2.0), infsup (-3.0, -1.0)), ...
%!    infsup ("0x1.0468A8ACE4DF6p1", "0x1.921FB54442D19p1"))))
%! assert (all (eq (...
%!    atan2 (infsup (1.0, 3.0), infsup (-3.0, -1.0)), ...
%!    infsup ("0x1.E47DF3D0DD4Dp0", "0x1.68F095FDF593Dp1"))))
%! assert (all (eq (...
%!    atan2 (infsup (1.0, 3.0), infsup (-2.0, 0.0)), ...
%!    infsup ("0x1.921FB54442D18p0", "0x1.56C6E7397F5AFp1"))))
%! assert (all (eq (...
%!    atan2 (infsup (1.0, 3.0), infsup (-2.0, 2.0)), ...
%!    infsup ("0x1.DAC670561BB4Fp-2", "0x1.56C6E7397F5AFp1"))))
%! assert (all (eq (...
%!    atan2 (infsup (1.0, 3.0), infsup (0.0, 2.0)), ...
%!    infsup ("0x1.DAC670561BB4Fp-2", "0x1.921FB54442D19p0"))))
%! assert (all (eq (...
%!    atan2 (infsup (1.0, 3.0), infsup (1.0, 3.0)), ...
%!    infsup ("0x1.4978FA3269EE1p-2", "0x1.3FC176B7A856p0"))))
%! assert (all (eq (...
%!    atan2 (infsup (0.0, 2.0), infsup (1.0, 3.0)), ...
%!    infsup ("0x0p0", "0x1.1B6E192EBBE45p0"))))
%! assert (all (eq (...
%!    atan2 (infsup (-2.0, 2.0), infsup (1.0, 3.0)), ...
%!    infsup ("-0x1.1B6E192EBBE45p0", "+0x1.1B6E192EBBE45p0"))))
%! assert (all (eq (...
%!    atan2 (infsup (-2.0, 0.0), infsup (1.0, 3.0)), ...
%!    infsup ("-0x1.1B6E192EBBE45p0", "0x0p0"))))
%! assert (all (eq (...
%!    atan2 (infsup (-3.0, -1.0), infsup (1.0, 3.0)), ...
%!    infsup ("-0x1.3FC176B7A856p0", "-0x1.4978FA3269EE1p-2"))))
%! assert (all (eq (...
%!    atan2 (infsup (-3.0, -1.0), infsup (0.0, 2.0)), ...
%!    infsup ("-0x1.921FB54442D19p0", "-0x1.DAC670561BB4Fp-2"))))
%! assert (all (eq (...
%!    atan2 (infsup (-3.0, -1.0), infsup (-2.0, 2.0)), ...
%!    infsup ("-0x1.56C6E7397F5AFp1", "-0x1.DAC670561BB4Fp-2"))))
%! assert (all (eq (...
%!    atan2 (infsup (-3.0, -1.0), infsup (-2.0, 0.0)), ...
%!    infsup ("-0x1.56C6E7397F5AFp1", "-0x1.921FB54442D18p0"))))
%! assert (all (eq (...
%!    atan2 (infsup (-3.0, -1.0), infsup (-3.0, -1.0)), ...
%!    infsup ("-0x1.68F095FDF593Dp1", "-0x1.E47DF3D0DD4Dp0"))))
%! assert (all (eq (...
%!    atan2 (infsup (-2.0, 0.0), infsup (-3.0, -1.0)), ...
%!    infsup ("-0x1.921FB54442D19p1", "+0x1.921FB54442D19p1"))))
%! assert (all (eq (...
%!    atan2 (infsup (-5.0, 0.0), infsup (-5.0, 0.0)), ...
%!    infsup ("-0x1.921FB54442D19p1", "+0x1.921FB54442D19p1"))))
%! assert (all (eq (...
%!    atan2 (infsup (0.0, 5.0), infsup (-5.0, 0.0)), ...
%!    infsup ("0x1.921FB54442D18p0", "0x1.921FB54442D19p1"))))
%! assert (all (eq (...
%!    atan2 (infsup (0.0, 5.0), infsup (0.0, 5.0)), ...
%!    infsup ("0x0p0", "0x1.921FB54442D19p0"))))
%! assert (all (eq (...
%!    atan2 (infsup (-5.0, 0.0), infsup (0.0, 5.0)), ...
%!    infsup ("-0x1.921FB54442D19p0", "0x0p0"))))
