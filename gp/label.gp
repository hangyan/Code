sinc(x) = sin(pi*x)/(pi*x);
set  xlabel "X";
set ylabel "Y";
unset key;
set samples 500;
set xrange [-5:5];
set xtics 1;
set x2range [0:10];
set x2tics 1;
set y2range [-2:5];
set y2tics 1;
set grid;
#set label 1 "hello first " at 2,0.5;
#set label 2 "hello second" at second 2,0.5;
plot sinc(x);

