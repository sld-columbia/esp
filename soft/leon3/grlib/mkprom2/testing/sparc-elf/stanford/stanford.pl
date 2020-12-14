#!/usr/bin/perl

if (scalar(@ARGV) != 1) {
    die("Error: $0 <file.info>, called with ".join(" ",@ARGV));
}
my $m = "";
while(<>) { $m .= $_; }

#print $m;

if (!($m =~ m/Perm\s+Towers\s+Queens\s+Intmm\s+Mm\s+Puzzle\s+Quick\s+Bubble\s+Tree\s+FFT/ms &&
      $m =~ m/Nonfloating\s+point\s+composite\s+is/ms)) {
    print("failed");
} else {
    print("ok");
}


