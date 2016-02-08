## Copyright 2014-2016 Oliver Heimlich
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
## @deftypefun {[@var{BOUNDARY}, @var{UNCERTAIN}] =} uncertainsplit (@var{BOUNDARY})
## 
## The the decimal number itself and the decimal number that represents the
## uncertainty for the number.
## @end deftypefun

## Author: Oliver Heimlich
## Created: 2014-10-21

function [boundary, uncertain] = uncertainsplit (boundary)

uncertainseparator = find (boundary == "?", 1);
assert (not (isempty (uncertainseparator)));
exponentseparator = find (lower (boundary) == "e", 1);
if (isempty (exponentseparator))
    exponentfield = "";
    if (uncertainseparator == length (boundary))
        ulpcount = "";
    else
        ulpcount = boundary ((uncertainseparator + 1) : end);
    endif
else
    exponentfield = boundary (exponentseparator : end);
    ulpcount = boundary ((uncertainseparator + 1) : (exponentseparator - 1));
endif
## Strip uncertain information from the boundary
literal = boundary (1 : (uncertainseparator - 1));
boundary = strcat (literal, exponentfield);

## Make a decimal number that represents the uncertainty
decimalseparator = find ((literal == ".") + (literal == ","), 1);
if (isempty (ulpcount))
    ## Half-ULP
    if (isempty (decimalseparator))
        uncertain = "0.5";
    else
        uncertain = strcat (regexprep (literal, "[0-9]", "0"), "5");
    endif
else
    uncertain = ulpcount;
    if (not (isempty (decimalseparator)))
        ## Insert decimal point in ulp number
        placesafterpoint = length (literal) - decimalseparator;
        if (length (uncertain) < length (literal))
            uncertain = prepad (uncertain, length (literal), "0", 2);
        endif
        uncertain = strcat (uncertain (1 : ...
            (length (uncertain) - placesafterpoint)), ...
            ".", ...
            uncertain ((length (uncertain) - placesafterpoint + 1) ...
            : length (uncertain)));
    endif
endif
uncertain = strcat (uncertain, exponentfield);

endfunction