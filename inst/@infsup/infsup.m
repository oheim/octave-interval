## Copyright 2014-2015 Oliver Heimlich
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
## @deftypefn {Function File} {[@var{X}, @var{ISEXACT}] =} infsup ()
## @deftypefnx {Function File} {[@var{X}, @var{ISEXACT}] =} infsup (@var{M})
## @deftypefnx {Function File} {[@var{X}, @var{ISEXACT}] =} infsup (@var{S})
## @deftypefnx {Function File} {[@var{X}, @var{ISEXACT}] =} infsup (@var{L}, @var{U})
## 
## Create an interval (from boundaries).  Convert boundaries to double
## precision.
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
## [+-]d[,.]d[[eE][+-]d]; or hexadecimal numbers as string of the form
## [+-]0xh[,.]h[[pP][+-]d]; or decimal numbers in rational form
## [+-]d/d.
##
## Also it is possible, to construct intervals from the uncertain form in the
## form @code{m?ruE}, where @code{m} is a decimal mantissa,
## @code{r} is empty (= half ULP) or a decimal integer ULP count or a
## second @code{?} character for unbounded intervals, @code{u} is
## empty or a direction character (u: up, d: down), and @code{E} is an
## exponential field.
## 
## If decimal or hexadecimal numbers are no binary64 floating point numbers, a
## tight enclosure will be computed.  int64 and uint64 numbers of high
## magnitude (> 2^53) can also be affected from precision loss.
##
## Non-standard behavior: This class constructor is not described by IEEE 1788,
## however it implements both IEEE 1788 functions numsToInterval and
## textToInterval.
## 
## @example
## @group
## infsup ()
##   @result{} [Empty]
## infsup ("[1]")
##   @result{} [1]
## infsup (2, 3)
##   @result{} [2, 3]
## infsup ("0.1")
##   @result{} [.09999999999999999, .10000000000000001]
## infsup ("0.1", "0.2")
##   @result{} [.09999999999999999, .20000000000000002]
## infsup ("0xff", "0x1.ffp14")
##   @result{} [255, 32704]
## infsup ("1/3")
##   @result{} [.33333333333333331, .33333333333333338]
## infsup ("[1/9, 47/11]")
##   @result{} [.1111111111111111, 4.2727272727272734]
## infsup ("7.3?9u")
##   @result{} [7.2999999999999998, 8.200000000000002]
## infsup ("0??")
##   @result{} [Entire]
## infsup ("911??de-2")
##   @result{} [-Inf, +9.110000000000002]
## infsup ("10?")
##   @result{} [9.5, 10.5]
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
    if (ischar (l))
        l = cellstr (l);
    endif
    if (iscell (l))
        ## Parse interval literals
        c = lower (l);
        u = cell (size (c));
        
        for i = 1 : numel (l)
            if (ischar (l {i}) && not (isempty (c {i})) && ...
                c {i} ([1, end]) == "[]")
                ## Strip square brackets and whitespace
                nobrackets = strtrim (c {i} (2 : (end-1)));
                switch nobrackets
                    case "entire"
                        l {i} = -inf;
                        u {i} = inf;
                    case {"empty", ""}
                        l {i} = inf;
                        u {i} = -inf;
                    otherwise
                        boundaries = strtrim (strsplit (nobrackets, ","));
                        switch (numel (boundaries))
                            case 1
                                l {i} = u {i} = boundaries {1};
                            case 2
                                l {i} = boundaries {1};
                                u {i} = boundaries {2};
                            otherwise
                                error ("interval:InvalidOperand", ...
                                    "interval literal is not in inf-sup form")
                        endswitch
                endswitch
            elseif (ischar (l {i}) && strfind (c {i}, "?"))
                ## Uncertain form: At this point we only split lower and upper
                ## boundary and remove the ??. ULP arithmetic is performed
                ## below when parsing the decimal number.
                if (strfind (c {i}, "u")) # up
                    ## The uncertainty only affects the upper boundary
                    l {i} = strcat (...
                            c {i} (1 : (find (c {i} == "?", 1) - 1)), ...
                            c {i} ((find (c {i} == "u", 1) + 1) : end));
                    u {i} = strrep (c {i} (1 : end), "u", "");
                elseif (strfind (c {i}, "d")) # down
                    ## The uncertainty only affects the lower boundary
                    l {i} = strrep (c {i} (1 : end), "d", "");
                    u {i} = strcat (...
                            c {i} (1 : (find (c {i} == "?", 1) - 1)), ...
                            c {i} ((find (c {i} == "d", 1) + 1) : end));
                else
                    ## The uncertainty affects both boundaries
                    l {i} = u {i} = c {i};
                endif
                if (strfind (l {i}, "??"))
                    l {i} = -inf;
                endif
                if (strfind (u {i}, "??"))
                    u {i} = inf;
                endif
            else
                ## syntax infsup (x) has to be equivalent with infsup (x, x)
                u {i} = l {i};
            endif
        endfor
    else # not cell or char
        ## syntax infsup (x) has to be equivalent with infsup (x, x)
        u = l;
    endif
endif

if (ischar (l))
    l = cellstr (lower (l));
endif
if (ischar (u))
    u = cellstr (lower (u));
endif

if (not (size_equal (l, u)))
    error ("interval:InvalidOperand", ...
           "infsup: size of upper and lower bounds must match")
endif

## check parameters and conversion to double precision
isexact = true ();
possiblyundefined = false (size (l));
x.inf = zeros (size (l));
x.sup = zeros (size (u));
input.inf = l;
input.sup = u;
for [boundaries, key] = input
    if (isfloat (boundaries))
        ## Simple case: the boundaries already are a binary floating point
        ## number in single or double precision.
        x.(key) = double (boundaries);
        possiblyundefined (:) = false ();
        continue
    endif
    for i = 1 : numel (boundaries)
        if (iscell (boundaries))
            boundary = boundaries {i};
            if (ischar (boundary))
                boundary = lower (boundary);
            endif
        else
            boundary = boundaries (i);
        endif

        if (isempty (boundary))
            switch key
                case "inf"
                    x.inf (i) = -inf;
                case "sup"
                    x.sup (i) = inf;
                    possiblyundefined (i) = false ();
            endswitch
        elseif (isnumeric (boundary))
            if (not (isreal (boundary)))
                error ("interval:InvalidOperand", ...
                       ["illegal " key " boundary: must not be complex"]);
            endif
            if (isfloat (boundary))
                ## Simple case: the boundary already is a binary floating point
                ## number in single or double precision.
                x.(key) (i) = double (boundary);
                possiblyundefined (i) = false ();
                continue
            endif
            
            ## Integer or logical, try to approximate in double precision
            x.(key) (i) = double (boundary);
            isdouble = x.(key) (i) == boundary;
            if (not (isdouble))
                isexact = false;
                if (key == "inf")
                    possiblyundefined (i) = true ();
                endif
            else
                possiblyundefined (i) = false ();
            end
            
            ## Check rounding direction of the approximation
            ## Mixed mode comparison works as intended
            if (isdouble || ... # exact conversion
                (x.(key) (i) < boundary && key == "inf") || ... # lower bound
                (x.(key) (i) > boundary && key == "sup")) # upper bound
                ## Conversion to double has used desired rounding direction
            else
                ## Approximation is not exact and not rounded as needed.
                ## However, because of faithful rounding the approximation
                ## is right next to the desired number.
                switch key
                    case "inf"
                        x.inf (i) = mpfr_function_d ('minus', +inf, ...
                                        x.inf (i), pow2 (-1074));
                    case "sup"
                        x.sup (i) = mpfr_function_d ('plus', -inf, ...
                                        x.sup (i), pow2 (-1074));
                endswitch
            endif
        elseif (not (ischar (boundary)))
            error ("interval:InvalidOperand", ...
                   ["illegal " key " boundary: must be numeric or string"]);
        elseif (strfind (boundary, "0x"))
            ## Hexadecimal floating point number
            switch key
                case "inf"
                    direction = -inf;
                case "sup"
                    direction = inf;
            endswitch
            
            [x.(key)(i), isdouble] = hex2double (boundary, direction);
            if (not (isdouble))
                isexact = false;
                if (key == "inf")
                    possiblyundefined (i) = true ();
                endif
            else
                possiblyundefined (i) = false ();
            end
        else
            ## parse string
            if (key == "sup" && possiblyundefined (i) && iscell (l))
                inf_boundary = l {i};
                ## infsup ("x", "x") or infsup ("x") is not possibly undefined
                if (strcmp (boundary, inf_boundary))
                    possiblyundefined (i) = false;
                endif
            endif
            
            switch (boundary)
                case {"-inf", "-infinity"}
                    x.(key) (i) = -inf;
                    possiblyundefined (i) = false ();
                case {"inf", "+inf", "infinity", "+infinity"}
                    x.(key) (i) = inf;
                    possiblyundefined (i) = false ();
                case "e"
                    isexact = false ();
                    switch key
                        case "inf"
                            x.inf (i) = 0x56FC2A2 * pow2 (-25) ...
                                      + 0x628AED2 * pow2 (-52);
                            possiblyundefined (i) = true ();
                        case "sup"
                            x.sup (i) = 0x56FC2A2 * pow2 (-25) ...
                                      + 0x628AED4 * pow2 (-52);
                    endswitch
                case "pi"
                    isexact = false ();
                    switch key
                        case "inf"
                            x.inf (i) = 0x6487ED5 * pow2 (-25) ...
                                      + 0x442D180 * pow2 (-55);
                            possiblyundefined (i) = true ();
                        case "sup"
                            x.sup (i) = 0x6487ED5 * pow2 (-25) ...
                                      + 0x442D190 * pow2 (-55);
                    endswitch
                otherwise
                    ## We have to parse a decimal string boundary and round the
                    ## result up or down depending on the boundary
                    ## (inf = down, sup = up).
                    ## str2double will produce the correct answer in 50 % of
                    ## all cases, because it uses rounding mode “to nearest”.
                    ## The input and a double format approximation can be
                    ## compared in a decimal floating point format without
                    ## precision loss.
                    
                    if (strfind (boundary, "?"))
                        ## Special case: uncertain-form
                        [boundary, uncertain] = uncertainsplit (boundary);
                    else
                        uncertain = [];
                    endif
                    
                    if (strfind (boundary, "/"))
                        ## Special case: rational form
                        boundary = strsplit (boundary, "/");
                        if (length (boundary) ~= 2)
                            error ("interval:InvalidOperand", ...
                                   ["illegal " key " boundary: ", ...
                                    "rational form must have single slash"]);
                        endif
                        [decimal, remainder] = decimaldivide (...
                                str2decimal (boundary {1}), ...
                                str2decimal (boundary {2}), 18);
                        if (not (isempty (remainder.m)))
                            ## This will guarantee the enclosure of the exact
                            ## value
                            decimal.m (19, 1) = 1;
                            isexact = false ();
                            if (key == "inf")
                                possiblyundefined (i) = true ();
                            endif
                        endif
                        ## Write result back into boundary for conversion to
                        ## double
                        boundary = ["0.", num2str(decimal.m)', ...
                                    "e", num2str(decimal.e)];
                        if (decimal.s)
                            boundary = ["-", boundary];
                        endif
                    else
                        decimal = str2decimal (boundary);
                    endif
                    
                    ## Parse and add uncertainty
                    if (not (isempty (uncertain)))
                        uncertain = str2decimal (uncertain);
                        if ((key == "inf") == decimal.s)
                            uncertain.s = decimal.s;
                        else
                            uncertain.s = not (decimal.s);
                        endif
                        decimal = decimaladd (decimal, uncertain);
                        ## Write result back into boundary for conversion to
                        ## double
                        boundary = ["0.", num2str(decimal.m)', ...
                                    "e", num2str(decimal.e)];
                        if (decimal.s)
                            boundary = ["-", boundary];
                        endif
                    endif
                    clear uncertain;
                    
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
                                    x.inf (i) = -inf;
                                else # realmax ... inf
                                    x.inf (i) = realmax ();
                                endif
                                possiblyundefined (i) = true ();
                            case "sup"
                                if (decimal.s) # -inf ... -realmax
                                    x.sup (i) = -realmax ();
                                else # realmax ... inf
                                    x.sup (i) = inf;
                                endif
                        endswitch
                        isexact = false ();
                        continue
                    endif
                    
                    ## Compute approximation, this only works between ± realmax
                    binary = str2double (strrep (boundary, ",", "."));
                    
                    ## Check approximation value
                    comparison = decimalcompare (double2decimal (binary), ...
                                                 decimal);
                    if (comparison ~= 0)
                        isexact = false ();
                        if (key == "inf")
                            possiblyundefined (i) = true ();
                        endif
                    else
                        possiblyundefined (i) = false ();
                    endif
                    if (comparison == 0 || ... # approximation is exact
                        (comparison < 0 && key == "inf") || ... # lower bound
                        (comparison > 0 && key == "sup")) # upper bound
                        x.(key) (i) = binary;
                    else
                        ## Approximation is not exact and not rounded as needed
                        ## However, because of faithful rounding the
                        ## approximation is right next to the desired number.
                        switch key
                            case "inf"
                                x.inf (i) = mpfr_function_d ('minus', -inf, ...
                                                binary, pow2 (-1074));
                            case "sup"
                                x.sup (i) = mpfr_function_d ('plus', +inf, ...
                                                binary, pow2 (-1074));
                        endswitch
                    endif
            endswitch
        endif
    endfor
endfor

## NaNs produce empty intervals
nanvalue = isnan (x.inf) | isnan (x.sup);
x.inf (nanvalue) = inf;
x.sup (nanvalue) = -inf;
possiblyundefined (nanvalue) = false;

## normalize boundaries:
## representation of the set containing only zero is always [-0,+0]
x.inf (x.inf == 0) = -0;
x.sup (x.sup == 0) = +0;

## check for illegal boundaries [inf,inf] and [-inf,-inf]
if (any (any (not (isfinite (x.inf (x.inf == x.sup))), 1)))
    error ("interval:InvalidOperand", ...
           "illegal interval boundaries: infimum = supremum = +/- infinity");
endif

## check boundary order
if (any (any (isfinite (x.inf (x.inf > x.sup)))) || ...
    any (any (isfinite (x.sup (x.inf > x.sup)))))
    error ("interval:InvalidOperand", ...
           "illegal interval boundaries: infimum greater than supremum");
endif

## check for possibly wrong boundary order
if (any (any (possiblyundefined)) && any (any (max (-realmax, ...
        mpfr_function_d ('plus',...
                         +inf, ...
                         x.inf (possiblyundefined), ...
                         pow2 (-1074))) == x.sup (possiblyundefined))))
    warning ("interval:PossiblyUndefined", ...
             "infimum may be greater than supremum");
endif

x = class (x, "infsup");
endfunction

%!test "double boundaries";
%!  assert (inf (infsup (0)), 0);
%!  assert (sup (infsup (0)), 0);
%!  assert (inf (infsup (2, 3)), 2);
%!  assert (sup (infsup (2, 3)), 3);
%!  assert (inf (infsup (nan)), +inf);
%!  assert (sup (infsup (nan)), -inf);
%!  assert (inf (infsup (nan, 2)), +inf);
%!  assert (sup (infsup (nan, 2)), -inf);
%!  assert (inf (infsup (3, nan)), +inf);
%!  assert (sup (infsup (3, nan)), -inf);
%!test "double matrix";
%!  assert (inf (infsup (magic (4))), magic (4));
%!  assert (sup (infsup (magic (4))), magic (4));
%!  assert (inf (infsup (magic (3), magic (3) + 1)), magic (3));
%!  assert (sup (infsup (magic (3), magic (3) + 1)), magic (3) + 1);
%!  assert (inf (infsup (nan (3))), +inf (3));
%!  assert (sup (infsup (nan (3))), -inf (3));
%!test "decimal boundaries";
%!  assert (inf (infsup ("0.1")), 0.1 - eps / 16);
%!  assert (sup (infsup ("0.1")), 0.1);
%!  assert (inf (infsup ("0.1e1")), 1);
%!  assert (sup (infsup ("0.1e1")), 1);
%!test "hexadecimal boundaries";
%!  assert (inf (infsup ("0xff")), 255);
%!  assert (sup (infsup ("0xff")), 255);
%!  assert (inf (infsup ("0xff.1")), 255.0625);
%!  assert (sup (infsup ("0xff.1")), 255.0625);
%!  assert (inf (infsup ("0xff.1p-1")), 127.53125);
%!  assert (sup (infsup ("0xff.1p-1")), 127.53125);
%!test "named constants";
%!  assert (inf (infsup ("pi")), pi);
%!  assert (sup (infsup ("pi")), pi + 2 * eps);
%!  assert (inf (infsup ("e")), e);
%!  assert (sup (infsup ("e")), e + eps);
%!test "uncertain form";
%!  assert (inf (infsup ("32?")), 31.5);
%!  assert (sup (infsup ("32?")), 32.5);
%!  assert (inf (infsup ("32?8")), 24);
%!  assert (sup (infsup ("32?8")), 40);
%!  assert (inf (infsup ("32?u")), 32);
%!  assert (sup (infsup ("32?u")), 32.5);
%!  assert (inf (infsup ("32?d")), 31.5);
%!  assert (sup (infsup ("32?d")), 32);
%!  assert (inf (infsup ("32??")), -inf);
%!  assert (sup (infsup ("32??")), +inf);
%!  assert (inf (infsup ("32??d")), -inf);
%!  assert (sup (infsup ("32??d")), 32);
%!  assert (inf (infsup ("32??u")), 32);
%!  assert (sup (infsup ("32??u")), +inf);
%!  assert (inf (infsup ("32?e5")), 3150000);
%!  assert (sup (infsup ("32?e5")), 3250000);
%!test "rational form";
%!  assert (inf (infsup ("6/9")), 2 / 3);
%!  assert (sup (infsup ("6/9")), 2 / 3 + eps / 2);
%!  assert (inf (infsup ("6e1/9")), 20 / 3 - eps * 2);
%!  assert (sup (infsup ("6e1/9")), 20 / 3);
%!  assert (inf (infsup ("6/9e1")), 2 / 30);
%!  assert (sup (infsup ("6/9e1")), 2 / 30 + eps / 16);
%!  assert (inf (infsup ("-6/9")), -(2 / 3 + eps / 2));
%!  assert (sup (infsup ("-6/9")), -2 / 3);
%!  assert (inf (infsup ("6/-9")), -(2 / 3 + eps / 2));
%!  assert (sup (infsup ("6/-9")), -2 / 3);
%!  assert (inf (infsup ("-6/-9")), 2 / 3);
%!  assert (sup (infsup ("-6/-9")), 2 / 3 + eps / 2);
%!  assert (inf (infsup ("6.6/9.9")), 2 / 3);
%!  assert (sup (infsup ("6.6/9.9")), 2 / 3 + eps / 2);
%!test "interval literal";
%!  assert (inf (infsup ("[Entire]")), -inf);
%!  assert (sup (infsup ("[Entire]")), +inf);
%!  assert (inf (infsup ("[Empty]")), +inf);
%!  assert (sup (infsup ("[Empty]")), -inf);
%!  assert (inf (infsup ("[2, 3]")), 2);
%!  assert (sup (infsup ("[2, 3]")), 3);
%!  assert (inf (infsup ("[0.1]")), 0.1 - eps / 16);
%!  assert (sup (infsup ("[0.1]")), 0.1);
%!  assert (inf (infsup ("[0xff, 0xff.1]")), 255);
%!  assert (sup (infsup ("[0xff, 0xff.1]")), 255.0625);
%!  assert (inf (infsup ("[e, pi]")), e);
%!  assert (sup (infsup ("[e, pi]")), pi + 2 * eps);
%!  assert (inf (infsup ("[6/9, 6e1/9]")), 2 / 3);
%!  assert (sup (infsup ("[6/9, 6e1/9]")), 20 / 3);
%!test "decimal vector";
%!  assert (inf (infsup (["0.1"; "0.2"; "0.3"])), [0.1 - eps / 16; 0.2 - eps / 8; 0.3]);
%!  assert (sup (infsup (["0.1"; "0.2"; "0.3"])), [0.1; 0.2; 0.3 + eps / 8]);
%!test "cell array with mixed boundaries";
%!  assert (inf (infsup ({"0.1", 42; "e", "3.2/8"}, {"0xffp2", "42e1"; "pi", 2})), [0.1 - eps / 16, 42; e, 0.4 - eps / 4]);
%!  assert (sup (infsup ({"0.1", 42; "e", "3.2/8"}, {"0xffp2", "42e1"; "pi", 2})), [1020, 420; pi + 2 * eps, 2]);
%!  assert (inf (infsup ({"[2, 3]", "3/4", "[Entire]", "42?3", 1, "0xf"})), [2, 0.75, -inf, 39, 1, 15]);
%!  assert (sup (infsup ({"[2, 3]", "3/4", "[Entire]", "42?3", 1, "0xf"})), [3, 0.75, +inf, 45, 1, 15]);
%!error infsup (3, 2);
%!error infsup ("Ausgeschnitzel");
%!warning infsup ("1.000000000000000000002", "1.000000000000000000001");
