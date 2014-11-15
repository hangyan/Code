set xlabel "Month";
set ylabel "Rain";
set title "Avg Rain-Month";
#unset key;
set xrange [0.5:12.5];
set xtics 1,1,12;
#plot "data" with linespoints linecolor 3 linewidth 2 \
     pointtype 7  pointsize 2;

plot "data" using 1:($2/25.4) w lp pt 5 title "BJ",\
     "data" using 1:($3/25.4)  w lp pt 7 title "SH";

