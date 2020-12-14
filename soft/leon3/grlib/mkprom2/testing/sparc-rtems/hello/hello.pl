#!/usr/bin/perl

if (scalar(@ARGV) != 1) {
    die("Error: $0 <file.info>, called with ".join(" ",@ARGV));
}
my $m = "";
while(<>) { $m .= $_; }

#print $m;

if (!($m =~ m/Hello\s+World/ms )) {
    print("failed");
} else {
    print("ok");
}


