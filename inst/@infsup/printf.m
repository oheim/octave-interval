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
## @defmethod {@@infsup} printf (@var{template}, @var{X})
##
## Print interval @var{X} under the control of a template string
## @var{template} to the stream @code{stdout} and return the number of
## characters printed.
##
## See @command{help intervaltotext} for the syntax of the template string.
##
## @example
## @group
## printf ("The result lies within the box %[4g].\n", infsup (2, 3))
##   @result{} The result lies within the box [   2,    3].
## @end group
## @end example
##
## When @var{X} is a vector, matrix, or array of intervals, this function
## cycles through the format template until all the values have been printed.
##
## @example
## @group
## printf ("%5:[g] %5:[g]\n", infsup (pascal (2)))
##   @result{} [ 1 ] [ 1 ]
##     [ 1 ] [ 2 ]
## @end group
## @end example
## @seealso{intervaltotext, @@infsup/fprintf, @@infsup/sprintf}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2018-06-30

function chars_printed = printf (template, x)

  if (nargin ~= 2)
    print_usage ();
    return
  endif

  [template, literals] = printf_prepare (template, x);

  if (nargout >= 1)
    chars_printed = printf (template, literals{:});
  else
    printf (template, literals{:});
  endif

endfunction

%!test
%! if (compare_versions (OCTAVE_VERSION, "4.2", ">="))
%!   assert (evalc ("n = printf ('%g', infsup ('pi'));"), "3.14159 3.1416");
%!   assert (n, 14);
%! endif
