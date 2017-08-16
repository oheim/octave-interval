## Copyright 2015-2016 Oliver Heimlich
## Copyright 2017 Joel Dahne
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
## @defmethod {@@infsupdec} dot (@var{X}, @var{Y})
## @defmethodx {@@infsupdec} dot (@var{X}, @var{Y}, @var{DIM})
##
## Compute the dot product of two interval vectors.
##
## If @var{X} and @var{Y} are arrays, calculate the dot products along the
## first non-singleton dimension.  If the optional argument @var{DIM} is given,
## calculate the dot products along this dimension.
##
## Conceptually this is equivalent to @code{sum (@var{X} .* @var{Y})}
## but it is computed in such a way that no intermediate round-off
## errors are introduced.
##
## Broadcasting is performed along all dimensions except if @var{X}
## and @var{Y} are both vectors and @var{DIM} is not specified, in
## which case they are aligned along dimension 1.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## dot ([infsupdec(1), 2, 3], [infsupdec(2), 3, 4])
##   @result{} ans = [20]_com
## @end group
## @group
## dot (infsupdec ([realmax; realmin; realmax]), [1; -1; -1], 1)
##   @result{} ans ⊂ [-2.2251e-308, -2.225e-308]_com
## @end group
## @end example
## @seealso{@@infsupdec/plus, @@infsupdec/sum, @@infsupdec/times}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2015-01-31

function result = dot (x, y, dim)

  if (nargin < 2 || nargin > 3)
    print_usage ();
    return
  endif

  if (not (isa (x, "infsupdec")))
    x = infsupdec (x);
  endif
  if (not (isa (y, "infsupdec")))
    y = infsupdec (y);
  endif
  if (nargin < 3)
    if (isvector (x.dec) && isvector (y.dec))
      ## Align vectors along common dimension
      dim = 1;
      x = vec (x, dim);
      y = vec (y, dim);
    else
      ## Try to find non-singleton dimension
      xsize = size (x.dec);
      ysize = size (y.dec);
      xsize(end+1:ndims (y)) = 1;
      ysize(end+1:ndims (x)) = 1;
      dim = find (and (xsize ~= 1, ysize ~= 1), 1);
      if (isempty (dim))
        dim = 1;
      endif
    endif
  endif

  result = newdec (dot (x.infsup, y.infsup, dim));
  warning ("off", "Octave:broadcast", "local");
  if (size (x, dim) > 0 && size (y, dim) > 0)
    result.dec = min (result.dec, ...
                      min (min (x.dec, [], dim), min (y.dec, [], dim)));
  endif
  if (isequal (x, infsupdec ([])) && isequal (y, infsupdec ([])))
    ## Inconsistency, dot (infsupdec ([]), []) = [0]_com
    ## Needs to be handled here for the decoration to work correctly
    result = newdec (result.infsup);
  endif
endfunction

%!# matrix × matrix
%!assert (isequal (dot (infsupdec (magic (3)), magic (3)), infsupdec([89, 107, 89])));
%!assert (isequal (dot (infsupdec (magic (3)), magic (3), 1), infsupdec([89, 107, 89])));
%!assert (isequal (dot (infsupdec (magic (3)), magic (3), 2), infsupdec([101; 83; 101])));

%!# matrix × vector
%!assert (isequal (dot (infsupdec (magic (3)), [1, 2, 3]), infsupdec([28; 34; 28])));
%!assert (isequal (dot (infsupdec (magic (3)), [1, 2, 3], 1), infsupdec([15, 30, 45])));
%!assert (isequal (dot (infsupdec (magic (3)), [1, 2, 3], 2), infsupdec([28; 34; 28])));
%!assert (isequal (dot (infsupdec (magic (3)), [1; 2; 3]), infsupdec([26, 38, 26])));
%!assert (isequal (dot (infsupdec (magic (3)), [1; 2; 3], 1), infsupdec([26, 38, 26])));
%!assert (isequal (dot (infsupdec (magic (3)), [1; 2; 3], 2), infsupdec([15; 30; 45])));

%!# matrix × scalar
%!assert (isequal (dot (infsupdec (magic (3)), 42), infsupdec([630, 630, 630])));
%!assert (isequal (dot (infsupdec (magic (3)), 42, 1), infsupdec([630, 630, 630])));
%!assert (isequal (dot (infsupdec (magic (3)), 42, 2), infsupdec([630; 630; 630])));

%!# vector x vector
%!assert (isequal (dot (infsupdec([1, 2, 3]), [4, 5, 6]), infsupdec(32)));
%!assert (isequal (dot (infsupdec([1, 2, 3]), [4, 5, 6], 1), infsupdec([4, 10, 18])));
%!assert (isequal (dot (infsupdec([1, 2, 3]), [4, 5, 6], 2), infsupdec(32)));
%!assert (isequal (dot (infsupdec([1; 2; 3]), [4; 5; 6]), infsupdec(32)));
%!assert (isequal (dot (infsupdec([1; 2; 3]), [4; 5; 6], 1), infsupdec(32)));
%!assert (isequal (dot (infsupdec([1; 2; 3]), [4; 5; 6], 2), infsupdec([4; 10; 18])));

%!# vector × scalar
%!assert (isequal (dot (infsupdec ([1, 2, 3]), 42), infsupdec(252)));
%!assert (isequal (dot (infsupdec ([1, 2, 3]), 42, 1), infsupdec([42, 84, 126])));
%!assert (isequal (dot (infsupdec ([1, 2, 3]), 42, 2), infsupdec(252)));
%!assert (isequal (dot (infsupdec ([1; 2; 3]), 42), infsupdec(252)));
%!assert (isequal (dot (infsupdec ([1; 2; 3]), 42, 1), infsupdec(252)));
%!assert (isequal (dot (infsupdec ([1; 2; 3]), 42, 2), infsupdec([42; 84; 126])));

%!# empty matrix x empty matrix
%!assert (isequal (dot (infsupdec (ones (0, 2)), infsupdec (ones (0, 2))), infsupdec ([0, 0])));

%!# N-dimensional arrays
%!test
%!  x = infsupdec (reshape (1:24, 2, 3, 4));
%!  y = infsupdec (2.*ones (2, 3, 4));
%!  assert (isequal (dot (x, y, 3), infsupdec ([80, 96, 112; 88, 104, 120])))
%!test
%!  x = infsupdec (ones (2, 2, 2, 2));
%!  y = infsupdec (1);
%!  assert (size (dot (x, y)), [1, 2, 2, 2]);
%!  assert (size (dot (x, y, 1)), [1, 2, 2, 2]);
%!  assert (size (dot (x, y, 2)), [2, 1, 2, 2]);
%!  assert (size (dot (x, y, 3)), [2, 2, 1, 2]);
%!  assert (size (dot (x, y, 4)), [2, 2, 2]);
%!  assert (size (dot (x, y, 5)), [2, 2, 2, 2]);

%!# from the documentation string
%!assert (isequal (dot ([infsupdec(1), 2, 3], [infsupdec(2), 3, 4]), infsupdec (20)));
%!assert (isequal (dot (infsupdec ([realmax; realmin; realmax]), [1; -1; -1], 1), infsupdec (-realmin)));
