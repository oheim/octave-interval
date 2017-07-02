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
## @defmethod {@@infsup} sum (@var{X})
## @defmethodx {@@infsup} sum (@var{X}, @var{DIM})
##
## Sum of elements along dimension @var{DIM}.  If @var{DIM} is omitted, it
## defaults to the first non-singleton dimension.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## sum ([infsup(1), pow2(-1074), -1])
##   @result{} ans ⊂ [4.9406e-324, 4.9407e-324]
## infsup (1) + pow2 (-1074) - 1
##   @result{} ans ⊂ [0, 2.2205e-16]
## @end group
## @end example
## @seealso{@@infsup/plus, @@infsup/prod}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-26

function result = sum (x, dim)

  if (nargin > 2)
    print_usage ();
    return
  endif

  if (nargin < 2)
    ## Try to find non-singleton dimension
    dim = find (size (x.inf) ~= 1, 1);
    if (isempty (dim))
      dim = 1;
    endif
  endif

  ## Short-circuit
  if (size (x.inf, dim) == 1)
    result = x;
    return
  endif

  l = mpfr_vector_sum_d (-inf, x.inf, dim);
  u = mpfr_vector_sum_d (+inf, x.sup, dim);

  result = infsup ();
  result.inf = l;
  result.sup = u;

endfunction

%!# from the documentation string
%!assert (sum ([infsup(1), pow2(-1074), -1]) == infsup (pow2 (-1074)));

%!assert (sum (infsup ([])) == 0);

%!# correct use of signed zeros
%!test
%! x = sum (infsup (0));
%! assert (signbit (inf (x)));
%! assert (not (signbit (sup (x))));

%!# N-dimensional arrays
%!assert (sum (infsup (ones (1, 1, 10))) == infsup (10));
%!assert (sum (infsup (ones (1, 1, 10))) == infsup (10));
