#!/usr/bin/perl

if (scalar(@ARGV) < 1) {
    die("Error: $0 <file>, called with ".join(" ",@ARGV));
}
my $file = $ARGV[0];

if ( ! -f "$file.info" ) {
    print("failed");
    exit;
}

print "ok";

