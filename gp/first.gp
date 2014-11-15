set samples 500;
unset key;
set title "sin5*x example";
set xlabel "X";
set ylabel "Y";
set xrange [-2*pi:2*pi];
set xtics pi;
set mxtics 2;
set ytics -1,0.5,1;

plot sin(5*x);
