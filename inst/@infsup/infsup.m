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

## usage: INTERVAL = infsup ()
## usage: [INTERVAL, ISEXACT] = infsup (X)
## usage: [INTERVAL, ISEXACT] = infsup (L, U)
##
## Create an interval from boundaries.  Convert boundaries to double precision.
##
## The syntax without parameters creates an (exact) empty interval.  The syntax
## with a single parameter infsup (X) equals infsup (X, X).  A second, logical
## output ISEXACT indicates if INTERVAL's boundaries both have been converted
## without precision loss.
##
## Each boundary can be provided in the following formats:
##  - literal constants: [+-]inf[inity], e, pi
##  - scalar real numeric data types, i. e., double, single, [u]int[8,16,32,64]
##  - decimal numbers as strings of the form [+-]d[,.]d[[eE][+-]d]
## 
## If decimal numbers are no binary64 floating point numbers, a tight enclosure
## will be computed.  int64 and uint64 numbers of high magnitude (> 2^53) can
## also be affected from precision loss.
##
## Example:
##  v = infsup ();             # empty interval
##  w = infsup (1);            # interval containing only the number 1
##  x = infsup (2, 3);         # interval from 2 to 3 (inclusive)
##  y = infsup ("0.1");        # interval enclosure of the number 0.1
##  z = infsup ("0.1", "0.2"); # interval enclosure of numbers from 0.1 to 0.2

## Author: Oliver Heimlich
## Keywords: interval constructor
## Created: 2014-09-27

function [interval, isexact] = infsup (l, u)

if (nargin == 0)
    ## representation of the empty interval is always [inf,-inf]
    l = inf;
    u = -inf;
endif

if (nargin == 1)
    ## syntax infsup (x) has to be equivalent with infsup (x, x)
    u = l;
endif

interval.inf = l;
interval.sup = u;
isexact = true ();

## check parameters and conversion to double precision
for [boundary, key] = interval
    if (isempty (boundary))
        error (["illegal " key " boundary: must not be empty"]);
    endif
    
    if (isnumeric (boundary))
        if (max (size (boundary)) ~= 1)
            error (["illegal " key " boundary: must be a single number"]);
        endif
        if (not (isreal (boundary)))
            error (["illegal " key " boundary: must not be complex"]);
        endif
        if (isfloat (boundary))
            if (isnan (boundary))
                error (["illegal " key " boundary: NaN not allowed"]);
            endif
            ## Simple case: the boundary already is a binary floating point
            ## number is single or double precision.
            interval.(key) = double (boundary);
            continue
        endif
        
        ## Integer or logical, try to approximate in double precision
        interval.(key) = double (boundary);
        isexact = and (isexact, interval.(key) == boundary);
        
        ## Check rounding direction of the approximation
        ## Mixed mode comparison works as intended
        if (interval.(key) == boundary || ... # exact conversion
            (interval.(key) < boundary && key == "inf") || ... # lower bound
            (interval.(key) > boundary && key == "sup")) # upper bound
            ## Conversion to double has used desired rounding direction
        else
            ## Approximation is not exact and not rounded as needed.
            ## However, because of faithful rounding the approximation
            ## is right next to the desired number.
            switch key
                case "inf"
                    interval.(key) = nextdown (interval.(key));
                case "sup"
                    interval.(key) = nextup (interval.(key));
            endswitch
        endif
    elseif (not (ischar (boundary)))
        error (["illegal " key " boundary: must be numeric or string"]);
    else
        ## parse string
        switch lower(boundary)
            case {"-inf", "-infinity"}
                interval.(key) = -inf;
            case {"inf", "+inf", "infinity", "+infinity"}
                interval.(key) = inf;
            case "e"
                isexact = false ();
                switch key
                    case "inf"
                        interval.inf = 0x56FC2A2 * pow2 (-25) ...
                                     + 0x628AED2 * pow2 (-52);
                    case "sup"
                        interval.sup = 0x56FC2A2 * pow2 (-25) ...
                                     + 0x628AED4 * pow2 (-52);
                endswitch
            case "pi"
                isexact = false ();
                switch key
                    case "inf"
                        interval.inf = 0x6487ED5 * pow2 (-25) ...
                                     + 0x442D180 * pow2 (-55);
                    case "sup"
                        interval.sup = 0x6487ED5 * pow2 (-25) ...
                                     + 0x442D190 * pow2 (-55);
                endswitch
            otherwise
                ## We have to parse a string boundary and round the result
                ## up or down depending on the boundary (inf = down, sup = up).
                ## str2double will produce the correct answer in 50 % of all
                ## cases, because it uses rounding mode “to nearest”.
                ## The input and a double format approximation can be compared
                ## in a decimal floating point format without precision loss.
                
                ## Parse input
                decimal = str2decimal (boundary);
                
                ## Check if number is outside of range
                ## Realmax == 1.7...e308 == 0.17...e309
                if (decimal.e > 309 || ...
                    (decimal.e == 309 && ...
                        decimal.s && ...
                        decimalcompare (double2decimal (-realmax ()), ...
                                        decimal) > 0) || ...
                    (decimal.e == 309 && ...
                        not (decimal.s) && ...
                        decimalcompare (double2decimal (realmax ()), ...
                                        decimal) < 0))
                    switch key
                        case "inf"
                            if (decimal.s) # -inf ... -realmax
                                interval.(key) = -inf;
                            else # realmax ... inf
                                interval.(key) = realmax ();
                            endif
                        case "sup"
                            if (decimal.s) # -inf ... -realmax
                                interval.(key) = -realmax ();
                            else # realmax ... inf
                                interval.(key) = inf;
                            endif
                    endswitch
                    isexact = false ();
                    continue
                endif
                
                ## Compute approximation, this only works between +/- realmax
                binary = str2double (boundary);
                
                ## Check approximation value
                comparison = decimalcompare (double2decimal (binary), decimal);
                isexact = and (isexact, comparison == 0);
                if (comparison == 0 || ... # approximation is exact
                    (comparison < 0 && key == "inf") || ... # lower bound
                    (comparison > 0 && key == "sup")) # upper bound
                    interval.(key) = binary;
                else
                    ## Approximation is not exact and not rounded as needed.
                    ## However, because of faithful rounding the approximation
                    ## is right next to the desired number.
                    switch key
                        case "inf"
                            interval.(key) = nextdown (binary);
                        case "sup"
                            interval.(key) = nextup (binary);
                    endswitch
                endif
        endswitch
    endif
endfor

assert (isa (interval.inf, "double"));
assert (isa (interval.sup, "double"));
assert (not (isnan (interval.inf)));
assert (not (isnan (interval.sup)));

## normalize boundaries:
## representation of the set containing only zero is always [-0,+0]
if (interval.inf == 0)
    interval.inf = -0;
endif
if (interval.sup == 0)
    interval.sup = +0;
endif

## check for illegal boundaries [inf,inf] and [-inf,-inf]
if (isequal (interval.inf, interval.sup, inf) || ...
    isequal (interval.inf, interval.sup, -inf))
    error ("illegal interval boundaries: infimum = supremum = +/- infinity");
endif

## check boundary order
if (interval.inf > interval.sup)
    if (isfinite (interval.inf) || isfinite (interval.sup))
        error ("illegal interval boundaries: infimum greater than supremum");
    else
        ## okay: empty set [inf;-inf]
    endif
endif

interval = class (interval, "infsup");
endfunction
