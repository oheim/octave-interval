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
## @documentencoding utf-8
## @deftypefn {Function File} {[@var{X}, @var{ISEXACT}] =} infsupdec ()
## @deftypefnx {Function File} {[@var{X}, @var{ISEXACT}] =} infsupdec (@var{M})
## @deftypefnx {Function File} {[@var{X}, @var{ISEXACT}] =} infsupdec (@var{M}, @var{D})
## @deftypefnx {Function File} {[@var{X}, @var{ISEXACT}] =} infsupdec (@var{S})
## @deftypefnx {Function File} {[@var{X}, @var{ISEXACT}] =} infsupdec (@var{L}, @var{U})
## @deftypefnx {Function File} {[@var{X}, @var{ISEXACT}] =} infsupdec (@var{L}, @var{U}, @var{D})
## 
## Create a decorated interval from boundaries.  Convert boundaries to double
## precision.
##
## The syntax without parameters creates an (exact) empty interval.  The syntax
## with a single parameter @code{infsupdec (@var{M})} equals
## @code{infsupdec (@var{M}, @var{M})}.  The syntax
## @code{infsupdec (@var{M}, @var{D})} equals
## @code{infsupdec (@var{M}, @var{M}, @var{D})}.  The syntax
## @code{infsupdec (@var{S})} parses a possibly decorated interval literal in
## inf-sup form or as a special value, where @code{infsupdec ("[S1, S2]")} is
## equivalent to @code{infsupdec ("S1", "S2")} and
## @code{infsupdec ("[S1, S2]_D")} is equivalent to
## @code{infsupdec ("S1", "S2", "D")}.  A second, logical output @var{ISEXACT}
## indicates if @var{X}'s boundaries both have been converted without precision
## loss.
##
## If construction fails, the special value [NaI], “not an interval,” will be
## returned and a warning message will be raised.  [NaI] is equivalent to
## [Empty] together with an ill-formed decoration.
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
## however it implements the IEEE 1788 functions newDec, numsToInterval, and
## textToInterval.
## 
## @example
## @group
## v = infsupdec ()
##   @result{} [Empty]_trv
## w = infsupdec (1)
##   @result{} [1]_com
## x = infsupdec (2, 3)
##   @result{} [2, 3]_com
## y = infsupdec ("0.1")
##   @result{} [.09999999999999999, .10000000000000001]_com
## z = infsupdec ("0.1", "0.2")
##   @result{} [.09999999999999999, .20000000000000002]_com
## @end group
## @end example
## @seealso{exacttointerval}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-12

function [x, isexact] = infsupdec (varargin)

## The decorated version must return NaI instead of an error if interval
## construction failed, so we use a try & catch block.
try
    if (nargin >= 1 && ischar (varargin {end}))
        varargin {end} = cellstr (varargin {end});
    endif
        
    if (nargin >= 1 && ...
        iscellstr (varargin {end}) && ...
        not (isempty (varargin {end})) && ...
        max (strcmpi (varargin {end} {1}, ...
                      {"com", "dac", "def", "trv", "ill"})))
        ## The decoration information has been passed as the last parameter
        dec = varargin {end};
        switch nargin
            case 1
                [bare, isexact] = infsup ();
            case 2
                if (isa (varargin {1}, "infsup"))
                    bare = infsup (inf (varargin {1}), sup (varargin {1}));
                    isexact = true ();
                else
                    [bare, isexact] = infsup (varargin {1});
                endif
            case 3
                [bare, isexact] = infsup (varargin {1}, varargin {2});
            otherwise
                error ("too many arguments")
        endswitch
    elseif (nargin == 1 && iscell (varargin {1}))
        ## Parse possibly decorated interval literals
        dec = cell (size (varargin {1}));
        dec (:) = {""};
        for i = 1 : numel (varargin {1})
            if (ischar (varargin {1} {i}))
                literal = strsplit (varargin {1} {i}, "_");
                if (length (literal) == 2) # decorated interval literal
                    varargin {1} {i} = literal {1};
                    dec {i} = literal {2};
                elseif (length (literal) > 2)
                       error ("illegal decorated interval literal")
                endif
            endif
        endfor
        
        ## Note: The representation of NaI, will trigger an error in the infsup
        ## constructor
        [bare, isexact] = infsup (varargin {1});
    else
        ## Undecorated interval boundaries
        dec = {""};
        switch nargin
            case 0
                [bare, isexact] = infsup ();
            case 1
                if (isa (varargin {1}, "infsup"))
                    bare = infsup (inf (varargin {1}), sup (varargin {1}));
                    isexact = true ();
                else
                    [bare, isexact] = infsup (varargin {1});
                endif
            case 2
                [bare, isexact] = infsup (varargin {1}, varargin {2});
            otherwise
                error ("too many arguments")
        endswitch
    endif
    
    assert (isa (bare, "infsup"));
    assert (iscellstr (dec));

    dec = lower (dec);
    
    ## Broadcast decoration
    if (isscalar (dec) && not (isscalar (bare)))
        decvalue = dec {1};
        dec = cell (size (bare));
        dec (:) = {decvalue};
    endif
    
    if (not (min (size (dec) == size (bare))))
        error ("decoration size mismatch")
    endif
    
    ## Add missing decoration
    missingdecoration = strcmp (dec, "");
    dec (missingdecoration) = "dac";
    dec (missingdecoration & isempty (bare)) = "trv";
    dec (missingdecoration & iscommoninterval (bare)) = "com";
    
    ## Check decoration
    if (max (max (isempty (bare) & not (strcmp (dec, "trv")))))
        error ("illegal decoration for empty interval")
    endif
    if (max (max (not (iscommoninterval (bare)) & strcmp (dec, "com"))))
        error ("illegal decoration for uncommon interval")
    endif
    if (not (min (min ( ...
            strcmp (dec, "com") | ...
            strcmp (dec, "dac") | ...
            strcmp (dec, "def") | ...
            strcmp (dec, "trv")))))
        error ("illegal decoration");
    endif
catch
    warning ("interval:infsupdec", lasterror.message);
    ## NaI representation is unique.
    bare = infsup ();
    dec = {"ill"};
    isexact = false ();
end_try_catch

x.dec = dec;

x = class (x, "infsupdec", bare);

## Enable all mixed mode functions to use decorated variants
## FIXME This does not work for operators atm,
## see http://savannah.gnu.org/bugs/?42735
superiorto ("infsup");

endfunction

%!# [NaI]s
%!warning assert (isnai (infsupdec (3, 2)));
%!warning assert (isnai (infsupdec ("Flugeldufel")));
%!warning assert (isnai (infsupdec (-inf, inf, "com")));
%!warning assert (isnai (infsupdec (inf, -inf, "def")));
%!test "decorated interval literal";
%!  assert (inf (infsupdec ("[2, 3]_def")), 2);
%!  assert (sup (infsupdec ("[2, 3]_def")), 3);
%!  assert (strcmp (decorationpart (infsupdec ("[2, 3]_def")), "def"));
%!  assert (inf (infsupdec ("trv")), inf);
%!  assert (sup (infsupdec ("trv")), -inf);
%!  assert (strcmp (decorationpart (infsupdec ("trv")), "trv"));
%!test "automatic decoration";
%!  assert (inf (infsupdec ("[2, 3]")), 2);
%!  assert (sup (infsupdec ("[2, 3]")), 3);
%!  assert (strcmp (decorationpart (infsupdec ("[2, 3]")), "com"));
%!  assert (inf (infsupdec ("[Empty]")), inf);
%!  assert (sup (infsupdec ("[Empty]")), -inf);
%!  assert (strcmp (decorationpart (infsupdec ("[Empty]")), "trv"));
%!  assert (inf (infsupdec ("[Entire]")), -inf);
%!  assert (sup (infsupdec ("[Entire]")), inf);
%!  assert (strcmp (decorationpart (infsupdec ("[Entire]")), "dac"));
%!  assert (inf (infsupdec ("")), -inf);
%!  assert (sup (infsupdec ("")), +inf);
%!  assert (strcmp (decorationpart (infsupdec ("")), "dac"));
%!test "separate decoration information";
%!  assert (inf (infsupdec ("[2, 3]", "def")), 2);
%!  assert (sup (infsupdec ("[2, 3]", "def")), 3);
%!  assert (strcmp (decorationpart (infsupdec ("[2, 3]", "def")), "def"));
%!test "cell array with decorated intervals";
%!  assert (inf (infsupdec ({"[2, 3]_def", "[4, 5]_dac"})), [2, 4]);
%!  assert (sup (infsupdec ({"[2, 3]_def", "[4, 5]_dac"})), [3, 5]);
%!  assert (all (strcmp (decorationpart (infsupdec ({"[2, 3]_def", "[4, 5]_dac"})), {"def", "dac"})));
%!test "cell array with separate decoration cell array";
%!  assert (inf (infsupdec ({"[2, 3]", "[4, 5]"}, {"def", "dac"})), [2, 4]);
%!  assert (sup (infsupdec ({"[2, 3]", "[4, 5]"}, {"def", "dac"})), [3, 5]);
%!  assert (all (strcmp (decorationpart (infsupdec ({"[2, 3]", "[4, 5]"}, {"def", "dac"})), {"def", "dac"})));
%!test "cell array with separate decoration vector";
%!  assert (inf (infsupdec ({"[2, 3]"; "[4, 5]"}, ["def"; "dac"])), [2; 4]);
%!  assert (sup (infsupdec ({"[2, 3]"; "[4, 5]"}, ["def"; "dac"])), [3; 5]);
%!  assert (all (strcmp (decorationpart (infsupdec ({"[2, 3]"; "[4, 5]"}, ["def"; "dac"])), {"def"; "dac"})));
%!test "cell array with broadcasting decoration";
%!  assert (inf (infsupdec ({"[2, 3]", "[4, 5]"}, "def")), [2, 4]);
%!  assert (sup (infsupdec ({"[2, 3]", "[4, 5]"}, "def")), [3, 5]);
%!  assert (all (strcmp (decorationpart (infsupdec ({"[2, 3]", "[4, 5]"}, "def")), {"def", "def"})));
%!test "separate boundaries with decoration";
%!  assert (inf (infsupdec (2, 3, "def")), 2);
%!  assert (sup (infsupdec (2, 3, "def")), 3);
%!  assert (strcmp (decorationpart (infsupdec (2, 3, "def")), "def"));
%!test "matrix boundaries with decoration";
%!  assert (inf (infsupdec ([3, 16], {"def", "trv"})), [3, 16]);
%!  assert (sup (infsupdec ([3, 16], {"def", "trv"})), [3, 16]);
%!  assert (all ( strcmp (decorationpart (infsupdec ([3, 16], {"def", "trv"})), {"def", "trv"})));
%!test "separate matrix boundaries with broadcasting decoration";
%!  assert (inf (infsupdec (magic (3), magic (3) + 1, "def")), magic (3));
%!  assert (sup (infsupdec (magic (3), magic (3) + 1, "def")), magic (3) + 1);
%!  assert (all ( all (strcmp (decorationpart (infsupdec (magic (3), magic (3) + 1, "def")), {"def", "def", "def"; "def", "def", "def"; "def", "def", "def"}))));
