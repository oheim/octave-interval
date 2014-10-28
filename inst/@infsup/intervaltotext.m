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
## @deftypefn {Interval Output} {@var{S} =} intervaltotext (@var{X})
## @deftypefnx {Interval Output} {@var{S} =} intervaltotext (@var{X}, @var{EXACT})
## @cindex IEEE1788 intervalToText
## 
## Build an approximate representation of the interval @var{X} in decimal
## format.
##
## The interval boundaries are stored in binary floating point format and are
## converted to decimal format with possible precision loss. If output is not
## exact, the boundaries are rounded accordingly (e. g. the upper boundary is
## rounded towards infinite for output representation).
##
## Enough decimal digits are used to ensure separation of subsequent floting
## point numbers.
##
## Accuracy: For all intervals @var{X} is an accurate subset of
## @code{texttointerval (intervaltotext (@var{X}))}.  If parameter @var{EXACT}
## is used and is set to @code{True} the output is exact.
##
## @example
## @group
## x = infsup (1 + eps);
## intervaltotext (x)
##   @result{} [1.0000000000000002, 1.0000000000000003]
## y = nextout (x);
## intervaltotext (y)
##   @result{} [1, 1.0000000000000005]
## z = infsup (1);
## intervaltotext (z)
##   @result{} [1]
## @end group
## @end example
## @seealso{intervaltoexact}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-09-30

function [s, isexact] = intervaltotext (x, exact)

assert (numel (x) == 1, "not supported for interval vectors / matrix");

isexact = true ();

if (isempty (x))
    s = "[Empty]";
    return
endif

if (isentire (x))
    s = "[Entire]";
    return
endif

if (nargin < 2)
    exact = false ();
endif

signpresent = false ();
boundaries.inf = x.inf;
boundaries.sup = x.sup;
for [boundary, key] = boundaries
    ## Sign
    if (boundary == 0)
        ## Never use a sign for zero
        boundarystring.(key) = "0";
        continue
    elseif (boundary < 0)
        ## Negative numbers must have a sign
        boundarystring.(key) = "-";
        signpresent = true ();
    elseif (signpresent)
        ## Positive numbers only get a sign if there also is a negative
        ## number present as an interval boundary
        boundarystring.(key) = "+";
    else
        boundarystring.(key) = "";
    endif
    
    if (not (isfinite (boundary)))
        boundarystring.(key) = strcat (boundarystring.(key), "Inf");
    else # boundary != 0, -inf, inf
        decimal = double2decimal (boundary);
        if (not (exact))
            ## We want the following number of digits in the output:
            ##   1. Two different interval boundary values must have two
            ##      different output representations
            ##   2. The number of digits in the output must be as small
            ##      as possible
            ##   3. Within these constraints the decimal number of the output
            ##      must be as exact as possible
            ##   4. If the decimal output is not exact, the boundaries must be
            ##      rounded in the right direction
    
            ## Calculate distance to next possible interval boundary.
            if (key == "inf" && boundary > -realmax () || ...
                key == "sup" && boundary == realmax ())
                fesetround (inf);
                numberdistance = boundary - nextdown (boundary);
            else
                fesetround (inf);
                numberdistance = nextup (boundary) - boundary;
            endif
            fesetround (0.5);
            
            assert (0 < numberdistance);
            assert (isfinite (numberdistance));
    
            keepfractiondigits = floor (-log10 (numberdistance)) + 1;
        
            ## Insert trailing zeroes
            decimal.m = [decimal.m; zeros(decimal.e + keepfractiondigits ...
                      - length (decimal.m), 1)];
                      
            accurracylost = find (decimal.m(...
                    decimal.e + keepfractiondigits + 1 : end) ~= 0, 1);
            
            isexact = isexact && isempty (accurracylost);
            
            ## Strip irrelevant digits (round towards zero)
            decimal.m = decimal.m(1 : decimal.e + keepfractiondigits);
            
            ## Fix rounding if round towards zero was wrong direction
            if (accurracylost && ...
                ((decimal.s && key == "inf") || ...
                (not (decimal.s) && key == "sup")))
                decimal.m(end) += 1;
                while (find (decimal.m >= 10, 1))
                    decimal.m = [0; rem(decimal.m, 10)] ...
                              + [floor(decimal.m ./ 10); 0];
                    if (decimal.m(1) == 0)
                        decimal.m(1) = [];
                    else
                        decimal.e ++;
                    endif
                endwhile
            endif
        endif
        
        ## Normalize mantissa: remove trailing zeroes;
        decimal.m = decimal.m(1 : find (decimal.m ~= 0, 1, "last"));
        
        ## Shall the boundary be printed with or without exponent notation?
        digitsbeforepoint = max (0, decimal.e);
        digitsafterpoint = max (0, length (decimal.m) - decimal.e);
        if (digitsbeforepoint + digitsafterpoint <= ...
            max (12, ... # always print up to 12 total decimal digits without
                         # exponent notation
                length (decimal.m) + 2)) # don't use exponent notation
                                         # if that would be longer
            
            ## format XXXXX.XXXX
            
            ## Insert trailing zeroes for integer numbers up to the decimal
            ## point
            decimal.m = [decimal.m;
                         zeros(digitsbeforepoint - length (decimal.m), 1)];
            
            ## Insert leading zeroes for fractions up to the decimal point
            if (digitsafterpoint > length (decimal.m))
                decimal.m = [...
                    zeros(digitsafterpoint - length (decimal.m), 1); ...
                    decimal.m ];
                decimal.e += digitsafterpoint - length (decimal.m);
            endif
            
            if (decimal.e >= 1)
                boundarystring.(key) = strcat (boundarystring.(key), ...
                    num2str (decimal.m(1 : decimal.e))');
            endif
            if (decimal.e < length (decimal.m))
                boundarystring.(key) = strcat (boundarystring.(key), ".", ...
                    num2str (decimal.m(max (1, decimal.e + 1) : end))');
            endif
        else
            ## format X.XXXXeXX
            boundarystring.(key) = strcat (boundarystring.(key), ...
                num2str (decimal.m(1)));
            if (length (decimal.m) > 1)
                boundarystring.(key) = strcat (boundarystring.(key), ".", ...
                                               num2str (decimal.m(2:end))');
            endif
            if (decimal.e ~= 1)
                boundarystring.(key) = strcat (boundarystring.(key), "e", ...
                                               num2str (decimal.e - 1));
            endif
        endif
    endif
endfor

if (strcmp(boundarystring.inf, boundarystring.sup))
    ## Interval contains a single number and the string representation
    ## is equal for both boundaries.
    s = ["[" boundarystring.inf "]"];
else
    s = ["[" boundarystring.inf ", " boundarystring.sup "]"];
endif

endfunction