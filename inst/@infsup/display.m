## Copyright 2014-2018 Oliver Heimlich
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
## @defmethod {@@infsup} display (@var{X})
##
## Display the variable name and value of interval @var{X}.
##
## Interval boundaries are approximated with faithful decimal numbers.
##
## If @var{X} is a variable, the interval is display together with its variable
## name.  The variable name is followed by an equality sign if all decimal
## boundaries exactly represent the actual boundaries.  Otherwise a subset
## symbol is used instead (this feature is not available on Microsoft Windows).
##
## For non-scalar intervals the size and classification (interval vector,
## interval matrix or interval array) is displayed before the content.
##
## @example
## @group
## display (infsupdec (2));
##   @result{} [2]_com
## @end group
## @end example
## @example
## @group
## x = infsupdec (2); display (x);
##   @result{} x = [2]_com
## @end group
## @end example
## @example
## @group
## y = infsupdec (eps); display (y);
##   @result{} y ⊂ [2.2204e-16, 2.2205e-16]_com
## @end group
## @end example
## @example
## @group
## z = infsupdec (pascal (2)); display (z);
##   @result{} z = 2×2 interval matrix
##      [1]_com   [1]_com
##      [1]_com   [2]_com
## @end group
## @end example
## @seealso{@@infsup/disp, intervaltotext}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-28

function display (x)

  if (nargin ~= 1)
    print_usage ();
    return
  endif

  loose_spacing = __loosespacing__ ();

  global current_print_indent_level;
  save_current_print_indent_level = current_print_indent_level;
  unwind_protect

    label = inputname (1);
    if (isempty (label) && regexp(argn, '^\[\d+,\d+\]$'))
      ## During output of cell array contents
      label = argn;
      ## FIXME: Need access to octave_value::current_print_indent_level
      ## for correctly formatted nested cell array output
      current_print_indent_level = 2;
    else
      current_print_indent_level = 0;
    endif

    line_prefix = " "(ones (1, current_print_indent_level));

    [s, isexact] = disp (x);

    printf (line_prefix);
    if (not (isempty (label)))
      printf (label);
      if (isexact || ispc ())
        printf (" = ");
      else
        ## The Microsoft Windows console does not support this multibyte
        ## character.
        printf (" ⊂ ");
      endif
    endif

    if (isscalar (x))
      ## Scalar interval
      printf (s);
      if (isempty (label))
        printf ("\n");
      endif
      return
    endif

    printf ("%d", size (x, 1))
    if (ispc ())
      printf ("x%d", size (x)(2:end))
    else
      ## The Microsoft Windows console does not support multibyte characters.
      printf ("×%d", size (x)(2:end))
    endif

    if (isvector (x))
      printf (" interval vector");
    elseif (ismatrix (x))
      printf (" interval matrix");
    else
      printf (" interval array")
    endif
    printf ("\n");

    if (not (isempty (s)))
      if (loose_spacing)
        printf ("\n");
      endif

      printf (line_prefix);

      if (current_print_indent_level > 0)
        s = strrep (s, "\n", cstrcat ("\n", line_prefix));
        s(end - current_print_indent_level + 1 : end) = "";
      endif

      printf (s);

      ## FIXME: The built-in display function prints an extra line break,
      ## if called with “display (var name)”—even with compact format
      ## spacing.  We assume that this method is always called for output
      ## after expression evaluation.

      if (loose_spacing)
        printf ("\n");
      endif
    endif
  unwind_protect_cleanup
    current_print_indent_level = save_current_print_indent_level;
  end_unwind_protect

endfunction

%!# Test for the display function are also largely done with the help of the
%!# doctest package.

%!# evalc has been introduced in Octave 4.2

%!test
%! if (compare_versions (OCTAVE_VERSION, "4.2", ">="))
%!   assert (evalc ("display (infsup ())"), "[Empty]\n\n");
%!   assert (evalc ("display (infsupdec ())"), "[Empty]_trv\n\n");
%! endif

%!test
%! if (compare_versions (OCTAVE_VERSION, "4.2", ">="))
%!   assert (evalc ("a = infsup ()"), "a = [Empty]\n");
%!   assert (evalc ("b = infsupdec ()"), "b = [Empty]_trv\n");
%! endif

%!test
%! if (compare_versions (OCTAVE_VERSION, "4.2", ">="))
%!   assert (evalc ("a = infsup (); display (a)"), "a = [Empty]\n");
%!   assert (evalc ("b = infsupdec (); display (b)"), "b = [Empty]_trv\n");
%! endif

%!test
%! if (compare_versions (OCTAVE_VERSION, "4.2", ">=") && !ispc ())
%!   assert (evalc ("display (infsup (magic (3)))"), ...
%!    ["3×3 interval matrix\n", ...
%!     "\n", ...
%!     "   [8]   [1]   [6]\n", ...
%!     "   [3]   [5]   [7]\n", ...
%!     "   [4]   [9]   [2]\n", ...
%!     "\n"]);
%! endif

%!test
%! if (compare_versions (OCTAVE_VERSION, "4.2", ">=") && !ispc ())
%!   assert (evalc ("infsup (magic (3))"), ...
%!    ["ans = 3×3 interval matrix\n", ...
%!     "\n", ...
%!     "   [8]   [1]   [6]\n", ...
%!     "   [3]   [5]   [7]\n", ...
%!     "   [4]   [9]   [2]\n", ...
%!     "\n"]);
%! endif

%!test
%! if (compare_versions (OCTAVE_VERSION, "4.2", ">=") && !ispc ())
%!   assert (evalc ("infsup ('pi')"), "ans ⊂ [3.1415, 3.1416]\n");
%! endif

%!test
%! if (compare_versions (OCTAVE_VERSION, "4.2", ">=") && !ispc ())
%!   assert (evalc ("infsup (1:3)"), ...
%!    ["ans = 1×3 interval vector\n", ...
%!     "\n", ...
%!     "   [1]   [2]   [3]\n", ...
%!     "\n"]);
%! endif

%!test
%! if (compare_versions (OCTAVE_VERSION, "4.2", ">=") && !ispc ())
%!   assert (evalc ("infsup (ones(2, 2, 2))"), ...
%!    ["ans = 2×2×2 interval array\n", ...
%!     "\n", ...
%!     "ans(:,:,1) =\n", ...
%!     "\n", ...
%!     "   [1]   [1]\n", ...
%!     "   [1]   [1]\n", ...
%!     "\n", ...
%!     "ans(:,:,2) =\n", ...
%!     "\n", ...
%!     "   [1]   [1]\n", ...
%!     "   [1]   [1]\n", ...
%!     "\n"]);
%! endif
