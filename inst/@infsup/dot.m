## Copyright 2014-2016 Oliver Heimlich
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
## @defmethod {@@infsup} dot (@var{X}, @var{Y})
## @defmethodx {@@infsup} dot (@var{X}, @var{Y}, @var{DIM})
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
## dot ([infsup(1), 2, 3], [infsup(2), 3, 4])
##   @result{} ans = [20]
## @end group
## @group
## dot (infsup ([realmax; realmin; realmax]), [1; -1; -1], 1)
##   @result{} ans ⊂ [-2.2251e-308, -2.225e-308]
## @end group
## @end example
## @seealso{@@infsup/plus, @@infsup/sum, @@infsup/times, @@infsup/sumabs, @@infsup/sumsq}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-26

function x = dot (x, y, dim)

  if (nargin < 2 || nargin > 3)
    print_usage ();
    return
  endif

  if (not (isa (x, "infsup")))
    x = infsup (x);
  endif
  if (not (isa (y, "infsup")))
    y = infsup (y);
  endif
  if (nargin < 3)
    if (isvector (x.inf) && isvector (y.inf))
      ## Align vectors along common dimension
      dim = 1;
      x = vec (x, dim);
      y = vec (y, dim);
    else
      ## Try to find non-singleton dimension
      xsize = size (x.inf);
      ysize = size (y.inf);
      xsize(end+1:ndims (y)) = 1;
      ysize(end+1:ndims (x)) = 1;
      dim = find (and (xsize ~= 1, ysize ~= 1), 1);
      if (isempty (dim))
        dim = 1;
      endif
    endif
  endif

  [l u] = mpfr_vector_dot_d (x.inf, y.inf, x.sup, y.sup, dim);

  l(l == 0) = -0;

  x.inf = l;
  x.sup = u;

endfunction

%!# matrix × matrix
%!assert (dot (infsup (magic (3)), magic (3)) == [89, 107, 89]);
%!assert (dot (infsup (magic (3)), magic (3), 1) == [89, 107, 89]);
%!assert (dot (infsup (magic (3)), magic (3), 2) == [101; 83; 101]);

%!# matrix × vector
%!assert (dot (infsup (magic (3)), [1, 2, 3]) == [28; 34; 28]);
%!assert (dot (infsup (magic (3)), [1, 2, 3], 1) == [15, 30, 45]);
%!assert (dot (infsup (magic (3)), [1, 2, 3], 2) == [28; 34; 28]);
%!assert (dot (infsup (magic (3)), [1; 2; 3]) == [26, 38, 26]);
%!assert (dot (infsup (magic (3)), [1; 2; 3], 1) == [26, 38, 26]);
%!assert (dot (infsup (magic (3)), [1; 2; 3], 2) == [15; 30; 45]);

%!# matrix × scalar
%!assert (dot (infsup (magic (3)), 42) == [630, 630, 630]);
%!assert (dot (infsup (magic (3)), 42, 1) == [630, 630, 630]);
%!assert (dot (infsup (magic (3)), 42, 2) == [630; 630; 630]);

%!# vector x vector
%!assert (dot (infsup([1, 2, 3]), [4, 5, 6]) == 32);
%!assert (dot (infsup([1, 2, 3]), [4, 5, 6], 1) == [4, 10, 18]);
%!assert (dot (infsup([1, 2, 3]), [4, 5, 6], 2) == 32);
%!assert (dot (infsup([1; 2; 3]), [4; 5; 6]) == 32);
%!assert (dot (infsup([1; 2; 3]), [4; 5; 6], 1) == 32);
%!assert (dot (infsup([1; 2; 3]), [4; 5; 6], 2) == [4; 10; 18]);

%!# vector × scalar
%!assert (dot (infsup ([1, 2, 3]), 42) == 252);
%!assert (dot (infsup ([1, 2, 3]), 42, 1) == [42, 84, 126]);
%!assert (dot (infsup ([1, 2, 3]), 42, 2) == 252);
%!assert (dot (infsup ([1; 2; 3]), 42) == 252);
%!assert (dot (infsup ([1; 2; 3]), 42, 1) == 252);
%!assert (dot (infsup ([1; 2; 3]), 42, 2) == [42; 84; 126]);

%!# N-dimensional arrays
%!test
%!  x = infsup (reshape (1:24, 2, 3, 4));
%!  y = infsup (2.*ones (2, 3, 4));
%!  assert (dot (x, y, 3) == infsup ([80, 96, 112; 88, 104, 120]))
%!test
%!  x = infsup (ones (2, 2, 2, 2));
%!  y = infsup (1);
%!  assert (size (dot (x, y)), [1, 2, 2, 2]);
%!  assert (size (dot (x, y, 1)), [1, 2, 2, 2]);
%!  assert (size (dot (x, y, 2)), [2, 1, 2, 2]);
%!  assert (size (dot (x, y, 3)), [2, 2, 1, 2]);
%!  assert (size (dot (x, y, 4)), [2, 2, 2]);
%!  assert (size (dot (x, y, 5)), [2, 2, 2, 2]);


%!# from the documentation string
%!assert (dot ([infsup(1), 2, 3], [infsup(2), 3, 4]) == 20);
%!assert (dot (infsup ([realmax; realmin; realmax]), [1; -1; -1], 1) == -realmin);
