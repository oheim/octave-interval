## Copyright 2015-2016 Oliver Heimlich
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
## Interval matrices with many rows are wrapped according to the terminal
## width.  @code{disp} prints nothing when @var{X} is an interval matrix
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
##   @result{} [3.14159265358979, 3.1415926535898]_com
## format short
## disp (infsupdec ("pi"))
##   @result{} [3.1415, 3.1416]_com
## disp (infsupdec (1 : 5))
##   @result{}    [1]_com   [2]_com   [3]_com   [4]_com   [5]_com
## s = disp (infsupdec (0))
##   @result{} s = [0]_com
## @end group
## @end example
## @seealso{@@infsup/display, @@infsup/intervaltotext}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2015-04-30

function varargout = disp (x)

if (nargin ~= 1)
    print_usage ();
    return
endif

## With format="auto" the output precision can be set with the format command
[s, isexact] = intervaltotext (x, "auto");

if (not (iscell (s)))
    ## Scalar interval
    if (nargout == 0)
        disp (s);
    else
        varargout {1} = cstrcat (s, "\n");
        varargout {2} = isexact;
    endif
    return
endif

## Interval matrix / vector
columnwidth = max (cellfun ("length", s), [], 1);
columnwidth += 3; # add 3 spaces between columns

## Print all columns
buffer = "";
if (rows (x) > 0)
    ## FIXME: See display.m for how current_print_indent_level is used
    global current_print_indent_level;
    maxwidth = terminal_size () (2) - current_print_indent_level;
    cstart = uint32 (1);
    cend = cstart - 1;
    while (cstart <= columns (x))
        ## Determine number of columns to print, print at least one column
        usedwidth = 0;
        submatrix = "";
        do
            cend ++;
            submatrix = strcat (submatrix, ...
                prepad (strjust (char (s (:, cend))), columnwidth (cend), " ", 2));
            usedwidth += columnwidth (cend);
        until (cend == columns (x) || ...
               (split_long_rows () && ...
                 usedwidth + columnwidth (cend + 1) > maxwidth))
        if (cstart > 1 || cend < columns (x))
            if (cstart > 1)
                buffer = cstrcat (buffer, "\n");
            endif
            if (cend > cstart)
                buffer = cstrcat (buffer, ...
                                  sprintf(" Columns %d through %d:\n\n", ...
                                        cstart, cend)); ...
            else
                buffer = cstrcat (buffer, ...
                                  sprintf(" Column %d:\n\n", cstart));
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

if (nargout > 0)
    varargout {1} = buffer;
    varargout {2} = isexact;
endif

endfunction

%!## Can't test the disp function. Would have to capture console output
%!assert (1);
