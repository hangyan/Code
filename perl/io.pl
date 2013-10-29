#!/usr/bin/perl -w
use strict;

print "Hello world!\n";

@ARGV = qw# larry moe culy #;
while (<>) {
    chomp;
    print "It was $_ that i saw in some stooge-like file\n";
}
