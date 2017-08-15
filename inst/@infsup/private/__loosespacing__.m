## Copyright 2017 Oliver Heimlich
## Copyright 2017 Joel Dahne
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
## @deffun __loosespacing__ ()
##
## Query the current format's spacing configuration.
##
## This function supports a wide range of Octave versions.  The API to query
## the current format settings has undergone several incompatible
## modifications in the 4.0, 4.2 and 4.4 releases.
##
## @example
## @group
## format compact
## __loosespacing__
##   @result{} ans = 0
## @end group
## @group
## format loose
## __loosespacing__
##   @result{} ans =  1
## @end group
## @end example
## @seealso{format}
## @end deffun

## Author: Oliver Heimlich
## Created: 2017-08-15

function result = __loosespacing__ ()

  if (compare_versions (OCTAVE_VERSION (), "4.4.0", ">="))
    ## Starting with changeset f84aa17075d4 it is possible
    ## to query the format function without breaking
    ## current format settings.
    [~, spacing] = format ();
  elseif (exist ("__compactformat__", "builtin"))
    ## An internal function has been introduced by Octave 4.0.0.
    result = not (__compactformat__ ());
    return
  elseif (compare_versions (OCTAVE_VERSION (), "4.2.0", ">="))
    ## Abovementioned changeset has removed the internal function.
    ## Development versions of Octave (4.3.0+) should already have
    ## support for the 2-output format function.
    ## TODO: This case can be removed after the 4.4.0 release.
    [~, spacing] = format ();
  else
    ## In older versions, we use this kludgy workaround to
    ## detect the current settings.
    ## Note: The deprecated root property "FormatSpacing",
    ## which has been removed in Octave 4.2.0, always returns "loose"
    ## in Octave < 4.0.0 and is of no use.
    compact_spacing = isempty (strfind (disp (zeros ([1 2 2])), "\n\n"));
    result = not (compact_spacing);
    return
  endif

  result = strcmp ("loose", spacing);

endfunction
