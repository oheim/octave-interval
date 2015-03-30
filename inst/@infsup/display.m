## Copyright 2014-2015 Oliver Heimlich
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

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-28

function display (x)

if (nargin ~= 1)
    print_usage ();
    return
endif

[s, isexact] = intervaltotext (x);
if (length (inputname (1)) > 0)
    fprintf ("%s ", inputname (1));
    if (isexact)
        fprintf ("= ");
    else
        fprintf ("⊂ ");
    endif
endif

if (not (iscell (s)))
    fprintf (s);
    fprintf ("\n");
    return
else
    fprintf ("%d×%d interval ", size (x, 1), size (x, 2));
    if (isvector (x))
        fprintf ("vector");
    else
        fprintf ("matrix");
    endif
    fprintf ("\n\n");
endif

columnwidth = max (cellfun ("length", s), [], 1);
columnwidth += 3; # add 3 spaces between columns

## Print all columns
maxwidth = terminal_size () (2);
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
        if (cend > cstart)
            fprintf (" Columns %d through %d:\n\n", cstart, cend);
        else
            fprintf (" Column %d:\n\n", cstart);
        endif
    endif
    disp (submatrix);
    fprintf ("\n");
    cstart = cend + 1;
endwhile

endfunction

%!## Can't test the display function. Would have to capture console output
%!assert (1);
