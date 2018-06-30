## Copyright 2018 Oliver Heimlich
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
## @deftypefun {[@var{template}, @var{literals}] =} printf_prepare (@var{template}, @var{X})
##
## Convert interval @var{X} under the control of a template string
## @var{template} to an interval literal.  The format @var{TEMPLATE} is
## modified to be used by Octave's formatted output functions @command{printf},
## @command{fprintf}, and @command{sprintf}.  That is, syntax for interval
## literals is replaced by @code{%s}.
##
## @seealso{intervaltotext}
## @end deftypefun

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2018-06-30

function [template, literals] = printf_prepare (template, x)

  if (nargin ~= 2)
    print_usage ();
    return
  endif

  if (not (ischar (template)))
    error ("format TEMPLATE must be a string");
    return
  endif

  if (not (isa (x, "infsup")))
    error ("X must be an interval")
    return
  endif

  ## Split templates to process each template individually
  template = strsplit (template, "%", "collapsedelimiters", false);

  ## Undo splitting of escaped '%'
  n = 2;
  while (n < numel (template))
    if (isempty (template{n}))
      template{n - 1} = cstrcat (template{n - 1}, "%%", template{n + 1});
      template([n, (n + 1)]) = [];
    else
      n ++;
    endif
  endwhile

  ## Format interval literals and replace corresponding templates by %s
  template_parts = numel (template) - 1;
  literals = cell (size (x));
  for n = 1 : template_parts
    part_idx = colon (n, template_parts, numel (x));
    [literals_part, ~, template_part_suffix] = intervaltotext (
        subsref (x, substruct ("()", {part_idx})),
        template{n + 1});
    literals(part_idx) = literals_part;
    template{n + 1} = cstrcat ("s", template_part_suffix);
  endfor
  template = strjoin (template, "%");

endfunction
