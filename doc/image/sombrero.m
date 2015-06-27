## This is part of the GNU Octave Interval Package Manual.
## Copyright (C) 2015 Oliver Heimlich.
## See the file manual.texinfo for copying conditions.

clf
hold on

light = [253 246 227] ./ 255;
blue = [38 139 210] ./ 255;
green = [133 153 0] ./ 255;
yellow = [181 137 0] ./ 255;
orange = [203 75 22] ./ 255;
red = [220 50 47] ./ 255;

range = linspace (-8, 8, 13);
[x, y] = meshgrid (range, range);
x = midrad (vec (x), (range (2) - range (1)) ./ 2);
y = midrad (vec (y), (range (2) - range (1)) ./ 2);

z = sin (hypot (x, y)) ./ hypot (x, y);

flat = sup (z) < .3;
low = ismember (sup (z), infsup (0.3, 1));
mid = ismember (sup (z), infsup (1, 1.2));
high = ismember (sup (z), infsup (1.2, 3));
unbound = sup (z) > 2;

## Infinite patches can't be displayed
z = intersect (z, infsupdec (-10, 10));

plot3 (x (flat), y (flat), z (flat), blue, light)
plot3 (x (low), y (low), z (low), green, light)
plot3 (x (mid), y (mid), z (mid), yellow, light)
plot3 (x (high), y (high), z (high), orange, light)
plot3 (x (unbound), y (unbound), z (unbound), red, light)

view ([-37.5, 30])
zlim ([-.5, 2])
box off
set (gca, "xgrid", "on", "ygrid", "on", "zgrid", "on")
