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
## @deftypemethod {@@infsup} {@var{S} =} intervaltotext (@var{X})
## @deftypemethodx {@@infsup} {@var{S} =} intervaltotext (@var{X}, @var{FORMAT})
## 
## Build an approximate representation of the interval @var{X}.
##
## Output @var{S} is a simple string for scalar intervals, and a cell array of
## strings for interval matrices.
## 
## The interval boundaries are stored in binary floating point format and are
## converted to decimal or hexadecimal format with possible precision loss.  If
## output is not exact, the boundaries are rounded accordingly (e. g. the upper
## boundary is rounded towards infinite for output representation).
## 
## The exact decimal format may produce a lot of digits.
##
## Possible values for @var{FORMAT} are: @code{decimal} (default),
## @code{exact decimal}, @code{exact hexadecimal}, @code{auto}
## 
## Accuracy: For all intervals @var{X} is an accurate subset of
## @code{infsup (intervaltotext (@var{X}))}.
## @example
## @group
## x = infsup (1 + eps);
## intervaltotext (x)
##   @result{} [1.0000000000000002, 1.000000000000001]
## @end group
## @end example
## @example
## @group
## y = nextout (x);
## intervaltotext (y)
##   @result{} [1, 1.0000000000000005]
## @end group
## @end example
## @example
## @group
## z = infsup (1);
## intervaltotext (z)
##   @result{} [1]
## @end group
## @end example
## @seealso{@@infsup/intervaltoexact}
## @end deftypemethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-09-30

function [s, isexact] = intervaltotext (x, format)

if (nargin > 2)
    print_usage ();
    return
endif

isexact = true ();

if (nargin < 2)
    format = "decimal";
endif

s = l = u = cell (size (x.inf));
s (isempty (x)) = "[Empty]";
s (isentire (x)) = "[Entire]";

select = not (isempty (x) | isentire (x));
if (any (any (select)))
    x.inf (x.inf == 0) = 0; # no sign for zero
    [l(select), lexact] = mpfr_to_string_d (-inf, format, x.inf (select));
    [u(select), uexact] = mpfr_to_string_d (+inf, format, x.sup (select));
    isexact = lexact && uexact;
    
    ## Normalize case of +-Inf
    l (select & x.inf == -inf) = "-Inf";
    u (select & x.sup == inf) = "Inf";
    
    ## If l is negative, then u shall also carry a sign (not zero)
    change_of_sign = select & x.inf < 0 & x.sup > 0;
    u (change_of_sign) = strcat ("+", u (change_of_sign));
    
    singleton_string = strcmp (l, u);
    s (select & singleton_string) = strcat ("[", ...
                                            l (select & singleton_string), ...
                                            "]");
    s (select & not (singleton_string)) = strcat (...
                                       "[", ...
                                       l (select & not (singleton_string)), ...
                                       {", "}, ...
                                       u (select & not (singleton_string)), ...
                                       "]");
endif

if (isscalar (s))
    s = s {1};
endif

endfunction

%!assert (intervaltotext (infsup (1 + eps), "exact decimal"), "[1.0000000000000002220446049250313080847263336181640625]");
%!assert (intervaltotext (infsup (1 + eps), "exact hexadecimal"), "[0X1.0000000000001P+0]");
%!test
%! output_precision (3, 'local');
%! assert (intervaltotext (infsup (pi), "auto"), "[3.14, 3.15]");
%! output_precision (4, 'local');
%! assert (intervaltotext (infsup (pi), "auto"), "[3.141, 3.142]");
%!test "from the documentation string";
%! assert (intervaltotext (infsup (1 + eps)), "[1.0000000000000002, 1.000000000000001]");
%! assert (intervaltotext (nextout (infsup (1 + eps))), "[1, 1.0000000000000005]");
%! assert (intervaltotext (infsup (1)), "[1]");
