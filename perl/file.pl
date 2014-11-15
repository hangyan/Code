#!/usr/bin/perl -w
# file.pl --- file module examples
# Author: yuyan <yuyan@jing.site>
# Created: 03 Nov 2013
# Version: 0.01

use warnings;
use strict;

use v5.14.2;

use File::Basename qw(fileparse basename dirname);
use File::Spec;
use Math::BigInt;
use Spreadsheet::WriteExcel;
use HTTP::SimpleLinkChecker qw(check_link);
use Try::Tiny;

### File::Basename
my $full_path = "/home/yuyan/Code/perl/file.pl";
my $dir_name  = dirname($full_path);
my $base_name = basename($full_path);
say $dir_name, "\t", $base_name;

### File::Spec
my $file_spec = File::Spec->catfile( "home", "yuyan", "Code", "perl", "io.pl" );
say $file_spec;

### Math::BigInt
my $big_int = Math::BigInt->new(2);
$big_int->bpow(1000);

#print $big_int->bstr,"\n";

### SpreadSheet::WriteExcel
my $workbook  = Spreadsheet::WriteExcel->new("perl.xls");
my $worksheet = $workbook->add_worksheet();
$worksheet->write( "A1", "Hello,perl" );

my $red_background = $workbook->add_format(
    color    => 'white',
    bg_color => 'red',
    bold     => 1
);
my $bold = $workbook->add_format( bold => 1 );
$worksheet->write( 0, 1, "read bg", $red_background );
$worksheet->write( 1, 1, "bold",    $bold );

my $product_code = '01234';
$worksheet->write_string( 0, 2, $product_code );

$worksheet->write( 'A3', 37 );
$worksheet->write( 'B3', 42 );
$worksheet->write( 'C3', '=A2+B2' );

### list operator
my @links      = "http";
my @good_links = grep {
    check_link($_);
    !$HTTP::SimpleLinkChecker::ERROR;
} @links;

### map
my @input_numbers = ( 1, 2, 4, 8, 16, 32, 64 );
my @result = map $_ + 100, @input_numbers;
print "@result\n";

@result = map { $_, 3 * $_ } @input_numbers;
print "@result\n";

my %hash = @result;
print "%hash\n";

@result = map { split // } @input_numbers;
print "@result\n";

### eval
my $total = 1;
my $count = 0;

eval { my $average = $total / $count };
print "Continuing after error:$@" if $@;

foreach my $operator (qw(+ - * /)) {
    my $result = eval "2 $operator 2";
    print "2 $operator 2 is $result\n";

}

print 'The quotient is ', eval '5 /', "\n";
warn $@ if $@;

### Try::Tiny
my $average = try { $total / $count } catch { "NaN" };

### do block
my $io = "io.pl";
do $io;

### reference
my @required = qw(preserver sunscreen water_bottle jacket);
my %skipper = map { $_, 1 } qw(blue_shirt hat preserver sunscreen);

foreach my $item (@required) {
    unless ( $skipper{$item} ) {
        print "Skipper is miising $item.\n";

    }
}


my $ref_to_required = \@required;
my $second_ref_to_required = $ref_to_required;
my $third_ref_to_required = \@skipper;




        
     
    

        __END__

=head1 NAME

file.pl - Describe the usage of script briefly

=head1 SYNOPSIS

file.pl [options] args

      -opt --long      Option description

=head1 DESCRIPTION

Stub documentation for file.pl, 

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
