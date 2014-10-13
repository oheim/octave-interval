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
## @deftypefn {Interval Constructor} {[@var{X}, @var{ISEXACT}] =} infsupdec ()
## @deftypefnx {Interval Constructor} {[@var{X}, @var{ISEXACT}] =} infsupdec (@var{M})
## @deftypefnx {Interval Constructor} {[@var{X}, @var{ISEXACT}] =} infsupdec (@var{M}, @var{D})
## @deftypefnx {Interval Constructor} {[@var{X}, @var{ISEXACT}] =} infsupdec (@var{S})
## @deftypefnx {Interval Constructor} {[@var{X}, @var{ISEXACT}] =} infsupdec (@var{L}, @var{U})
## @deftypefnx {Interval Constructor} {[@var{X}, @var{ISEXACT}] =} infsupdec (@var{L}, @var{U}, @var{D})
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
## v = infsupdec ()
##   @result{} [Empty]_trv
## w = infsupdec (1)
##   @result{} [1]_com
## x = infsup (2, 3)
##   @result{} [2, 3]_com
## y = infsup ("0.1")
##   @result{} [.09999999999999999, .10000000000000001]_com
## z = infsup ("0.1", "0.2")
##   @result{} [.09999999999999999, .20000000000000002]_com
## @end group
## @end example
## @seealso{numstointerval, texttointerval, exacttointerval}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-12

function [x, isexact] = infsupdec (varargin)

## The decorated version must return NaI instead of an error if interval
## construction failed, so we use a try & catch block.
try
    if (nargin >= 1 && max(strcmpi (varargin{end}, {"com","dac","def","trv"})))
        ## The decoration has been passed as the last parameter
        dec = varargin{end};
        switch nargin
            case 1
                [bare, isexact] = infsup ();
            case 2
                [bare, isexact] = infsup (varargin{1});
            case 3
                [bare, isexact] = infsup (varargin{1}, varargin{2});
            otherwise
                error ("too many arguments")
        endswitch
    elseif (nargin == 1 && ischar (varargin{1}))
        ## interval literal or single decimal number
        literal = strsplit (varargin{1}, "_");
        if (isempty (literal))
            [bare, isexact] = infsup ("");
        else
            ## If literal{1} is the representation of NaI, the infsup
            ## constructor will trigger an error.
            [bare, isexact] = infsup (literal{1});
            if (length (literal) == 2) # decorated interval literal
                dec = literal{2};
            elseif (length (literal) > 2)
                error ("illegal decorated interval literal")
            endif
        endif
    else
        ## Undecorated interval boundaries
        switch nargin
            case 0
                [bare, isexact] = infsup ();
            case 1
                [bare, isexact] = infsup (varargin{1});
            case 2
                [bare, isexact] = infsup (varargin{1}, varargin{2});
            otherwise
                error ("too many arguments")
        endswitch
    endif
    
    assert (isa (bare, "infsup"));
    
    if (not (exist ("dec", "var")))
        ## Add missing decoration
        if (isempty (bare))
            dec = "trv";
        elseif (not (isfinite (inf (bare)) && isfinite (sup (bare))))
            dec = "dac";
        else # bounded & non-empty
            dec = "com";
        endif
    endif
    dec = lower (dec);
    
    ## Check decoration
    if (isempty (bare) && dec ~= "trv")
        error ("illegal decoration for empty interval")
    endif
    if (not (isfinite (inf (bare)) && isfinite (sup (bare))) && dec == "com")
        error ("illegal decoration for unbound interval")
    endif
    if (not (max(strcmp (dec, {"com","dac","def","trv"}))))
        error ("illegal decoration");
    endif
catch
    warning (lasterror.message)
    ## NaI representation is unique.
    bare = infsup ();
    dec = "ill";
    isexact = false ();
end_try_catch

x.dec = dec;

x = class (x, "infsupdec", bare);

endfunction
