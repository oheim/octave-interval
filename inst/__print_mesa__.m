## Copyright 2015-2016 Oliver Heimlich
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
## @defun __print_mesa__ (@var{H}, @var{FILENAME})
## Render the OpenGL scene into an image file (internal function).
##
## This function can be used as an replacement of the @code{print} function,
## but will generously modify the figure.  The figure should be closed after
## calling this function.
##
## Kludge alert: The export of patch objects within figures is somewhat broken,
## especially for 3D plots.  This function renders the OpenGL scene without
## using @command{gl2ps}, which basically produces a screen shot of the figure.
##
## This function requires an Octave version of at least 4.0.0.
## @end defun

## Author: Oliver Heimlich
## Keywords: kludge
## Created: 2015-05-20

function __print_mesa__ (h, filename)

if (not (exist ('__osmesa_print__')))
    warning (['__print_mesa__ requires Octave >= 4.0.0, ' ...
              'falling back to builtin print function'])
    builtin ('print', h, filename);
    return
endif

## hide figure (for __osmesa_print__ to work)
set (h, 'visible', 'off');

screensize = get (h, 'position') (3 : 4);
## print exports raster graphics with 150 dpi
exportsize = 150 .* get (h, 'paperposition') (3 : 4);
## __osmesa_print__ seems to apply no anti-aliasing.
## Thus, we apply a FXAA filter ourself. Since this would make the image pretty
## small, we have to increase the figure size.
rendersize = 2 .* exportsize;
set (h, 'position', [0, 0, rendersize]);
resizefactor = mean (rendersize ./ screensize);

## The greater figure size together with the FXAA filter effectively increase
## the image's resolution. In order to get readable text and visible lines,
## we must also increase font sizes, line widths and dot sizes.
##
## FIXME The following code might not increase the size of all relevant objects
## in the figure, but works quite well for everything that can be encountered
## in the interval package.
a = allchild (h);
a = a (strcmp (get (a, 'type'), 'axes')); # axis and legend
for obj = a'
    set (obj, 'fontsize', resizefactor * get (obj, 'fontsize'), ...
              'linewidth', resizefactor * get (obj, 'linewidth'));
endfor
l = allchild (a);
if (iscell (l))
    l = vertcat (l {:});
endif
t = l (strcmp (get (l, 'type'), 'text'));
for obj = t'
    set (obj, 'fontsize', resizefactor * get (obj, 'fontsize'));
endfor
l = l (strcmp (get (l, 'type'), 'line') | strcmp (get (l, 'type'), 'patch'));
for obj = l'
    set (obj, 'linewidth', resizefactor * get (obj, 'linewidth'));
endfor
g = allchild (a);
if (iscell (g))
    g = vercat (g {:});
endif
g = g (strcmp (get (g, 'type'), 'hggroup')); # markers from scatter plots
p = allchild (g);
if (iscell (p))
    p = vertcat (p {:});
endif
p = p (strcmp (get (p, 'type'), 'patch'));
for obj = p'
    set (obj, 'markersize', resizefactor * get (obj, 'markersize'));
endfor

## Capture OpenGL scene (without gl2ps)
warning ('off', 'Octave:GraphicsMagic-Quantum-Depth', 'local');
img = __osmesa_print__ (h);

## Apply FXAA
img = uint16 (img);
img = img (1:2:end, :, :) + img (2:2:end, :, :);
img = img (:, 1:2:end, :) + img (:, 2:2:end, :);
img = uint8 (img / 4);

## Save to file
imwrite (img, filename);

endfunction

%!# This function cannot be tested -- it would also fail on Octave < 3.8.2
%!assert (1);
