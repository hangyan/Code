set term wxt enhanced;
set xlabel "X";
set ylabel "Y";
set xrange [0:10];
set xtics 0,1,10;
unset key;
set title "f(x) = {/Symbol=6 \326} ~{x^@3}{1.1{/Symbol=16 \276}}&{aa} \
 Function Pic";
plot sqrt(x**3);
