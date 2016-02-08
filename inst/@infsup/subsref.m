## Copyright 2014-2016 Oliver Heimlich
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
## @defop Method {@@infsup} subsref (@var{A}, @var{IDX})
## @defopx Operator {@@infsup} {@var{A}(@var{I})}
## @defopx Operator {@@infsup} {@var{A}(@var{I1}, @var{I2})}
## @defopx Operator {@@infsup} {@var{A}.@var{P}}
##
## Select property @var{P} or elements @var{I} from interval matrix @var{A}.
##
## The index @var{I} may be either @code{:} or an index matrix.
## @comment DO NOT SYNCHRONIZE DOCUMENTATION STRING
## The property @var{P} may correspond to any unary method of the interval's
## class, but usually is either @code{inf} or @code{sup}.
##
## @example
## @group
## x = infsup (magic (3), magic (3) + 1);
## x (1)
##   @result{} ans = [8, 9]
## x (:, 2)
##   @result{} ans = 3×1 interval vector
##       [1, 2]
##       [5, 6]
##      [9, 10]
## x.inf
##   @result{} ans =
##      8   1   6
##      3   5   7
##      4   9   2
## @end group
## @end example
## @seealso{@@infsup/subsasgn}
## @end defop

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-29

function result = subsref (A, S)

if (nargin ~= 2)
    print_usage ();
    return
endif

switch (S (1).type)
    case "()"
        A.inf = subsref (A.inf, S (1));
        A.sup = subsref (A.sup, S (1));
        result = A;
    case "{}"
        error ("interval cannot be indexed with {}")
    case "."
        if (not (any (strcmp (S(1).subs, methods (A)))))
            error (["interval property ‘", S(1).subs, "’ is unknown"])
        endif
        functionname = ["@infsup", filesep(), S(1).subs];
        if (nargin (functionname) ~= 1)
            error (["‘", S(1).subs, "’ is not a valid interval property"])
        endif
        result = feval (S (1).subs, A);
    otherwise
        error ("invalid subscript type")
endswitch

if (numel (S) > 1)
    result = subsref (result, S (2:end));
endif

endfunction

%!assert (infsup (magic (3)) ([1, 2, 3]) == magic (3) ([1, 2, 3]));
%!test "from the documentation string";
%! x = infsup (magic (3), magic (3) + 1);
%! assert (x (1) == infsup (8, 9)); 
%! assert (x (:, 2) == infsup ([1; 5; 9], [2; 6; 10]));
%! assert (x.inf, magic (3));
