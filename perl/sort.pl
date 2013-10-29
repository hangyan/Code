#!/usr/bin/perl -w
# sort.pl --- some sort examples
# Author: yuyan <yuyan@jing.site>
# Created: 25 Oct 2013
# Version: 0.01

use warnings;
use strict;
use v5.14.2;



sub by_number {
    $a <=> $b
}
    
    
my @some_numbers = [1,2,3,4,7,5,9,0];


my @result  = sort by_number @some_numbers;
    
print @result,"\n";



           

my %score = ("barney" => 195,"fred" => 205,"dino" => 30,"bamm-bamm"=>195);
sub by_score { $score{$b} <=> $score{$a}}
sub by_score_and_name {
    $score{$b} <=> $score{$a}
        or
            $a cmp $b
        }

my @winners = sort by_score_and_name keys %score;

print "@winners","\n";



say "match number ~~ string" if 4 ~~ '5abc';
say "match string ~~ number" if '4abc' ~~ 4;


    
__END__

=head1 NAME

sort.pl - Describe the usage of script briefly

=head1 SYNOPSIS

sort.pl [options] args

      -opt --long      Option description

=head1 DESCRIPTION

Stub documentation for sort.pl, 

=head1 AUTHOR

yuyan, E<lt>yuyan@jing.siteE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 by yuyan

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.

=head1 BUGS

None reported... yet.

=cut
