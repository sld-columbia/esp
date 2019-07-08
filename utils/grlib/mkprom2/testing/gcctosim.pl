#!/usr/bin/perl

if (scalar(@ARGV) < 1) {
    die("Error: $0 <sim> <gccoptions>, called with ".join(" ",@ARGV));
}
my $sim = $ARGV[0];
my $opt = $ARGV[1];
$sim =~ s/.exe$//;
$sim =~ s/^.*\///;
my $simopt = "";

if (!($sim eq 'tsim-leon' ||
      $sim eq 'tsim-leon3' ||
      $sim eq 'tsim-erc32' ||
      $sim eq 'grsim')) {
    die("Error: expecting tsim-erc32 tsim-leon tsim-leon3 grsim as simulators\n");
}

if($opt =~ /\@msoft-float/) {
    if($sim eq 'tsim-leon') {
	$simopt .= " -nfp ";
    } elsif($sim eq 'tsim-leon3') {
	$simopt .= " -nfp ";
    } elsif($sim eq 'tsim-erc32') {
	$simopt .= " -nfp ";
    } elsif($sim eq 'grsim') {
	$simopt .= " -nfp ";
    }
}

if(!($opt =~ /\@mcpu=v8/)) {
    if($sim eq 'tsim-leon') {
	$simopt .= " -nov8 ";
    } elsif($sim eq 'tsim-leon3') {
 	$simopt .= " -nov8 ";
    } elsif($sim eq 'tsim-erc32') {
	#print(STDERR "warning: running with \@mcpu=v8 option for tsim-erc32:\n".join(" ",@ARGV));
    } elsif($sim eq 'grsim') {
 	$simopt .= " -nov8 ";
    }
} else {
}

if($opt =~ /\@mflat/) {
    if($sim eq 'tsim-leon') {
	die("error: \@mflat option not supported for tsim-leon\n");
    } elsif($sim eq 'tsim-leon3') {
	$simopt .= " -nwin 2 ";
    } elsif($sim eq 'tsim-erc32') {
	die("error: \@mflat option not supported for tsim-erc32\n");
    } elsif($sim eq 'grsim') {
	die("error: \@mflat option not supported for grsim\n");
    }
}

if($opt =~ /\@qsvt/) {
    if($sim eq 'tsim-leon') {
	die("error: \@qsvt option not supported for tsim-leon\n");
    } elsif($sim eq 'tsim-leon3') {
    } elsif($sim eq 'tsim-erc32') {
	die("error: \@qsvt option not supported for tsim-erc32\n");
    } elsif($sim eq 'grsim') {
    }
}

#print(STDERR "Options for $sim: $simopt\n");
print($simopt);


