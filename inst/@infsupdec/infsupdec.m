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
## Non-standard behavior: This class constructor is not described by IEEE 1788.
## 
## @example
## @group
## v = infsup ()
##   @result{} [Empty]
## w = infsup (1)
##   @result{} [1]
## x = infsup (2, 3)
##   @result{} [2, 3]
## y = infsup ("0.1")
##   @result{} [.09999999999999999, .10000000000000001]
## z = infsup ("0.1", "0.2")
##   @result{} [.09999999999999999, .20000000000000002]
## @end group
## @end example
## @seealso{numstointerval, texttointerval, exacttointerval}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-12

function [x, isexact] = infsupdec (p1, p2, p3)

## The decorated version must return NaI instead of an error if interval
## construction failed
try
    switch nargin
        case 0
            [bare, isexact] = infsup ();
            dec = "trv";
        case 1
            if (isa (p1, "infsup"))
                bare = p1;
                isexact = true ();
                dec = "trv";
            else
                [bare, isexact] = infsup ();
                dec = p1;
            endif
        case 2
            if (isa (p1, "infsup"))
                bare = p1;
                isexact = true ();
            else
                [bare, isexact] = infsup (p1);
            endif
            dec = p2;
        case 3
            [bare, isexact] = infsup (p1, p2);
            dec = p3;
    endswitch
    dec = lower (dec);
    if (isempty (bare) && dec ~= "trv")
        error ("illegal decoration for empty interval")
    endif
    if (not (isfinite (inf (bare)) && isfinite (sup (bare))) && dec == "com")
        error ("illegal decoration for unbound interval")
    endif
    if (dec ~= "com" && dec ~= "dac" && dec ~= "def" && dec ~= "trv")
        error ("illegal decoration");
    endif
catch
    ## NaI representation is unique.
    bare = empty ();
    dec = "ill";
    isexact = false ();
end_try_catch

x.dec = dec;

x = class (x, "infsupdec", bare);

endfunction
