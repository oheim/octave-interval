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
## @deftypefn {Interval Constructor} {[@var{X}, @var{ISEXACT}] =} infsup ()
## @deftypefnx {Interval Constructor} {[@var{X}, @var{ISEXACT}] =} infsup (@var{M})
## @deftypefnx {Interval Constructor} {[@var{X}, @var{ISEXACT}] =} infsup (@var{S})
## @deftypefnx {Interval Constructor} {[@var{X}, @var{ISEXACT}] =} infsup (@var{L}, @var{U})
## @cindex IEEE1788 numsToInterval
## @cindex IEEE1788 textToInterval
## 
## Create an interval from boundaries.  Convert boundaries to double precision.
##
## The syntax without parameters creates an (exact) empty interval.  The syntax
## with a single parameter @code{infsup (@var{M})} equals
## @code{infsup (@var{M}, @var{M})}.  The syntax @code{infsup (@var{S})} parses
## an interval literal in inf-sup form or as a special value, where
## @code{infsup ("[S1, S2]")} is equivalent to @code{infsup ("S1", "S2")}.  A
## second, logical output @var{ISEXACT} indicates if @var{X}'s boundaries both
## have been converted without precision loss.
##
## Each boundary can be provided in the following formats: literal constants
## [+-]inf[inity], e, pi; scalar real numeric data types, i. e., double,
## single, [u]int[8,16,32,64]; or decimal numbers as strings of the form
## [+-]d[,.]d[[eE][+-]d].
## 
## If decimal numbers are no binary64 floating point numbers, a tight enclosure
## will be computed.  int64 and uint64 numbers of high magnitude (> 2^53) can
## also be affected from precision loss.
##
## Non-standard behavior: This class constructor is not described by IEEE 1788,
## however it implements both IEEE 1788 functions numsToInterval and
## textToInterval.
## 
## @example
## @group
## v = infsup ()
##   @result{} [Empty]
## w = infsup ("[1]")
##   @result{} [1]
## x = infsup (2, 3)
##   @result{} [2, 3]
## y = infsup ("0.1")
##   @result{} [.09999999999999999, .10000000000000001]
## z = infsup ("0.1", "0.2")
##   @result{} [.09999999999999999, .20000000000000002]
## @end group
## @end example
## @seealso{exacttointerval}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-09-27

function [x, isexact] = infsup (l, u)

if (nargin == 0)
    ## representation of the empty interval is always [inf,-inf]
    l = inf;
    u = -inf;
endif

if (nargin == 1)
    if (ischar (l) && not (isempty (l)) && l(1) == "[" && l(end) == "]")
        ## Parse interval literal
        
        ## Strip square brackets and whitespace
        s = strtrim (l(2:end-1));
        
        switch lower (s)
            case "entire"
                l = -inf;
                u = inf;
            case {"empty", ""}
                l = inf;
                u = -inf;
            otherwise
                s = strsplit (s, ",");
                if (isempty (s) || length (s) > 2)
                    error ("interval literal is not in inf-sup form")
                endif
                l = strtrim (s{1});
                if (length (s) == 1)
                    u = l;
                else
                    u = strtrim (s{2});
                endif
        endswitch    
    else
        ## syntax infsup (x) has to be equivalent with infsup (x, x)
        u = l;
    endif
endif

x.inf = l;
x.sup = u;
isexact = true ();

## check parameters and conversion to double precision
for [boundary, key] = x
    if (isempty (boundary))
        switch key
            case "inf"
                x.inf = -inf;
            case "sup"
                x.sup = inf;
        endswitch
        continue
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
            x.(key) = double (boundary);
            continue
        endif
        
        ## Integer or logical, try to approximate in double precision
        x.(key) = double (boundary);
        isexact = and (isexact, x.(key) == boundary);
        
        ## Check rounding direction of the approximation
        ## Mixed mode comparison works as intended
        if (x.(key) == boundary || ... # exact conversion
            (x.(key) < boundary && key == "inf") || ... # lower bound
            (x.(key) > boundary && key == "sup")) # upper bound
            ## Conversion to double has used desired rounding direction
        else
            ## Approximation is not exact and not rounded as needed.
            ## However, because of faithful rounding the approximation
            ## is right next to the desired number.
            switch key
                case "inf"
                    x.inf = nextdown (x.inf);
                case "sup"
                    x.sup = nextup (x.sup);
            endswitch
        endif
    elseif (not (ischar (boundary)))
        error (["illegal " key " boundary: must be numeric or string"]);
    else
        ## parse string
        switch lower(boundary)
            case {"-inf", "-infinity"}
                x.(key) = -inf;
            case {"inf", "+inf", "infinity", "+infinity"}
                x.(key) = inf;
            case "e"
                isexact = false ();
                switch key
                    case "inf"
                        x.inf = 0x56FC2A2 * pow2 (-25) ...
                                     + 0x628AED2 * pow2 (-52);
                    case "sup"
                        x.sup = 0x56FC2A2 * pow2 (-25) ...
                                     + 0x628AED4 * pow2 (-52);
                endswitch
            case "pi"
                isexact = false ();
                switch key
                    case "inf"
                        x.inf = 0x6487ED5 * pow2 (-25) ...
                                     + 0x442D180 * pow2 (-55);
                    case "sup"
                        x.sup = 0x6487ED5 * pow2 (-25) ...
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
                                x.inf = -inf;
                            else # realmax ... inf
                                x.inf = realmax ();
                            endif
                        case "sup"
                            if (decimal.s) # -inf ... -realmax
                                x.sup = -realmax ();
                            else # realmax ... inf
                                x.sup = inf;
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
                    x.(key) = binary;
                else
                    ## Approximation is not exact and not rounded as needed.
                    ## However, because of faithful rounding the approximation
                    ## is right next to the desired number.
                    switch key
                        case "inf"
                            x.inf = nextdown (binary);
                        case "sup"
                            x.sup = nextup (binary);
                    endswitch
                endif
        endswitch
    endif
endfor

assert (isa (x.inf, "double"));
assert (isa (x.sup, "double"));
assert (not (isnan (x.inf)));
assert (not (isnan (x.sup)));

## normalize boundaries:
## representation of the set containing only zero is always [-0,+0]
if (x.inf == 0)
    x.inf = -0;
endif
if (x.sup == 0)
    x.sup = +0;
endif

## check for illegal boundaries [inf,inf] and [-inf,-inf]
if (isequal (x.inf, x.sup, inf) || ...
    isequal (x.inf, x.sup, -inf))
    error ("illegal interval boundaries: infimum = supremum = +/- infinity");
endif

## check boundary order
if (x.inf > x.sup)
    if (isfinite (x.inf) || isfinite (x.sup))
        error ("illegal interval boundaries: infimum greater than supremum");
    else
        ## okay: empty set [inf;-inf]
    endif
endif

x = class (x, "infsup");
endfunction
