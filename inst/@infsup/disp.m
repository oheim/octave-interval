## Copyright 2015-2017 Oliver Heimlich
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
## @defmethod {@@infsup} disp (@var{X})
##
## Display the value of interval @var{X}.
##
## Interval boundaries are approximated with faithful decimal numbers.
##
## Interval arrays with many rows are wrapped according to the terminal
## width.  @code{disp} prints nothing when @var{X} is an interval array
## without elements.
##
## Note that the output from @code{disp} always ends with a newline.
##
## If an output value is requested, @code{disp} prints nothing and returns the
## formatted output in a string.
##
## @example
## @group
## format long
## disp (infsupdec ("pi"))
##   @result{} [3.141592653589793, 3.141592653589794]_com
## format short
## disp (infsupdec ("pi"))
##   @result{} [3.1415, 3.1416]_com
## disp (infsupdec (1 : 5))
##   @result{}    [1]_com   [2]_com   [3]_com   [4]_com   [5]_com
## s = disp (infsupdec (0))
##   @result{} s = [0]_com
## @end group
## @end example
## @seealso{@@infsup/display, intervaltotext}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2015-04-30

function varargout = disp (x)

  if (nargin ~= 1)
    print_usage ();
    return
  endif

  if (strcmp (disp (uint8 (255)), "ff\n"))
    ## hex output
    cs = "[.13a]";
  else
    ## decimal output
    cs = cstrcat ("[.", num2str (output_precision ()) , "g]");
  endif

  [s, isexact] = intervaltotext (x, cs);

  if (not (iscell (s)))
    ## Scalar interval
    if (nargout == 0)
      disp (s);
    else
      varargout{1} = cstrcat (s, "\n");
      varargout{2} = isexact;
    endif
    return
  endif

  loose_spacing = __loosespacing__ ();

  columnwidth = max (cellfun ("length", s), [], 1);
  columnwidth += 3; # add 3 spaces between columns

  buffer = "";
  numberofmatrixparts = prod (size (x.inf)(3:end));
  for matrixpart = 1:numberofmatrixparts
    ## Print the current submatrix
    if (rows (x.inf) > 0)
      ## FIXME: See display.m for how current_print_indent_level is used
      global current_print_indent_level;
      maxwidth = terminal_size ()(2) - current_print_indent_level;

      if (ndims (x) > 2)
        ## Loose format: Use extra newline between previous matrix and current label,
        ## unless the submatrix is scalar
        if (loose_spacing && matrixpart > 1 && ...
            (rows (x.inf) > 1 || columns (x.inf) > 1))
          buffer = cstrcat (buffer, "\n");
        endif
        ## Print the index for the current matrix in the array
        buffer = cstrcat (buffer, sprintf("ans(:,:"));
        matrixpartsubscript = cell (1, ndims (x) - 2);
        [matrixpartsubscript{:}] = ind2sub (size (x.inf)(3:end), matrixpart);
        buffer = cstrcat (buffer, ...
                          sprintf(",%d", ...
                                  matrixpartsubscript{1:ndims (x.inf) - 2}));
        ## FIXME: How should we handle the equal sign, "=", when the
        ## representation is not exact?
        buffer = cstrcat (buffer, sprintf(") ="));
        if (rows (x.inf) > 1 || columns (x.inf) > 1)
          buffer = cstrcat (buffer, ifelse (loose_spacing, "\n\n", "\n"));
        endif
      endif

      cstart = uint32 (1);
      cend = cstart - 1;
      while (cstart <= columns (x.inf))
        ## Determine number of columns to print, print at least one column
        usedwidth = 0;
        submatrix = "";
        do
          cend ++;
          submatrix = strcat (submatrix, ...
                              prepad (strjust (char (s(:, cend, ...
                                                       matrixpart))), ...
                                      columnwidth(1, cend, matrixpart), ...
                                      " ", 2));
          usedwidth += columnwidth(cend);
        until (cend == columns (x.inf) || ...
               (split_long_rows () && ...
                usedwidth + columnwidth(cend + 1) > maxwidth))
        if (cstart > 1 || cend < columns (x.inf))
          if (loose_spacing && cstart > 1)
            buffer = cstrcat (buffer, "\n");
          endif
          if (cend > cstart)
            buffer = cstrcat (buffer, ...
                              sprintf(" Columns %d through %d:\n", ...
                                      cstart, cend)); ...
          else
            buffer = cstrcat (buffer, ...
                              sprintf(" Column %d:\n", cstart));
          endif
          if (loose_spacing)
            buffer = cstrcat (buffer, "\n");
          endif
        endif
        ## Convert string matrix into string with newlines
        buffer = cstrcat (buffer, strjoin (cellstr (submatrix), "\n"), "\n");
        if (nargout == 0)
          printf (buffer);
          buffer = "";
        endif
        cstart = cend + 1;
      endwhile
    endif
  endfor
  if (nargout > 0)
    varargout{1} = buffer;
    varargout{2} = isexact;
  endif

endfunction

%!assert (disp (infsup([])), "");
%!assert (disp (infsup(zeros (0, 1))), "");
%!assert (disp (infsup(zeros (1, 0))), "");
%!assert (disp (infsup(0)), "[0]\n");
%!assert (disp (infsup(0, 1)), "[0, 1]\n");
%!assert (disp (infsup([0 0])), "   [0]   [0]\n");
%!assert (disp (infsup([0 0; 0 0])), "   [0]   [0]\n   [0]   [0]\n");
%!assert (disp (infsup([0; 0])), "   [0]\n   [0]\n");
%!assert (disp (infsup (zeros (1, 1, 1, 0))), "");
%!assert (disp (infsup(zeros(2, 2, 2))), "ans(:,:,1) =\n\n   [0]   [0]\n   [0]   [0]\n\nans(:,:,2) =\n\n   [0]   [0]\n   [0]   [0]\n")
%!test
%! i = infsupdec (reshape (1:24, 2, 3, 4));
%! i(1, 1, 2) = entire ();
%! i(1, 1, 3) = empty ();
%! i(1, 1, 4) = nai ();
%! assert (disp (i(1,1,:)), "ans(:,:,1) =   [1]_com\nans(:,:,2) =   [Entire]_dac\nans(:,:,3) =   [Empty]_trv\nans(:,:,4) =   [NaI]\n")
%!test
%! x = infsup (zeros ([1 2 2]));
%! unwind_protect
%!   format compact
%!   compact = disp (x);
%!   format loose
%!   loose = disp (x);
%! unwind_protect_cleanup
%!   format
%! end_unwind_protect
%! assert (compact, "ans(:,:,1) =\n   [0]   [0]\nans(:,:,2) =\n   [0]   [0]\n");
%! assert (loose, "ans(:,:,1) =\n\n   [0]   [0]\n\nans(:,:,2) =\n\n   [0]   [0]\n");
%!test
%! x = infsup (zeros ([1 1 2]));
%! unwind_protect
%!   format compact
%!   compact = disp (x);
%!   format loose
%!   loose = disp (x);
%! unwind_protect_cleanup
%!   format
%! end_unwind_protect
%! assert (compact, "ans(:,:,1) =   [0]\nans(:,:,2) =   [0]\n");
%! assert (loose,   "ans(:,:,1) =   [0]\nans(:,:,2) =   [0]\n");