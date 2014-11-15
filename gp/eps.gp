set xlabel "Month";
set ylabel "Precipitation_mm";
set xrange [0.5:12.5];
set xtics 1,1,12;
set term pdfcairo lw 2 font "Times_New_Roman,8"
set output "precipitation.pdf"
plot "data" using 1:2 w lp pt 5 title "Beijing",\
     "data" using 1:3 w lp pt 7 title "ShangHai";
set output;


set term pngcairo lw 2 font "AR_PL_UKai_CN,14";
set output "precipitation.png";
replot;
set output;
set term wxt;
