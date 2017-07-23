## Copyright 2015-2016 Oliver Heimlich
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
## @deftypefun {@var{I} =} midrad (@var{M}, @var{R})
## @deftypefunx {@var{I} =} midrad (@var{M})
## @deftypefunx {@var{I} =} midrad ()
## @deftypefunx {[@var{M}, @var{R}] =} midrad (@var{I})
##
## Create an interval enclosure @var{I} for [@var{M}-@var{R}, @var{M}+@var{R}].
##
## With two output arguments, compute a rigorous midpoint @var{M} and
## radius @var{R} for interval @var{I}.
##
## Without input parameters, return the empty interval.  With only one input
## parameter, the radius @var{R} defaults to zero.
##
## Parameters can be simple numbers, intervals or interval literals as strings.
## If needed, broadcasting is performed.
##
## The result is not guaranteed to be tightest if parameters are given as
## strings.  This is due to intermediate results.  The infsupdec constructor
## with interval literals in uncertain form @code{m?ruE} can instead be used to
## create tight enclosures of decimal numbers with a radius.
##
## Accuracy (with one output argument): The result is an accurate enclosure.
## The result is tightest if @var{M} and @var{R} are floating-point numbers or
## intervals.
##
## Accuracy (with two output arguments): @var{M} is the interval's midpoint
## in binary64 precision, rounded to nearest and ties to even.  The returned
## radius @var{R} will make a tight enclosure of the interval together with
## @var{M}.  That is, @var{R} is the smallest binary64 number, which will make
## [@var{M}-@var{R}, @var{M}+@var{R}] enclose the interval @var{I}.
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
## @end deftypefun

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2015-03-06

function [m, r] = midrad (m, r)

  if (nargout > 1)
    warning ("off", "id=interval:ImplicitPromote", "local");
  endif

  switch nargin
    case 0
      i = infsupdec ();

    case 1
      if (nargout == 2 && isa (m, "infsup"))
        i = m;
      else
        i = infsupdec (m);
      endif

    case 2
      if (isfloat (m) && isreal (m) && ...
          isfloat (r) && isreal (r))
        ## Simple case: m and r are binary64 numbers
        l = mpfr_function_d ('minus', -inf, m, r);
        u = mpfr_function_d ('plus', +inf, m, r);
        i = infsupdec (l, u);
      else
        ## Complicated case: m and r are strings or other types
        m = infsupdec (m);
        if (not (isa (r, "infsup")))
          ## [-inf, r] should make a valid interval, unless r == -inf
          ## Intersection with non-negative numbers ensures that we
          ## return [Empty] if r < 0.
          if (isfloat (r))
            r(r == -inf) = nan;
          endif
          r = intersect (infsupdec (-inf, r), infsupdec (0, inf));
          ## Fix decoration, since intersect would return “trv” at best.
          legal_radius = not (isempty (r));
          r(legal_radius) = newdec (intervalpart (r(legal_radius)));
        endif
        if (isa (r, "infsupdec"))
          dec_r = decorationpart (r);
        else
          dec_r = {"com"};
        endif
        sup_r = sup (r);
        sup_r(sup_r < 0) = -inf;
        r = infsupdec (-sup_r, sup_r, dec_r);

        i = m + r;
      endif

    otherwise
      print_usage ();
  endswitch

  switch nargout
    case {0, 1}
      m = i;

    case 2
      m = mid (i);
      ## The midpoint is rounded to nearest and the radius
      ## must cover both boundaries
      r1 = mpfr_function_d ('minus', +inf, m, inf (i));
      r2 = mpfr_function_d ('minus', +inf, sup (i), m);
      r = max (r1, r2);

    otherwise
      print_usage ();
  endswitch

endfunction

%!assert (isempty (midrad ()));
%!warning id=interval:UndefinedOperation
%! assert (isnai (midrad (0, -inf)));
%!warning id=interval:UndefinedOperation
%! assert (isnai (midrad (0, -.1)));
%!warning id=interval:UndefinedOperation
%! assert (isnai (midrad (0, "-.1")));
%!warning id=interval:UndefinedOperation
%! assert (isnai (midrad (0, infsup("-.1"))));
%!assert (isequal (midrad ("pi"), infsupdec ("pi")));
%!warning id=interval:ImplicitPromote
%! assert (isequal (midrad (infsup (2), 2), infsupdec (0, 4)));
%!assert (isequal (midrad (2, infsup (2)), infsupdec (0, 4)));
%!warning id=interval:ImplicitPromote
%! assert (isequal (midrad (infsup (2), infsup (2)), infsupdec (0, 4)));
%!assert (isequal (midrad (2, infsupdec (2)), infsupdec (0, 4)));
%!assert (isequal (midrad (infsupdec (2), 2), infsupdec (0, 4)));
%!warning id=interval:ImplicitPromote
%! assert (isequal (midrad (infsup (2), infsupdec (2)), infsupdec (0, 4)));
%!assert (isequal (midrad (infsupdec (2), infsup (2)), infsupdec (0, 4)));
%!assert (isequal (midrad (infsupdec (2), infsupdec (2)), infsupdec (0, 4)));
%!assert (isequal (midrad (1, magic (3)), infsupdec ([-7, 0, -5; -2, -4, -6; -3, -8, -1], [9, 2, 7; 4, 6, 8; 5, 10, 3])));
%!assert (isequal (midrad (magic (3), 1), infsupdec ([7, 0, 5; 2, 4, 6; 3, 8, 1], [9, 2, 7; 4, 6, 8; 5, 10, 3])));
%!# from the documentation string
%!assert (isequal (midrad (42, 3), infsupdec (39, 45)));
%!assert (isequal (midrad (0, inf), entire ()));
%!assert (isequal (midrad ("1.1", "0.1"), infsupdec (1 - eps, "1.2")));

%!# N-dimensional arrays
%!assert (isequal (midrad (zeros (2, 2, 2), ones (2, 2, 2)), infsupdec (-ones (2, 2, 2), ones (2, 2, 2))));
%!assert (isequal (midrad (zeros (2, 2, 2), 1), infsupdec (-ones (2, 2, 2), ones (2, 2, 2))));
%!assert (isequal (midrad (0, ones (2, 2, 2)), infsupdec (-ones (2, 2, 2), ones (2, 2, 2))));
%!test
%! [M, R] = midrad (infsupdec (-ones (2, 2, 2), ones (2, 2, 2)));
%! assert (M, zeros (2, 2, 2));
%! assert (R, ones (2, 2, 2));
