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
## @defun midrad (@var{M}, @var{R})
## @defunx midrad (@var{M})
## @defunx midrad ()
## 
## Create an interval enclosure for [@var{M}-@var{R}, @var{M}+@var{R}].
##
## Without input parameters, return the empty interval.  With only one input
## parameter, the radius @var{R} defaults to zero.
##
## Parameters can be simple numbers, intervals or interval literals as strings.
## Scalar values or scalar intervals do broadcast if combined with matrices or
## interval matrices.
##
## The result is not guaranteed to be tightest if parameters are given as
## strings.  This is due to intermediate results.  The infsupdec constructor
## with interval literals in uncertain form @code{m?ruE} can instead be used to
## create tight enclosures of decimal numbers with a radius.
##
## Accuracy: The result is an accurate enclosure.  The result is tightest if
## @var{M} and @var{R} are floating-point numbers or intervals.
##
## @example
## @group
## midrad (42, 3)
##   @result{} ans = [39, 45]_com
## midrad (0, inf)
##   @result{} ans = [Entire]_dac
## midrad ("1.1", "0.1")
##   @result{} ans ⊂ [0.99999, 1.2001]_com
## midrad ("25", "3/7")
##   @result{} ans ⊂ [24.571, 25.429]_com
## @end group
## @end example
## @seealso{@@infsupdec/infsupdec, hull, @@infsupdec/mid, @@infsupdec/rad}
## @end defun

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
            l = mpfr_function_d ('minus', -inf, m, r);
            u = mpfr_function_d ('plus', +inf, m, r);
            emptyresult = r < 0 & true (size (m));
            l (emptyresult) = inf;
            u (emptyresult) = -inf;
            result = infsupdec (l, u);
        else
            ## Complicated case: m and r are strings or other types
            m = infsupdec (m);
            if (isnai (m))
                result = m;
                return
            endif
            if (not (isa (r, "infsup")))
                ## [-inf, r] should make a valid interval, unless r == -inf
                ## Intersection with non-negative numbers ensures that we
                ## return [Empty] if r < 0.
                if (isfloat (r))
                    r (r == -inf) = nan;
                endif
                r = intersect (infsupdec (-inf, r), infsupdec (0, inf));
                if (not (isnai (r)))
                    ## Fix decoration
                    r = newdec (intervalpart (r));
                endif
            endif
            if (isa (r, "infsupdec"))
                if (isnai (r))
                    result = r;
                    return
                endif
                dec_r = decorationpart (r);
            else
                dec_r = "com";
            endif
            sup_r = sup (r);
            sup_r (sup_r < 0) = -inf;
            r = infsupdec (-sup_r, sup_r, dec_r);
            
            result = m + r;
        endif
        
    otherwise
        print_usage ();
endswitch

endfunction

%!assert (isempty (midrad ()));
%!assert (isempty (midrad (0, -inf)));
%!assert (isempty (midrad (0, -.1)));
%!assert (isempty (midrad (0, "-.1")));
%!assert (isempty (midrad (0, infsup("-.1"))));
%!assert (isequal (midrad ("pi"), infsupdec ("pi")));
%!warning assert (isequal (midrad (infsup (2), 2), infsupdec (0, 4)));
%!assert (isequal (midrad (2, infsup (2)), infsupdec (0, 4)));
%!warning assert (isequal (midrad (infsup (2), infsup (2)), infsupdec (0, 4)));
%!assert (isequal (midrad (2, infsupdec (2)), infsupdec (0, 4)));
%!assert (isequal (midrad (infsupdec (2), 2), infsupdec (0, 4)));
%!warning assert (isequal (midrad (infsup (2), infsupdec (2)), infsupdec (0, 4)));
%!assert (isequal (midrad (infsupdec (2), infsup (2)), infsupdec (0, 4)));
%!assert (isequal (midrad (infsupdec (2), infsupdec (2)), infsupdec (0, 4)));
%!xtest assert (isequal (midrad (1, magic (3)), infsupdec ([-7, 0, -5; -2, -4, -6; -3, -8, -1], [9, 2, 7; 4, 6, 8; 5, 10, 3])));
%!xtest assert (isequal (midrad (magic (3), 1), infsupdec ([7, 0, 5; 2, 4, 6; 3, 8, 1], [9, 2, 7; 4, 6, 8; 5, 10, 3])));
%!test "from the documentation string";
%! assert (isequal (midrad (42, 3), infsupdec (39, 45)));
%! assert (isequal (midrad (0, inf), entire ()));
%! assert (isequal (midrad ("1.1", "0.1"), infsupdec (1 - eps, "1.2")));
