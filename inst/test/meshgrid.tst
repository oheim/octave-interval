## Copyright 2017 Oliver Heimlich
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

## We use Octave's builtin meshgrid function for intervals
## (there is no @infsup/meshgrid method) and want to verify that it works
## as desired.

%!test
%! X = 0 : 3;
%! [IX, IY] = meshgrid (infsup (X));
%! [XX, YY] = meshgrid (X);
%! assert (isequal (IX, infsup (XX)));
%! assert (isequal (IY, infsup (YY)));

%!test
%! X = 0 : 3;
%! Y = 7 : 8;
%! [IX, IY] = meshgrid (infsup (X), infsup (Y));
%! [XX, YY] = meshgrid (X, Y);
%! assert (isequal (IX, infsup (XX)));
%! assert (isequal (IY, infsup (YY)));

%!test
%! X = 1 : 5;
%! [IX, IY, IZ] = meshgrid (infsup (X));
%! [XX, YY, ZZ] = meshgrid (X);
%! assert (isequal (IX, infsup (XX)));
%! assert (isequal (IY, infsup (YY)));
%! assert (isequal (IZ, infsup (ZZ)));

%!test
%! X = 20 : 22;
%! Y = 78 : 90;
%! Z = 12 : 16;
%! [IX, IY, IZ] = meshgrid (infsup (X), infsup (Y), infsup (Z));
%! [XX, YY, ZZ] = meshgrid (X, Y, Z);
%! assert (isequal (IX, infsup (XX)));
%! assert (isequal (IY, infsup (YY)));
%! assert (isequal (IZ, infsup (ZZ)));

%!test
%! X = 0 : 3;
%! Y = 7 : 8;
%! [IX, IY] = meshgrid (infsup (X), Y);
%! [XX, YY] = meshgrid (X, Y);
%! assert (isequal (IX, infsup (XX)));
%! assert (isequal (IY, YY));

%!test
%! X = 0 : 3;
%! Y = 7 : 8;
%! [IX, IY] = meshgrid (X, infsup (Y));
%! [XX, YY] = meshgrid (X, Y);
%! assert (isequal (IX, XX));
%! assert (isequal (IY, infsup (YY)));

%!test
%! X = 20 : 22;
%! Y = 78 : 90;
%! Z = 12 : 16;
%! [IX, IY, IZ] = meshgrid (infsup (X), infsup (Y), Z);
%! [XX, YY, ZZ] = meshgrid (X, Y, Z);
%! assert (isequal (IX, infsup (XX)));
%! assert (isequal (IY, infsup (YY)));
%! assert (isequal (IZ, ZZ));

%!test
%! X = 20 : 22;
%! Y = 78 : 90;
%! Z = 12 : 16;
%! [IX, IY, IZ] = meshgrid (infsup (X), Y, infsup (Z));
%! [XX, YY, ZZ] = meshgrid (X, Y, Z);
%! assert (isequal (IX, infsup (XX)));
%! assert (isequal (IY, YY));
%! assert (isequal (IZ, infsup (ZZ)));

%!test
%! X = 20 : 22;
%! Y = 78 : 90;
%! Z = 12 : 16;
%! [IX, IY, IZ] = meshgrid (X, infsup (Y), infsup (Z));
%! [XX, YY, ZZ] = meshgrid (X, Y, Z);
%! assert (isequal (IX, XX));
%! assert (isequal (IY, infsup (YY)));
%! assert (isequal (IZ, infsup (ZZ)));

%!test
%! X = 20 : 22;
%! Y = 78 : 90;
%! Z = 12 : 16;
%! [IX, IY, IZ] = meshgrid (infsup (X), Y, Z);
%! [XX, YY, ZZ] = meshgrid (X, Y, Z);
%! assert (isequal (IX, infsup (XX)));
%! assert (isequal (IY, YY));
%! assert (isequal (IZ, ZZ));

%!test
%! X = 20 : 22;
%! Y = 78 : 90;
%! Z = 12 : 16;
%! [IX, IY, IZ] = meshgrid (X, infsup (Y), Z);
%! [XX, YY, ZZ] = meshgrid (X, Y, Z);
%! assert (isequal (IX, XX));
%! assert (isequal (IY, infsup (YY)));
%! assert (isequal (IZ, ZZ));

%!test
%! X = 20 : 22;
%! Y = 78 : 90;
%! Z = 12 : 16;
%! [IX, IY, IZ] = meshgrid (X, Y, infsup (Z));
%! [XX, YY, ZZ] = meshgrid (X, Y, Z);
%! assert (isequal (IX, XX));
%! assert (isequal (IY, YY));
%! assert (isequal (IZ, infsup (ZZ)));

%!test
%! X = 0 : 3;
%! [IX, IY] = meshgrid (infsupdec (X));
%! [XX, YY] = meshgrid (X);
%! assert (isequal (IX, infsupdec (XX)));
%! assert (isequal (IY, infsupdec (YY)));

%!test
%! X = 0 : 3;
%! Y = 7 : 8;
%! [IX, IY] = meshgrid (infsupdec (X), infsupdec (Y));
%! [XX, YY] = meshgrid (X, Y);
%! assert (isequal (IX, infsupdec (XX)));
%! assert (isequal (IY, infsupdec (YY)));

%!test
%! X = 1 : 5;
%! [IX, IY, IZ] = meshgrid (infsupdec (X));
%! [XX, YY, ZZ] = meshgrid (X);
%! assert (isequal (IX, infsupdec (XX)));
%! assert (isequal (IY, infsupdec (YY)));
%! assert (isequal (IZ, infsupdec (ZZ)));

%!test
%! X = 20 : 22;
%! Y = 78 : 90;
%! Z = 12 : 16;
%! [IX, IY, IZ] = meshgrid (infsupdec (X), infsupdec (Y), infsupdec (Z));
%! [XX, YY, ZZ] = meshgrid (X, Y, Z);
%! assert (isequal (IX, infsupdec (XX)));
%! assert (isequal (IY, infsupdec (YY)));
%! assert (isequal (IZ, infsupdec (ZZ)));

%!test
%! X = 0 : 3;
%! Y = 7 : 8;
%! [IX, IY] = meshgrid (infsupdec (X), Y);
%! [XX, YY] = meshgrid (X, Y);
%! assert (isequal (IX, infsupdec (XX)));
%! assert (isequal (IY, YY));

%!test
%! X = 0 : 3;
%! Y = 7 : 8;
%! [IX, IY] = meshgrid (X, infsupdec (Y));
%! [XX, YY] = meshgrid (X, Y);
%! assert (isequal (IX, XX));
%! assert (isequal (IY, infsupdec (YY)));

%!test
%! X = 20 : 22;
%! Y = 78 : 90;
%! Z = 12 : 16;
%! [IX, IY, IZ] = meshgrid (infsupdec (X), infsupdec (Y), Z);
%! [XX, YY, ZZ] = meshgrid (X, Y, Z);
%! assert (isequal (IX, infsupdec (XX)));
%! assert (isequal (IY, infsupdec (YY)));
%! assert (isequal (IZ, ZZ));

%!test
%! X = 20 : 22;
%! Y = 78 : 90;
%! Z = 12 : 16;
%! [IX, IY, IZ] = meshgrid (infsupdec (X), Y, infsupdec (Z));
%! [XX, YY, ZZ] = meshgrid (X, Y, Z);
%! assert (isequal (IX, infsupdec (XX)));
%! assert (isequal (IY, YY));
%! assert (isequal (IZ, infsupdec (ZZ)));

%!test
%! X = 20 : 22;
%! Y = 78 : 90;
%! Z = 12 : 16;
%! [IX, IY, IZ] = meshgrid (X, infsupdec (Y), infsupdec (Z));
%! [XX, YY, ZZ] = meshgrid (X, Y, Z);
%! assert (isequal (IX, XX));
%! assert (isequal (IY, infsupdec (YY)));
%! assert (isequal (IZ, infsupdec (ZZ)));

%!test
%! X = 20 : 22;
%! Y = 78 : 90;
%! Z = 12 : 16;
%! [IX, IY, IZ] = meshgrid (infsupdec (X), Y, Z);
%! [XX, YY, ZZ] = meshgrid (X, Y, Z);
%! assert (isequal (IX, infsupdec (XX)));
%! assert (isequal (IY, YY));
%! assert (isequal (IZ, ZZ));

%!test
%! X = 20 : 22;
%! Y = 78 : 90;
%! Z = 12 : 16;
%! [IX, IY, IZ] = meshgrid (X, infsupdec (Y), Z);
%! [XX, YY, ZZ] = meshgrid (X, Y, Z);
%! assert (isequal (IX, XX));
%! assert (isequal (IY, infsupdec (YY)));
%! assert (isequal (IZ, ZZ));

%!test
%! X = 20 : 22;
%! Y = 78 : 90;
%! Z = 12 : 16;
%! [IX, IY, IZ] = meshgrid (X, Y, infsupdec (Z));
%! [XX, YY, ZZ] = meshgrid (X, Y, Z);
%! assert (isequal (IX, XX));
%! assert (isequal (IY, YY));
%! assert (isequal (IZ, infsupdec (ZZ)));

%!test
%! X = 0 : 3;
%! Y = 7 : 8;
%! [IX, IY] = meshgrid (infsupdec (X), infsup (Y));
%! [XX, YY] = meshgrid (X, Y);
%! assert (isequal (IX, infsupdec (XX)));
%! assert (isequal (IY, infsup (YY)));

%!test
%! X = 0 : 3;
%! Y = 7 : 8;
%! [IX, IY] = meshgrid (infsup (X), infsupdec (Y));
%! [XX, YY] = meshgrid (X, Y);
%! assert (isequal (IX, infsup (XX)));
%! assert (isequal (IY, infsupdec (YY)));

%!test
%! X = 20 : 22;
%! Y = 78 : 90;
%! Z = 12 : 16;
%! [IX, IY, IZ] = meshgrid (infsupdec (X), infsupdec (Y), infsup (Z));
%! [XX, YY, ZZ] = meshgrid (X, Y, Z);
%! assert (isequal (IX, infsupdec (XX)));
%! assert (isequal (IY, infsupdec (YY)));
%! assert (isequal (IZ, infsup (ZZ)));

%!test
%! X = 20 : 22;
%! Y = 78 : 90;
%! Z = 12 : 16;
%! [IX, IY, IZ] = meshgrid (infsupdec (X), infsup (Y), infsupdec (Z));
%! [XX, YY, ZZ] = meshgrid (X, Y, Z);
%! assert (isequal (IX, infsupdec (XX)));
%! assert (isequal (IY, infsup (YY)));
%! assert (isequal (IZ, infsupdec (ZZ)));

%!test
%! X = 20 : 22;
%! Y = 78 : 90;
%! Z = 12 : 16;
%! [IX, IY, IZ] = meshgrid (infsup (X), infsupdec (Y), infsupdec (Z));
%! [XX, YY, ZZ] = meshgrid (X, Y, Z);
%! assert (isequal (IX, infsup (XX)));
%! assert (isequal (IY, infsupdec (YY)));
%! assert (isequal (IZ, infsupdec (ZZ)));

%!test
%! X = 20 : 22;
%! Y = 78 : 90;
%! Z = 12 : 16;
%! [IX, IY, IZ] = meshgrid (infsupdec (X), infsup (Y), infsup (Z));
%! [XX, YY, ZZ] = meshgrid (X, Y, Z);
%! assert (isequal (IX, infsupdec (XX)));
%! assert (isequal (IY, infsup (YY)));
%! assert (isequal (IZ, infsup (ZZ)));

%!test
%! X = 20 : 22;
%! Y = 78 : 90;
%! Z = 12 : 16;
%! [IX, IY, IZ] = meshgrid (infsup (X), infsupdec (Y), infsup (Z));
%! [XX, YY, ZZ] = meshgrid (X, Y, Z);
%! assert (isequal (IX, infsup (XX)));
%! assert (isequal (IY, infsupdec (YY)));
%! assert (isequal (IZ, infsup (ZZ)));

%!test
%! X = 20 : 22;
%! Y = 78 : 90;
%! Z = 12 : 16;
%! [IX, IY, IZ] = meshgrid (infsup (X), infsup (Y), infsupdec (Z));
%! [XX, YY, ZZ] = meshgrid (X, Y, Z);
%! assert (isequal (IX, infsup (XX)));
%! assert (isequal (IY, infsup (YY)));
%! assert (isequal (IZ, infsupdec (ZZ)));

