## Copyright 2014 Oliver Heimlich
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
## @deftypefn {Function File} {@var{XD} =} decorateresult (@var{RESULT}, @{@var{INPUTPARAMETERS}...@})
## @deftypefnx {Function File} {@var{XD} =} decorateresult (@var{RESULT}, @{@var{INPUTPARAMETERS}...@}, @var{MAXDEC})
## 
## Create a decorated interval result (of an arithmetic function) by decorating
## the bare @var{RESULT} with the minimum of decorations from the
## @var{INPUTPARAMETERS}.
##
## Using a third input parameter, it is possible do define a maximum decoration
## for the final interval, e. g., if the arithmetic function is undefined or
## not continuous for some of the input parameters.
##
## @example
## @group
## decorateresult (entire (), {empty ()})
##   @result{} [Entire]_trv
## @end group
## @end example
## @seealso{newdec}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-13

function decorated = decorateresult (result, inputparameters, maxdec)

assert (nargin >= 1);

if (isa (result, "infsupdec"))
    ## result is already decorated
    decorated = result;
else
    assert (isa (result, "infsup"));
    ## result is a bare interval, apply best possible decoration
    decorated = newdec (result);
endif

if (isnai (decorated))
    return
endif

if (nargin >= 2)
    decorations = cell (length (inputparameters) + nargin - 2, 1);
    for i = 1:length(inputparameters)
        assert (isa (inputparameters{i}, "infsupdec"));
        if (isnai (inputparameters{i}))
            decorated = inputparameters{i};
            return
        endif
        decorations{i} = decorationpart (inputparameters{i});
    endfor

    if (nargin >= 3)
        assert (ischar (maxdec));
        assert (max (strcmp (maxdec, {"com", "dac", "def", "trv"})));
        decorations{end} = maxdec;
    endif
    
    ## Determine and apply the minimum decoration
    for i = 1:length(decorations)
        ## Because of the simple propagation order com > dac > def > trv, we
        ## can use string comparison order.
        if (sign (decorationpart (decorated) - decorations{i}) * [4; 2; 1] < 0)
            decorated = infsupdec (inf (decorated), sup (decorated), ...
                                   decorations{i});
        endif
    endfor
endif

endfunction