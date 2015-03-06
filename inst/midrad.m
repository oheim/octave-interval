## Copyright 2015 Oliver Heimlich
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
## @deftypefn {Function File} {} midrad (@var{M}, @var{R})
## 
## Return an interval enclosure for [@var{M}-@var{R}, @var{M}+@var{R}].
##
## Accuracy: The result is an accurate enclosure.  The result is tightest if
## @var{M} and @var{R} are floating-point numbers.
##
## @example
## @group
## midrad (42, 3)
##   @result{} [39, 45]_com
## midrad (0, inf)
##   @result{} [Entire]_dac
## midrad ("1.1", "0.1")
##   @result{} [.9999999999999997, 1.2000000000000002]_com
## @end group
## @end example
## @seealso{@@infsup/infsup, hull}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2015-03-06

function result = midrad (m, r)

switch nargin
    case 0
        result = infsupdec ();
    case 1
        result = infsupdec (m);
    case 2
        if (isfloat (m) && isreal (m) && ...
            isfloat (r) && isreal (r))
            ## Simple case: m and r are binary64 numbers
            if (not (all (all (r >= 0))))
                error ("midrad: radius must be non-negative")
            endif
            l = mpfr_function_d ('minus', -inf, m, r);
            u = mpfr_function_d ('plus', +inf, m, r);
            result = infsupdec (l, u);
        else
            ## Complicated case: m and r are strings or other types
            m = infsupdec (m);
            if (isnai (m))
                result = m;
                return
            endif
            if (not (isa (r, "infsupdec")))
                if (isa (r, "infsup"))
                    r = infsupdec (r);
                else
                    r = infsupdec (0, r);
                endif
            endif
            if (isnai (r))
                result = r;
                return
            endif
            sup_r = sup (r);
            r = infsupdec (-sup_r, sup_r, decorationpart (r));
            result = m + r;
        endif
        
    otherwise 
        print_usage ();
endswitch

endfunction

%!assert (isempty (midrad ()));
%!assert (isequal (midrad ("pi"), infsupdec ("pi")));
%!assert (isequal (midrad (infsup (2), 2), infsupdec (0, 4)));
%!assert (isequal (midrad (2, infsup (2)), infsupdec (0, 4)));
%!assert (isequal (midrad (infsup (2), infsup (2)), infsupdec (0, 4)));
%!assert (isequal (midrad (2, infsupdec (2)), infsupdec (0, 4)));
%!assert (isequal (midrad (infsupdec (2), 2), infsupdec (0, 4)));
%!assert (isequal (midrad (infsup (2), infsupdec (2)), infsupdec (0, 4)));
%!assert (isequal (midrad (infsupdec (2), infsup (2)), infsupdec (0, 4)));
%!assert (isequal (midrad (infsupdec (2), infsupdec (2)), infsupdec (0, 4)));
%!xtest assert (isequal (midrad (1, magic (3)), infsupdec ([-7, 0, -5; -2, -4, -6; -3, -8, -1], [9, 2, 7; 4, 6, 8; 5, 10, 3])));
%!xtest assert (isequal (midrad (magic (3), 1), infsupdec ([7, 0, 5; 2, 4, 6; 3, 8, 1], [9, 2, 7; 4, 6, 8; 5, 10, 3])));
%!test "from the documentation string";
%! assert (isequal (midrad (42, 3), infsupdec (39, 45)));
%! assert (isequal (midrad (0, inf), entire ()));
%! assert (isequal (midrad ("1.1", "0.1"), infsupdec (1 - eps, "1.2")));
