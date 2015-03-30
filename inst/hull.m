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
## @deftypefn {Function File} {} hull (@var{X1}, @var{X2}, …)
## 
## Return an interval enclosure for a list of parameters.
##
## Parameters can be simple numbers, intervals or interval literals as strings.
## Scalar values or scalar intervals do broadcast if combined with matrices or
## interval matrices.
##
## NaNs represent missing values and are treated like empty intervals.
##
## The result is equivalent to 
## @code{infsupdec (@var{X1}) | infsupdec (@var{X2}) | …}, but computed in a
## more efficient way and may carry a decoration other than @code{trv}.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## hull (1, 4, 3, 2)
##   @result{} [1, 4]_com
## hull (empty, entire)
##   @result{} [Entire]_trv
## hull ("0.1", "pi", "e")
##   @result{} [.09999999999999999, 3.1415926535897936]_com
## hull ("[0, 3]", "[4, 7]")
##   @result{} [0, 7]_com
## @end group
## @end example
## @seealso{@@infsup/or}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2015-03-02

function result = hull (varargin)

l = u = cell (size (varargin));

## Floating point numbers can be used without conversion
floats = cellfun (@isfloat, varargin);
l (floats) = u (floats) = varargin (floats);

## Convert everything else to interval, if necessary
decoratedintervals = cellfun ("isclass", varargin, "infsupdec");
to_convert = not (decoratedintervals | floats);
## Use infsupdec constructor for conversion, because it can handle decorated
## interval literals.  Also, it will trigger an interval:ImplicitPromote
## warning if necessary.
varargin (to_convert) = cellfun (@infsupdec, varargin (to_convert), ...
                                 "UniformOutput", false ());
decoratedintervals = not (floats);

nais = cellfun (@isnai, varargin (decoratedintervals));
if (any (nais))
    ## Simply return first NaI
    result = varargin (decoratedintervals) {find (nais, 1)};
    return
endif

## Extract inf and sup matrices for remaining elements of l and u.
l (decoratedintervals) = cellfun (@inf, varargin (decoratedintervals), ...
                                  "UniformOutput", false ());
u (decoratedintervals) = cellfun (@sup, varargin (decoratedintervals), ...
                                  "UniformOutput", false ());

## Broadcast nonsingleton dimensions (otherwise cat would throw an error below)
sizes1 = cellfun ("size", l, 1);
sizes2 = cellfun ("size", l, 2);
targetsize = [max(sizes1) max(sizes2)];
if ((targetsize (1) ~= 1 && min (sizes1 (sizes1 ~= 1)) ~= targetsize (1))
    || (targetsize (2) ~= 1 && min (sizes2 (sizes2 ~= 1)) ~= targetsize (2)))
    error ("hull: dimension mismatch")
endif
if (any (targetsize ~= [1 1]))
    to_broadcast = sizes1 ~= targetsize (1) ...
                 | sizes2 ~= targetsize (2);
    if (any (to_broadcast))
        for i = find (to_broadcast)
            if (size (l {i}, 1) ~= targetsize (1))
                ## Broadcast 1st dimension
                l {i} = l {i} (ones (targetsize (1), 1), :);
                u {i} = u {i} (ones (targetsize (1), 1), :);
            endif
            if (size (l {i}, 2) ~= targetsize (2))
                ## Broadcast 2nd dimension
                l {i} = l {i} (:, ones (targetsize (2), 1));
                u {i} = u {i} (:, ones (targetsize (2), 1));
            endif
        endfor
    endif
endif

## Compute min and max of inf and sup matrices, NaNs would be ignored and must
## be considered
nans = false (targetsize);
l = cat (3, l {:});
nans (any (isnan (l), 3)) = true;
l = min (l, [], 3);
u = cat (3, u {:});
nans (any (isnan (u), 3)) = true;
u = max (u, [], 3);

## Compute best possible decoration
dec = cell (targetsize);
dec (:) = "com";
dec (not (isfinite (l) & isfinite (u))) = "dac";
dec (nans) = "trv";

## Consider input decorations
if (any (decoratedintervals))
    dec = mindec (dec, cellfun (@decorationpart, ...
                                varargin (decoratedintervals), ...
                                "UniformOutput", false ()));
endif

result = infsupdec (l, u, dec);

endfunction

function decoration = mindec (decoration, decorations)

## Determine and apply the minimum decoration
for i = 1 : length (decorations)
    if (iscell (decorations {i}) && not (isempty (decorations {i})))
        otherdecoration = decorations {i} {1};
    else
        otherdecoration = decorations {i};
    endif

    ## Only check distinct elements
    for n = find (not (strcmp (decoration, decorations {i}))) (:)'
        if (iscell (decorations {i}) && not (isscalar (decorations {i})))
            otherdecoration = decorations {i} {n};
        else
            ## Scalars broadcast into the whole cell array. The value is set
            ## once before the inner for loop.
        endif

        ## Because of the simple propagation order com > dac > def > trv, we
        ## can use string comparison order.
        if (sign ((decoration {n}) - otherdecoration) * [4; 2; 1] < 0)
            decoration {n} = otherdecoration;
        endif
    endfor
endfor

endfunction

%!assert (isnai (hull (nai)));
%!assert (isempty (hull (nan)));
%!assert (isequal (hull (2, nan, 3, 5), infsupdec (2, 5, "trv")));
%!xtest assert (isequal (hull ([1, 2, 3], [5; 0; 2]), infsupdec ([1, 2, 3; 0, 0, 0; 1, 2, 2], [5, 5, 5; 1, 2, 3; 2, 2, 3], "com")));
%!xtest assert (isequal (hull (magic (3), 10), infsupdec (magic (3), 10 (ones (3)), "com")));
%!xtest assert (isequal (hull (2, magic (3), [nan, 2, 3; nan, 1, 1; 99, 100, nan]), infsupdec ([2, 1, 2; 2, 1, 1; 2, 2, 2], [8, 2, 6; 3, 5, 7; 99, 100, 2], {"trv", "com", "com"; "trv", "com", "com"; "com", "com", "trv"})));
%!test "from the documentation string";
%! assert (isequal (hull (1, 2, 3, 4), infsupdec (1, 4, "com")));
%! assert (isequal (hull (empty, entire), infsupdec (-inf, inf, "trv")));
%! assert (isequal (hull ("0.1", "pi", "e"), infsupdec (0.1 - eps / 16, pi + eps * 2, "com")));
%! assert (isequal (hull ("[0, 3]", "[4, 7]"), infsupdec ("[0, 7]_com")));
