## Copyright 2018 Oliver Heimlich
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
## @defmethod {@@infsup} sprintf (@var{template}, @var{X})
##
## Convert interval @var{X} under the control of a template string
## @var{template} to a string with interval literals.
##
## See @command{help intervaltotext} for the syntax of the template string.
##
## @example
## @group
## sprintf ("The result lies within the box %[4g].\n", infsup (2, 3))
##   @result{} ans = The result lies within the box [   2,    3].
## @end group
## @end example
##
## @seealso{intervaltotext, @@infsup/printf, @@infsup/fprintf}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2018-06-30

function s = sprintf (template, x)

  if (nargin ~= 2)
    print_usage ();
    return
  endif

  [template, literals] = printf_prepare (template, x);

  s = sprintf (template, literals{:});

endfunction

%!assert (sprintf ("%g", infsup ("pi")), "3.14159 3.1416");
