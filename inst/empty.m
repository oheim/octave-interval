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
## @defun empty ()
## @defunx empty (@var{N})
## @defunx empty (@var{N}, @var{M})
## @defunx empty (@var{N}, @var{M}, @var{K}, ...)
## @defunx empty ([@var{N} @var{M} ...])
##
## Return the empty interval.
##
## With additional parameters, create an interval vector/matrix/array, which
## comprises empty interval entries.
##
## The empty interval [Empty] contains no real numbers.  All interval functions
## return an empty result if the input is either empty or outside of the
## function's domain.
##
## The empty interval carries the trivial @code{trv} decoration, which denotes
## that the empty interval cannot be the result of a function evaluation for
## a nonempty subset of its domain.
##
## Accuracy: The representation of the empty interval is exact.
##
## @example
## @group
## x = empty ()
##   @result{} x = [Empty]_trv
## inf (x)
##   @result{} ans = Inf
## sup (x)
##   @result{} ans = -Inf
## @end group
## @end example
## @seealso{@@infsup/isempty, entire}
## @end defun

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-09-27

function result = empty (varargin)

  persistent scalar_empty_interval = infsupdec ();

  result = subsref (scalar_empty_interval, ...
                    substruct ("()", {ones(varargin{:})}));

endfunction

%!assert (inf (empty ()), inf);
%!assert (sup (empty ()), -inf);
%!assert (decorationpart (empty ()), {"trv"});
%!assert (inf (empty (5)), inf (5));
%!assert (sup (empty (5)), -inf (5));
%!assert (strcmp (decorationpart (empty (5)), "trv"), true (5));
%!assert (inf (empty (5, 6)), inf (5, 6));
%!assert (sup (empty (5, 6)), -inf (5, 6));
%!assert (strcmp (decorationpart (empty (5, 6)), "trv"), true (5, 6));
%!assert (inf (empty (5, 6, 7)), inf (5, 6, 7));
%!assert (sup (empty (5, 6, 7)), -inf (5, 6, 7));
%!assert (strcmp (decorationpart (empty (5, 6, 7)), "trv"), true (5, 6, 7));
