hold on
blue = [38 139 210] ./ 255;
shade = [238 232 213] ./ 255;
## Interval plotting
x = mince (2*infsup (0, "pi"), 6);
plot (x, sin (x), shade)
## Classical plotting
x = linspace (0, 2*pi, 7);
plot (x, sin (x), 'linewidth', 2, 'color', blue)
set (gca, 'XTick', 0 : pi : 2*pi)
set (gca, 'XTickLabel', {'0', 'pi', '2 pi'})
