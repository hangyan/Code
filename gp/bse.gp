set term wxt enhanced;
set xlabel "X";
set ylabel "y";
set xrange [0:10];
set xtics 0,1,10;
unset key;
set title "0阶贝塞尔函数 J_0(X)";
plot besj0(x);

set grid;
replot
