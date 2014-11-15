#!/usr/bin/perl -w
# system.pl --- exe system process
# Author: yuyan <yuyan@jing.site>
# Created: 31 Oct 2013
# Version: 0.01

use warnings;
use strict;
use 5.014;

use IPC::System::Simple qw(system);


#system 'ls -l $HOME';

#system 'for i in *;do echo == $i==;cat $i;done';

my $who_text = `who`;
my @who_lines = split /\n/,$who_text;

@who_lines = `who`;
say @who_lines;



open DATE,'date|' or die "cannot pipe from date:$!";
#open MAIL,'|mail yuyan' or die "cannot pipe to mail:$!";



open my $find_fh,'-|',
    'find',qw(/ -atime +90 -size +1000 -print)
    or die "fork: $|";
while (<$find_fh>) {
    chomp;
    printf "%s size %dK last accessed %.2f days ago\n",
        $_,(1023 + -s $_)/1024, -A $_;
    
}



__END__

=head1 NAME

system.pl - Describe the usage of script briefly

=head1 SYNOPSIS

system.pl [options] args

      -opt --long      Option description

=head1 DESCRIPTION

Stub documentation for system.pl, 

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
