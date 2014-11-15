set samples 25;
set isosamples 26;
set title "Test 3D gnuplot";
set contour base;
set hidden3d offset 1;
splot [-12:12.01] [-12:12.01] sin(sqrt(x**2+y**2))/sqrt(x**2+y**2);
