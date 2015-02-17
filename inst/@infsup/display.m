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

if (numel (x) < 1)
    if (length (inputname (1)) > 0)
        fprintf ("%s = ", inputname (1));
    endif
    fprintf ("%d×%d interval matrix\n", size (x, 1), size (x, 2));
    return
endif

if (numel (x) == 1)
    [s, isexact] = intervaltotext (x);
    if (length (inputname (1)) > 0)
        fprintf ("%s ", inputname (1));
        if (isexact)
            fprintf ("= ");
        else
            fprintf ("⊂ ");
        endif
    endif
    fprintf (s);
    fprintf ("\n");
    return
endif

string = cell (1, columns (x));
columnwidth = zeros (columns (x), 1, "uint8");
isexact = true ();
idx.type = "()"; # subsref with operator syntax doesn't work below
## Build text representation for each column
for column = 1 : columns (x)
    columnstring = cell (rows (x), 1);
    for row = 1 : rows (x)
        idx.subs = {row, column};
        interval = subsref (x, idx);
        [columnstring{row}, elementisexact] = ...
            intervaltotext (interval);
        isexact = and (isexact, elementisexact);
        columnwidth (column) = max (columnwidth (column), ...
                                    length (columnstring {row}));
    endfor
    ## Right align elements within their column
    columnwidth (column) += 3; # add 3 spaces between columns
    for row = 1 : rows (x)
        columnstring {row} = prepad (columnstring {row}, ...
                                     columnwidth (column), " ");
    endfor
    string {column} = columnstring;
endfor

## Print variable name and header
if (length (inputname (1)) > 0)
    fprintf ("%s ", inputname (1));
    if (isexact)
        fprintf ("=");
    else
        fprintf ("⊂");
    endif
    fprintf (" %d×%d interval ", size (x, 1), size (x, 2));
    if (isvector (x))
        fprintf ("vector");
    else
        fprintf ("matrix");
    endif
    fprintf ("\n\n");
endif

## Print all columns
maxwidth = terminal_size () (2);
cstart = uint32 (1);
while (cstart <= columns (x))
    ## Determine number of columns to print, print at least one column
    cend = cstart;
    usedwidth = columnwidth (cend);
    while (cend < columns (x) && ...
           usedwidth + columnwidth (cend + 1) <= maxwidth)
        cend ++;
        usedwidth += columnwidth (cend);
    endwhile
    if (cstart > 1 || cend < columns (x))
        if (cend > cstart)
            fprintf (" Columns %d through %d:\n\n", cstart, cend);
        else
            fprintf (" Column %d:\n\n", cstart);
        endif
    endif
    fprintf (strjoin (strcat (string {cstart : cend}), "\n"));
    fprintf ("\n\n");
    cstart = cend + 1;
endwhile

endfunction