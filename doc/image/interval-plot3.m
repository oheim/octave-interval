red = [220 50 47] ./ 255;
shade = [238 232 213] ./ 255;
x = midrad (1 : 6, 0.25);
y = midrad (-3 : 3, 0.25);
[x, y] = meshgrid (x, y);
z = atan2 (y, x);
plot3 (x, y, z, shade, red)
view ([-35, 30])
box off
set (gca, "xgrid", "on", "ygrid", "on", "zgrid", "on")
