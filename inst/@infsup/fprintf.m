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
## @defmethod {@@infsup} fprintf (@var{fid}, @var{template}, @var{X})
## @defmethodx {@@infsup} fprintf (@var{template}, @var{X})
##
## Write interval @var{X} under the control of a template string
## @var{template} to the file descriptor @code{fid} and return the number of
## characters printed.
##
## If @var{fid} is omitted, the output is written to @code{stdout} making the
## function exactly equivalent to @command{printf}.
##
## See @command{help intervaltotext} for the syntax of the template string.
##
## @example
## @group
## fprintf ("The result lies within the box %[4g].\n", infsup (2, 3))
##   @result{} The result lies within the box [   2,    3].
## @end group
## @end example
##
## @seealso{intervaltotext, @@infsup/printf, @@infsup/sprintf}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2018-06-30

function chars_printed = fprintf (fid, template, x)

  if (nargin < 2 || nargin > 3)
    print_usage ();
    return
  endif

  if (nargin < 3)
    [fid, template, x] = deal (stdout, fid, template);
  endif

  if (isa (fid, "infsup"))
    error ("handle FID must be an output stream");
  endif

  [template, literals] = printf_prepare (template, x);

  if (nargout >= 1)
    chars_printed = fprintf (fid, template, literals{:});
  else
    fprintf (fid, template, literals{:});
  endif

endfunction

%!test
%! if (compare_versions (OCTAVE_VERSION, "4.2", ">="))
%!   assert (evalc ("n = fprintf ('%g', infsup ('pi'));"), "3.14159 3.1416");
%!   assert (n, 14);
%! endif
