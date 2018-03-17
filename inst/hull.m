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
## @defun hull (@var{X1}, @var{X2}, …)
##
## Create an interval enclosure for a list of parameters.
##
## Parameters can be simple numbers, intervals or interval literals as strings.
## If needed, broadcasting is performed.
##
## NaNs represent missing values and are treated like empty intervals.  Inf and
## -Inf can be used to create unbound intervals, but note that these values
## will not be members of the interval.  In particular, it is not possible to
## create an interval with @code{hull (inf)}.
##
## The result is equivalent to
## @code{union (infsupdec (@var{X1}), union (infsupdec (@var{X2}), …))}, but
## computed in a more efficient way.  In contrast to the union function, this
## function is not considered a set operation and the result carries the best
## possible decoration, which is allowed by the input parameters.
##
## Warning: This function is not defined by IEEE Std 1788-2015 and shall not be
## confused with the standard's convexHull function, which is implemented by
## @code{union}.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## hull (1, 4, 3, 2)
##   @result{} ans = [1, 4]_com
## hull (empty, entire)
##   @result{} ans = [Entire]_trv
## hull ("0.1", "pi", "e")
##   @result{} ans ⊂ [0.099999, 3.1416]_com
## hull ("[0, 3]", "[4, 7]")
##   @result{} ans = [0, 7]_com
## @end group
## @end example
## @seealso{@@infsupdec/union}
## @end defun

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2015-03-02

function result = hull (varargin)

  if (isempty (varargin))
    result = infsupdec ();
    return
  endif

  l = u = cell (size (varargin));

  ## Floating point numbers can be used without conversion
  floats = cellfun (@isfloat, varargin);
  l(floats) = u(floats) = varargin(floats);

  ## Convert everything else to interval, if necessary
  decoratedintervals = cellfun ("isclass", varargin, "infsupdec");
  to_convert = not (decoratedintervals | floats);
  ## Use infsupdec constructor for conversion, because it can handle decorated
  ## interval literals.  Also, it will trigger an interval:ImplicitPromote
  ## warning if necessary.
  varargin(to_convert) = cellfun (@infsupdec, varargin(to_convert), ...
                                  "UniformOutput", false ());
  decoratedintervals = not (floats);

  ## Extract inf and sup arrays for remaining elements of l and u.
  l(decoratedintervals) = cellfun (@inf, varargin(decoratedintervals), ...
                                   "UniformOutput", false ());
  u(decoratedintervals) = cellfun (@sup, varargin(decoratedintervals), ...
                                   "UniformOutput", false ());

  ## Broadcast nonsingleton dimensions (otherwise cat would throw an error below)
  numberofdimensions = max (cellfun ("ndims", l));
  sizes = zeros(numberofdimensions, size (l)(2));
  for dim = 1:numberofdimensions
    sizes(dim, :) = cellfun("size", l, dim);
  endfor
  targetsize = max (sizes, [], 2);
  warning ("off", "Octave:broadcast", "local");
  if (!all (or (targetsize == sizes, sizes == 1)(:)))
    error ("hull: dimensions mismatch")
  endif
  for dim = 1:numberofdimensions
    if (targetsize(dim) ~= 1)
      to_broadcast = sizes(dim, :) == 1;
      for i = find (to_broadcast)
        broadcastvector = ones (numberofdimensions, 1);
        broadcastvector(dim) = targetsize(dim);
        l{i} = repmat (l{i}, broadcastvector);
        u{i} = repmat (u{i}, broadcastvector);
      endfor
    endif
  endfor

  ## Compute min and max of inf and sup arrays, NaNs would be ignored and must
  ## be considered
  nans = false (targetsize);
  l = cat (numberofdimensions + 1, l{:});
  nans(any (isnan (l), numberofdimensions + 1)) = true;
  l = min (l, [], numberofdimensions + 1);
  u = cat (numberofdimensions + 1, u{:});
  nans(any (isnan (u), numberofdimensions + 1)) = true;
  u = max (u, [], numberofdimensions + 1);

  ## Compute best possible decoration
  dec = cell (targetsize);
  dec(:) = "com";
  dec(not (isfinite (l) & isfinite (u))) = "dac";
  dec(nans) = "trv";

  ## Consider input decorations
  if (any (decoratedintervals))
    dec = mindec (dec, cellfun (@decorationpart, ...
                                varargin(decoratedintervals), ...
                                "UniformOutput", false ()));
  endif

  nairesult = strcmp (dec, "ill");
  emptyresult = isnan (l) | isnan (u) | l > u | nairesult;
  l(emptyresult) = u(emptyresult) = 0;
  dec(nairesult) = "com";
  result = infsupdec (l, u, dec);
  result(emptyresult) = empty ();
  result(nairesult) = nai ();

endfunction

function decoration = mindec (decoration, decorations)

  ## Determine and apply the minimum decoration
  for i = 1 : length (decorations)
    if (iscell (decorations{i}) && not (isempty (decorations{i})))
      otherdecoration = decorations{i}{1};
    else
      otherdecoration = decorations{i};
    endif

    ## Only check distinct elements
    for n = find (not (strcmp (decoration, decorations{i})))(:)'
      if (iscell (decorations{i}) && not (isscalar (decorations{i})))
        otherdecoration = decorations{i}{n};
      else
        ## Scalars broadcast into the whole cell array. The value is set
        ## once before the inner for loop.
      endif

      ## Because of the simple propagation order com > dac > def > trv, we
      ## can use string comparison order.
      if (!strcmp (decoration{n}, "ill") && ...
          (strcmp (otherdecoration, "ill") || ...
           sign ((decoration{n}) - otherdecoration) * [4; 2; 1] < 0))
        decoration{n} = otherdecoration;
      endif
    endfor
  endfor

endfunction

%!assert (isnai (hull (nai)));
%!assert (isempty (hull (nan)));
%!assert (isequal (hull (2, nan, 3, 5), infsupdec (2, 5, "trv")));
%!assert (isequal (hull ([1, 2, 3], [5; 0; 2]), infsupdec ([1, 2, 3; 0, 0, 0; 1, 2, 2], [5, 5, 5; 1, 2, 3; 2, 2, 3], "com")));
%!assert (isequal (hull (magic (3), 10), infsupdec (magic (3), 10 (ones (3)), "com")));
%!assert (isequal (hull (2, magic (3), [nan, 2, 3; nan, 1, 1; 99, 100, nan]), infsupdec ([2, 1, 2; 2, 1, 1; 2, 2, 2], [8, 2, 6; 3, 5, 7; 99, 100, 2], {"trv", "com", "com"; "trv", "com", "com"; "com", "com", "trv"})));
%!assert (isnai (hull ([nai, 2])), logical ([1 0]));
%!assert (isnai (hull ([nai, 2], [nai, 3])), logical ([1 0]));
%!assert (isnai (hull ([nai, 2], nai)), logical ([1 1]));
%!assert (isnai (hull ([nai, 2], [2, nai])), logical ([1 1]));
%!assert (isequal (hull (zeros (2, 2, 2, 2), ones (2, 2, 2, 2)), infsupdec (zeros (2, 2, 2, 2), ones (2, 2, 2, 2))))
%!assert (isequal (hull (zeros (2, 1, 4, 1), ones (1, 3, 1, 5), -1), infsupdec (-ones (2, 3, 4, 5), ones (2, 3, 4, 5))))
%!assert (isnai (hull (zeros (2, 2, 2, 2), ones (2, 2, 2, 2), nai)), logical (ones (2, 2, 2, 2)))

%!error <dimensions mismatch> hull (1:2, 1:3);
%!error <dimensions mismatch> hull ((1:2)', (1:3)');
%!error <dimensions mismatch> hull (ones (2, 2, 2), ones (2, 2, 3));

%!test "from the documentation string";
%! assert (isequal (hull (1, 2, 3, 4), infsupdec (1, 4, "com")));
%! assert (isequal (hull (empty, entire), infsupdec (-inf, inf, "trv")));
%! assert (isequal (hull ("0.1", "pi", "e"), infsupdec (0.1 - eps / 16, pi + eps * 2, "com")));
%! assert (isequal (hull ("[0, 3]", "[4, 7]"), infsupdec ("[0, 7]_com")));
