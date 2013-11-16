#!/usr/bin/perl -w
# money.pl --- my money usage
# Author:  <yuyan@jing>
# Created: 17 Nov 2013
# Version: 0.01

use warnings;
use strict;

use Time::Piece;
use String::Util 'trim';




my $FILE = "/home/yuyan/.yanhang/money";

if (! open MONEY,"$FILE") {
    die "File not exist! ($!)";
}

my $total = 0;

my $dateformat = "%Y-%m-%d";
my $min_date = "2013-10-01";
my $max_date = "2013-10-01";
my $expense = 0;
my $income = 0;
my %dis;
my $sub;



$min_date = Time::Piece->strptime($min_date,$dateformat);
$max_date = Time::Piece->strptime($max_date,$dateformat);



while (<MONEY>) {
    chomp;
    (my $date,my $name,my $number,my $desc) = split(",");
    
    $date = trim($date);
    $name = trim($name);
    $number = trim($number);
    $desc = trim($desc);
    
    
    $total += $number;

   
    
    if ($name =~ /Expense\./) { 
        $expense += $number;
        $name =~ s/Expense\.//;
        
        if (exists $dis{$name}) {

            $dis{$name} += abs($number);
        } else {
            $dis{$name} = abs($number);
            
        }
        
        
    }

    $date = Time::Piece->strptime($date,$dateformat);
    if ($date < $min_date) {
        $min_date = $date;
        
    }
    if ($date > $max_date) {
        $max_date = $date
    }

    
}

$expense = abs($expense);



print "--------------------------------------\n";

print "结余:";
print $total,"\n";
print "开始日期:",$min_date->strftime($dateformat),"\n";
print "结束日期:",$max_date->strftime($dateformat),"\n";
print "--------------------------------------\n";
print "支出:\n";
print "总计:",$expense,"\n";
print "--------------\n";

while (my ($k,$v)=each %dis) {
    printf "%s \t %.2f \t  %5.2f%% \n",$k,$v,$v/$expense*100;
    
}













__END__

=head1 NAME

money.pl - Describe the usage of script briefly

=head1 SYNOPSIS

money.pl [options] args

      -opt --long      Option description

=head1 DESCRIPTION

Stub documentation for money.pl, 

=head1 AUTHOR

, E<lt>yuyan@jingE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 by 

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.

=head1 BUGS

None reported... yet.

=cut
