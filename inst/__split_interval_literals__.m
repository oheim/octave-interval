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
## @documentencoding utf-8
## @defun __split_interval_literals__ (@var{S})
##
## Split string @var{S} into a cell array of interval literals.
##
## This is an internal function of the interval package and should not be used
## directly.
## @end defun

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2015-06-13

function result = __split_interval_literals__ (s)

if (isempty (s))
    result = { s };
    return
endif

## Split into rows,
## using newline characters, semicolon and rows in 2D strings as delimiters
row = transpose (ostrsplit (s, ";\n"));

## Normalize delimiters between intervals within the same row
row = strrep (row, "\t", ' ');
row = strrep (row, '[', "\t["); # start of interval literals
row = regexprep (row, '(](_\w*)?)\s*', "$1\t"); # end of interval literals

## Bare numbers “1 2, 3 4” shall be split into columns by spaces or commas
[bare_numbers.s, bare_numbers.e] = regexp (row, '(^|\t)[^\t\[]+($|\t)');
for i = 1 : numel (row)
    for j = 1 : numel (bare_numbers.s {i})
        select = bare_numbers.s {i} (j) : bare_numbers.e {i} (j);
        row {i} (select) = strrep (strrep (row {i} (select), ' ', "\t"), ...
                                                             ',', "\t");
    endfor
endfor

## Separate columns within each row
row = cellfun (@(s) strsplit (strtrim (s), "\t"), row, "UniformOutput", false);

## Fill short rows with empty columns
cols = cellfun ('numel', row);
max_cols = max (cols);
for i = find (cols < max_cols)'
    row {i} = horzcat (row {i}, {"[Empty]"} (ones (1, max_cols - cols (i))));
endfor

## Build a 2D cell array from a cell array of cell arrays
result = vertcat (row {:});

endfunction

%!assert (__split_interval_literals__ (""), {""});
%!assert (__split_interval_literals__ (","), {""});
%!assert (__split_interval_literals__ ("1"), {"1"});
%!assert (__split_interval_literals__ ("1?"), {"1?"});
%!assert (__split_interval_literals__ ("1?u"), {"1?u"});
%!assert (__split_interval_literals__ ("1?u3"), {"1?u3"});
%!assert (__split_interval_literals__ ("[Empty]"), {"[Empty]"});
%!assert (__split_interval_literals__ ("[Entire]"), {"[Entire]"});
%!assert (__split_interval_literals__ ("[]"), {"[]"});
%!assert (__split_interval_literals__ ("[,]"), {"[,]"});
%!assert (__split_interval_literals__ ("[1]"), {"[1]"});
%!assert (__split_interval_literals__ ("[1,2]"), {"[1,2]"});
%!assert (__split_interval_literals__ ("1             2"), {"1", "2"});
%!assert (__split_interval_literals__ ("1, , , , , , ,2"), {"1", "2"});
%!assert (__split_interval_literals__ ("1;;2"), {"1"; ""; "2"});
%!assert (__split_interval_literals__ ("1; ;2"), {"1"; ""; "2"});
%!assert (__split_interval_literals__ ("[1,2] [3,4]"), {"[1,2]", "[3,4]"});
%!assert (__split_interval_literals__ ("[1,2],[3,4]"), {"[1,2]", "[3,4]"});
%!assert (__split_interval_literals__ ("[1,2], [3,4]"), {"[1,2]", "[3,4]"});
%!assert (__split_interval_literals__ ("[1,2]\n[3,4]"), {"[1,2]"; "[3,4]"});
%!assert (__split_interval_literals__ ("[1,2];[3,4]"), {"[1,2]"; "[3,4]"});
%!assert (__split_interval_literals__ ("[1,2]; [3,4]"), {"[1,2]"; "[3,4]"});
%!assert (__split_interval_literals__ (["[1,2]"; "[3,4]"]), {"[1,2]"; "[3,4]"});
%!assert (__split_interval_literals__ ("1 [3,4]"), {"1", "[3,4]"});
%!assert (__split_interval_literals__ ("1,[3,4]"), {"1", "[3,4]"});
%!assert (__split_interval_literals__ ("1, [3,4]"), {"1", "[3,4]"});
%!assert (__split_interval_literals__ ("1\n[3,4]"), {"1"; "[3,4]"});
%!assert (__split_interval_literals__ ("1;[3,4]"), {"1"; "[3,4]"});
%!assert (__split_interval_literals__ ("1; [3,4]"), {"1"; "[3,4]"});
%!assert (__split_interval_literals__ (["1"; "[3,4]"]), {"1"; "[3,4]"});
%!assert (__split_interval_literals__ ("[1,2] 3"), {"[1,2]", "3"});
%!assert (__split_interval_literals__ ("[1,2],3"), {"[1,2]", "3"});
%!assert (__split_interval_literals__ ("[1,2], 3"), {"[1,2]", "3"});
%!assert (__split_interval_literals__ ("[1,2]\n3"), {"[1,2]"; "3"});
%!assert (__split_interval_literals__ ("[1,2];3"), {"[1,2]"; "3"});
%!assert (__split_interval_literals__ ("[1,2]; 3"), {"[1,2]"; "3"});
%!assert (__split_interval_literals__ (["[1,2]"; "3"]), {"[1,2]"; "3"});
%!assert (__split_interval_literals__ ("1 3"), {"1", "3"});
%!assert (__split_interval_literals__ ("1,3"), {"1", "3"});
%!assert (__split_interval_literals__ ("1, 3"), {"1", "3"});
%!assert (__split_interval_literals__ ("1\n3"), {"1"; "3"});
%!assert (__split_interval_literals__ ("1;3"), {"1"; "3"});
%!assert (__split_interval_literals__ ("1; 3"), {"1"; "3"});
%!assert (__split_interval_literals__ (["1"; "3"]), {"1"; "3"});
%!assert (__split_interval_literals__ ("[1,2] [3,4] [5,6]"), {"[1,2]", "[3,4]", "[5,6]"});
%!assert (__split_interval_literals__ ("[1,2],[3,4],[5,6]"), {"[1,2]", "[3,4]", "[5,6]"});
%!assert (__split_interval_literals__ ("[1,2], [3,4], [5,6]"), {"[1,2]", "[3,4]", "[5,6]"});
%!assert (__split_interval_literals__ ("[1,2]\n[3,4];[5,6]"), {"[1,2]"; "[3,4]"; "[5,6]"});
%!assert (__split_interval_literals__ ("[1,2];[3,4] [5,6]"), {"[1,2]", "[Empty]"; "[3,4]", "[5,6]"});
%!assert (__split_interval_literals__ ("[1,2] [3,4];[5,6]"), {"[1,2]", "[3,4]"; "[5,6]", "[Empty]"});
%!assert (__split_interval_literals__ ("1 [3,4] [5,6]"), {"1", "[3,4]", "[5,6]"});
%!assert (__split_interval_literals__ ("1,[3,4],[5,6]"), {"1", "[3,4]", "[5,6]"});
%!assert (__split_interval_literals__ ("1, [3,4], [5,6]"), {"1", "[3,4]", "[5,6]"});
%!assert (__split_interval_literals__ ("1\n[3,4];[5,6]"), {"1"; "[3,4]"; "[5,6]"});
%!assert (__split_interval_literals__ ("1;[3,4] [5,6]"), {"1", "[Empty]"; "[3,4]", "[5,6]"});
%!assert (__split_interval_literals__ ("1 [3,4];[5,6]"), {"1", "[3,4]"; "[5,6]", "[Empty]"});
%!assert (__split_interval_literals__ ("[1,2] 3 [5,6]"), {"[1,2]", "3", "[5,6]"});
%!assert (__split_interval_literals__ ("[1,2],3,[5,6]"), {"[1,2]", "3", "[5,6]"});
%!assert (__split_interval_literals__ ("[1,2], 3, [5,6]"), {"[1,2]", "3", "[5,6]"});
%!assert (__split_interval_literals__ ("[1,2]\n3;[5,6]"), {"[1,2]"; "3"; "[5,6]"});
%!assert (__split_interval_literals__ ("[1,2];3 [5,6]"), {"[1,2]", "[Empty]"; "3", "[5,6]"});
%!assert (__split_interval_literals__ ("[1,2] 3;[5,6]"), {"[1,2]", "3"; "[5,6]", "[Empty]"});
%!assert (__split_interval_literals__ ("[1,2] [3,4] 5"), {"[1,2]", "[3,4]", "5"});
%!assert (__split_interval_literals__ ("[1,2],[3,4],5"), {"[1,2]", "[3,4]", "5"});
%!assert (__split_interval_literals__ ("[1,2], [3,4], 5"), {"[1,2]", "[3,4]", "5"});
%!assert (__split_interval_literals__ ("[1,2]\n[3,4];5"), {"[1,2]"; "[3,4]"; "5"});
%!assert (__split_interval_literals__ ("[1,2];[3,4] 5"), {"[1,2]", "[Empty]"; "[3,4]", "5"});
%!assert (__split_interval_literals__ ("[1,2] [3,4];5"), {"[1,2]", "[3,4]"; "5", "[Empty]"});
%!assert (__split_interval_literals__ ("1 [3,4] 5"), {"1", "[3,4]", "5"});
%!assert (__split_interval_literals__ ("1,[3,4],5"), {"1", "[3,4]", "5"});
%!assert (__split_interval_literals__ ("1, [3,4], 5"), {"1", "[3,4]", "5"});
%!assert (__split_interval_literals__ ("1\n[3,4];5"), {"1"; "[3,4]"; "5"});
%!assert (__split_interval_literals__ ("1;[3,4] 5"), {"1", "[Empty]"; "[3,4]", "5"});
%!assert (__split_interval_literals__ ("1 [3,4];5"), {"1", "[3,4]"; "5", "[Empty]"});
%!assert (__split_interval_literals__ ("1 3 [5,6]"), {"1", "3", "[5,6]"});
%!assert (__split_interval_literals__ ("1,3,[5,6]"), {"1", "3", "[5,6]"});
%!assert (__split_interval_literals__ ("1, 3, [5,6]"), {"1", "3", "[5,6]"});
%!assert (__split_interval_literals__ ("1\n3;[5,6]"), {"1"; "3"; "[5,6]"});
%!assert (__split_interval_literals__ ("1;3 [5,6]"), {"1", "[Empty]"; "3", "[5,6]"});
%!assert (__split_interval_literals__ ("1 3;[5,6]"), {"1", "3"; "[5,6]", "[Empty]"});
%!assert (__split_interval_literals__ ("[1,2] 3 5"), {"[1,2]", "3", "5"});
%!assert (__split_interval_literals__ ("[1,2],3,5"), {"[1,2]", "3", "5"});
%!assert (__split_interval_literals__ ("[1,2], 3, 5"), {"[1,2]", "3", "5"});
%!assert (__split_interval_literals__ ("[1,2]\n3;5"), {"[1,2]"; "3"; "5"});
%!assert (__split_interval_literals__ ("[1,2];3 5"), {"[1,2]", "[Empty]"; "3", "5"});
%!assert (__split_interval_literals__ ("[1,2] 3;5"), {"[1,2]", "3"; "5", "[Empty]"});
%!assert (__split_interval_literals__ ("1 3 5"), {"1", "3", "5"});
%!assert (__split_interval_literals__ ("1,3,5"), {"1", "3", "5"});
%!assert (__split_interval_literals__ ("1, 3, 5"), {"1", "3", "5"});
%!assert (__split_interval_literals__ ("1\n3;5"), {"1"; "3"; "5"});
%!assert (__split_interval_literals__ ("1;3 5"), {"1", "[Empty]"; "3", "5"});
%!assert (__split_interval_literals__ ("1 3;5"), {"1", "3"; "5", "[Empty]"});
