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
## @documentencoding UTF-8
## @deftypefn {Function File} {[@var{X}, @var{ISEXACT}] =} infsupdec ()
## @deftypefnx {Function File} {[@var{X}, @var{ISEXACT}] =} infsupdec (@var{M})
## @deftypefnx {Function File} {[@var{X}, @var{ISEXACT}] =} infsupdec (@var{M}, @var{D})
## @deftypefnx {Function File} {[@var{X}, @var{ISEXACT}] =} infsupdec (@var{S})
## @deftypefnx {Function File} {[@var{X}, @var{ISEXACT}] =} infsupdec (@var{L}, @var{U})
## @deftypefnx {Function File} {[@var{X}, @var{ISEXACT}] =} infsupdec (@var{L}, @var{U}, @var{D})
## @deftypefnx {Function File} {[@var{X}, @var{ISEXACT}] =} infsupdec (@var{I}, @var{D})
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
## equivalent to @code{infsupdec ("S1", "S2")} and, if [S1, S2]_D is a valid
## interval literal,
## @code{infsupdec ("[S1, S2]_D")} is equivalent to
## @code{infsupdec ("S1", "S2", "D")}.  The syntax 
## @code{infsupdec (@var{I}, @var{D})} overrides an interval @var{I}'s
## decoration with a new decoration @var{D}.  A second, logical output
## @var{ISEXACT} indicates if @var{X}'s boundaries both have been converted
## without precision loss and without changes to the optional, desired
## decoration.
##
## If construction fails, the special value NaI, “not an interval,” will be
## returned and a warning message will be raised.  NaI is equivalent to
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
## The decoration @var{D} must be any of @code{com}, @code{dac}, @code{def},
## @code{trv}, or @code{ill}.  Illegal decorations within interval literals
## will produce NaIs, whereas illegal decorations provided as an additional
## function parameter will be automatically adjusted.
##
## For the creation of interval matrices, arguments may be provided as (1) cell 
## arrays with arbitrary/mixed types, (2) numeric matrices, or (3) string
## column vectors.  Scalar values do broadcast.
##
## Non-standard behavior: This class constructor is not described by IEEE 1788,
## however it implements the IEEE 1788 functions setDec, numsToInterval, and
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
##   @result{} [0.09999999999999999, 0.1000000000000001]_com
## z = infsupdec ("0.1", "0.2")
##   @result{} [0.09999999999999999, 0.2000000000000001]_com
## @end group
## @end example
## @seealso{exacttointerval, hull, midrad, @@infsup/newdec}
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
    
    ## The setDec function, as described by IEEE 1788, may fix decorations
    fix_illegal_decorations = true ();
    
    if (nargin >= 1 && ...
        iscellstr (varargin {end}) && ...
        not (isempty (varargin {end})) && ...
        any (strcmpi (varargin {end} {1}, ...
                      {"com", "dac", "def", "trv", "ill"})))
        ## The decoration information has been passed as the last parameter
        decstr = varargin {end};
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
                print_usage ();
                return
        endswitch
    elseif (nargin == 1 && iscell (varargin {1}))
        ## Parse possibly decorated interval literals
        chars = cellfun ("ischar", varargin {1});
        varargin {1} (chars) = cellfun (@strsplit, ...
                                        varargin {1} (chars), ...
                                        {"_"}, ...
                                        "UniformOutput", false);
        if (any (any (cellfun ("size", varargin {1} (chars), 2) > 2)))
            ## More than 2 underscores in any literal
            error ("interval:InvalidOperand", ...
                   "illegal decorated interval literal")
        endif
        ## Extract decoration
        decstr = cell (size (varargin {1}));
        hasdec = false (size (varargin {1}));
        hasdec (chars) = cellfun ("size", varargin {1} (chars), 2) == 2;
        decstr (hasdec) = cellfun (@(x) x {2}, varargin {1} (hasdec), ...
                                   "UniformOutput", false);
        varargin {1} (chars) = cellfun (@(x) x {1}, varargin {1} (chars), ...
                                        "UniformOutput", false);
        
        ## Note: The representation of NaI, will trigger an error in the infsup
        ## constructor
        [bare, isexact, overflow] = infsup (varargin {1});
        
        ## Silently fix decorated interval literals when overflow occurred
        decstr (overflow & strcmpi (decstr, "com")) = "dac";
        
        ## Interval literals must not carry illegal decorations
        fix_illegal_decorations = false ();
    else
        ## Undecorated interval boundaries
        decstr = {""};
        switch nargin
            case 0
                [bare, isexact] = infsup ();
            case 1
                if (isa (varargin {1}, "infsupdec"))
                    x = varargin {1};
                    isexact = true ();
                    return
                elseif (isa (varargin {1}, "infsup"))
                    bare = varargin {1};
                    isexact = true ();
                    if (not (all (all (isempty (bare)))))
                        warning ("interval:ImplicitPromote", ...
                                ["Implicitly decorated bare interval; ", ...
                                 "resulting decoration may be wrong"]);
                    endif
                else
                    [bare, isexact] = infsup (varargin {1});
                endif
            case 2
                [bare, isexact] = infsup (varargin {1}, varargin {2});
            otherwise
                print_usage ();
        endswitch
    endif
    
    assert (isa (bare, "infsup"));
    assert (iscell (decstr));

    ## Convert decoration strings into decoration matrix.
    ## Initialize the matrix with the ill decoration, which is not allowed to
    ## be used explicitly as a parameter to this function.
    dec = _ill () (ones (size (decstr)));
    
    ## Missing decorations will later be assigned their final value
    missingdecoration_value = uint8 (1); # magic value, not used otherwise
    dec (cellfun ("isempty", decstr)) = missingdecoration_value;
    
    dec (strcmpi (decstr, "com")) = _com ();
    dec (strcmpi (decstr, "dac")) = _dac ();
    dec (strcmpi (decstr, "def")) = _def ();
    dec (strcmpi (decstr, "trv")) = _trv ();

    if (any (any (dec == _ill ())))
        error ("interval:InvalidOperand", "illegal decoration");
    endif

    ## Broadcast decoration
    if (isscalar (dec) && not (isscalar (bare)))
        dec = dec (ones (size (bare)));
    elseif (not (all (size (dec) == size (bare))))
        error ("interval:InvalidOperand", "decoration size mismatch")
    endif

    ## Add missing decoration
    missingdecoration = dec == missingdecoration_value;
    dec (missingdecoration) = _dac ();
    dec (missingdecoration & isempty (bare)) = _trv ();
    dec (missingdecoration & iscommoninterval (bare)) = _com ();
    
    ## Check decoration
    empty_not_trv = isempty (bare) & dec ~= _trv ();
    if (any (any (empty_not_trv)))
        if (not (fix_illegal_decorations))
            error ("interval:InvalidOperand", ...
                   "illegal decorated interval literal")
        endif
        isexact = false ();
        dec (empty_not_trv) = _trv ();
    endif
    uncommon_com = not (iscommoninterval (bare)) & dec == _com ();
    if (any (any (uncommon_com)))
        if (not (fix_illegal_decorations))
            error ("interval:InvalidOperand", ...
                   "illegal decorated interval literal")
        endif
        isexact = false ();
        dec (uncommon_com) = _dac ();
    endif
catch
    switch lasterror.identifier
        case "Octave:invalid-fun-call"
            print_usage ();
        case "interval:NaI"
            ## The bare inverval:NaI error can only occur, if the interval
            ## literal [NaI] is observed. In that particular case, we must not
            ## issue a warning.
        case {"interval:PossiblyUndefined", ...
              "interval:ImplicitPromote"}
            ## The user has set these warnings to error, which we must respect
            rethrow (lasterror)
        otherwise
            warning ("interval:NaI", lasterror.message);
    endswitch
    ## NaI representation is unique.
    bare = infsup ();
    dec = _ill ();
    isexact = false ();
end_try_catch

x.dec = dec;

x = class (x, "infsupdec", bare);

## Enable all mixed mode functions to use decorated variants with implicit
## conversion from bare to decorated intervals.
##
## There is bug #42735 in GNU Octave core, which makes this a little
## complicated: When [infsup] [operator] [infsupdec] syntax is used, the
## decoration from the second argument would be lost, because the bare
## implementation for the operator is evaluated. However, sufficient runtime
## checks have been placed in the overloaded class operator implementations of
## the infsup class as a workaround.
##
## The workaround is necessary, because otherwise this could lead to wrong
## results, which is catastrophic for a verified computation package.
superiorto ("infsup");

endfunction

%!# [NaI]s
%!  assert (isnai (infsupdec ("[nai]"))); # quiet [NaI]
%!warning assert (isnai (infsupdec (3, 2)));
%!warning assert (isnai (infsupdec ("Flugeldufel")));
%!warning assert (isnai (infsupdec ("[1, Inf]_com")));
%!warning assert (isnai (infsupdec ("[Empty]_def")));
%!test "decoration adjustments, setDec function";
%!  assert (inf (infsupdec (42, inf, "com")), 42);
%!  assert (sup (infsupdec (42, inf, "com")), inf);
%!  assert (strcmp (decorationpart (infsupdec (42, inf, "com")), "dac"));
%!  assert (inf (infsupdec (-inf, inf, "com")), -inf);
%!  assert (sup (infsupdec (-inf, inf, "com")), inf);
%!  assert (strcmp (decorationpart (infsupdec (-inf, inf, "com")), "dac"));
%!  assert (inf (infsupdec (inf, -inf, "def")), inf);
%!  assert (sup (infsupdec (inf, -inf, "def")), -inf);
%!  assert (strcmp (decorationpart (infsupdec (inf, -inf, "def")), "trv"));
%!test "overflow";
%!  assert (inf (infsupdec ("[1, 1e999]_com")), 1);
%!  assert (sup (infsupdec ("[1, 1e999]_com")), inf);
%!  assert (strcmp (decorationpart (infsupdec ("[1, 1e999]_com")), "dac"));
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
