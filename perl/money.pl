#!/usr/bin/perl -w
# money.pl --- my money usage managerment script
# Author:  <yuyan@jing>
# Created: 17 Nov 2013
# Version: 0.01

use warnings;
use strict;

use Time::Piece;
use String::Util 'trim';
use POSIX;
use Term::ANSIColor qw(:constants);


#############################################
# Brief:   the origin data file
# Format:  date,name,number,desc
# Example: 2013-11-11,Expense.Eat,-100,good.
############################################
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

        # Expense.Eat-->Eat
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

my $pct;

while (my ($k,$v) = each %dis) {
    $pct = $v/$expense*100;
    
    printf "%s \t %.2f \t %5.2f%% ",$k,$v,$pct;
    if (int($pct + 0.5) > 10) {        
        print RED,"*" x int($pct + 0.5),RESET;
    } else {
        print "*" x int($pct + 0.5);        
    }
     print "\n";
}

print "--------------------------------------\n"; 












