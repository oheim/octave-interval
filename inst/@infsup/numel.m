## Copyright 2014-2016,2018 Oliver Heimlich
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
## @defmethod {@@infsup} numel (@var{A})
## @defmethodx {@@infsup} numel (@var{A}, @var{idx1}, @var{idx2}, @dots{})
##
## Return the number of elements in the interval object @var{A}.
##
## Optionally, if indices @var{idx1}, @var{idx2}, @dots{} are supplied, return
## the number of elements that would result from indexing
## @code{A(idx1, idx2, @dots{})}.
## @seealso{@@infsup/length, @@infsup/size, @@infsup/rows, @@infsup/columns, @@infsup/end}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-29

function result = numel (a, varargin)

  if (not (isa (a, "infsup")))
    error ("invalid use of interval as indexing parameter to numel ()")
  endif

  result = numel (a.inf(varargin{:}));

endfunction

%!assert (numel (infsup ([])), 0);
%!assert (numel (infsup (0)), 1);
%!assert (numel (infsup (zeros (3, 1))), 3);
%!assert (numel (infsup (zeros (1, 4))), 4);
%!assert (numel (infsup (zeros (3, 4))), 12);

%!assert (numel (infsup (ones (2, 3)), 3:5), 3);
%!assert (numel (infsup (ones (2, 3)), ":", 2), 2);
%!assert (numel (infsup (ones (2, 3)), 2, ":"), 3);

%!# numel is called implicitly during this subsref expression (see bug #53375)
%!assert (infsup ()(:).inf, inf);

%!error <invalid use> numel (1, infsup(1));