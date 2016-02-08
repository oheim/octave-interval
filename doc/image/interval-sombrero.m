## This is part of the GNU Octave Interval Package Manual.
## Copyright 2015-2016 Oliver Heimlich.
## See the file manual.texinfo for copying conditions.

clf
hold on

light = [253 246 227] ./ 255;
blue = [38 139 210] ./ 255;
green = [133 153 0] ./ 255;
yellow = [181 137 0] ./ 255;
orange = [203 75 22] ./ 255;
red = [220 50 47] ./ 255;

range = mince (infsupdec (-8, 8), 13);
[x, y] = meshgrid (range);

h = hypot (x, y);
z = sin (h) ./ h;
## The sombrero function would suffer from the dependency problem
## Thus, we compute an interval version of the function, which works around it.
select = mag (h) < pi;
z (select) = hull (sin (mag (h (select))) ./ mag (h (select)), ...
                   sin (mig (h (select))) ./ mig (h (select)));
z (mig (h) == 0) = union (z (mig (h) == 0), 1);

flat = sup (z) < .3;
low = ismember (sup (z), infsup (0.3, 0.8));
mid = ismember (sup (z), infsup (0.8, 0.9));
high = ismember (sup (z), infsup (0.9, 1));
top = sup (z) >= 1;

plot3 (x (flat), y (flat), z (flat), blue, light)
plot3 (x (low), y (low), z (low), green, light)
plot3 (x (mid), y (mid), z (mid), yellow, light)
plot3 (x (high), y (high), z (high), orange, light)
plot3 (x (top), y (top), z (top), red, light)

view ([-37.5, 30])
zlim ([-.4, 1])
box off
set (gca, "xgrid", "on", "ygrid", "on", "zgrid", "on")
