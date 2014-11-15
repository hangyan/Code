set xlabel "月份";
set ylabel "降水量（毫米）";
set y2label "气温（摄氏度)";
set title "北京市平均降水量及气温";
set xrange [0.5:12.5];
set xtics 1,1,12
set ytics nomirror;
set y2tics;
set grid xtics y2tics;
set y2range [-10:40];
set y2tics 5;
set grid;
plot "weather_bj.dat" u 1:2 w lp pt 5 lc rgbcolor "#2B60DE"\
     axis x1y1 t "降水量","weather_bj.dat" u 1:3 w lp pt 7\
     lc rgbcolor "#F62817" axis x1y2 t "气温";
