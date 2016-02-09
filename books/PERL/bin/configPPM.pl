#!perl -w
#
# Copyright (c) 2002-2003 ActiveState Corp.  All rights reserved.
#
use XML::Simple;
use strict;
use File::Copy;

my $ppmConfigFile = $ARGV[0];    # full path of ppm.xml on target install tree
my $sdir          = $ARGV[1];   # directory where install package is located
my $repository;

if ($sdir) {
    # this path sets up the ActiveCD repository if a PPMPackages directory
    # exists two levels up from where the MSI package is located
    $sdir =~ s#\\#/#g;

    # weak series of regex to strip off two levels of extra dirs
    $sdir =~ s#/$##;
    $sdir =~ s#(.*/).*$#$1#;

    $sdir =~ s#/$##;
    $sdir =~ s#(.*/).*$#$1#;
    if (-d $sdir ."PPMPackages") {
	my $location = "${sdir}PPMPackages/";
	if ($^V and $^V ge v5.8.0) {
	    $location .= "5.8-" . ($^O eq "MSWin32" ? "windows" : $^O);
	}
	else {
	    $location .= "5.6plus";
	}
	$repository = {
	  'NAME' => 'ActiveCD Repository',
	  'LOCATION' => $location,
	  'SUMMARYFILE' => 'package.lst'
	};
    }
}

exit unless $sdir && $repository;

print "Configuring PPM ...\n";
chmod(0666, $ppmConfigFile)
    or warn "Unable to chmod $ppmConfigFile: $!\n";

File::Copy::copy($ppmConfigFile, "$ppmConfigFile~") || die;


my $ppmxml = XMLin ($ppmConfigFile, forcearray => 'REPOSITORY', keeproot => 1 );
unshift (@{$ppmxml->{PPMCONFIG}->[0]->{REPOSITORY}}, $repository);
#use Data::Dumper; print Dumper $ppmxml;

open (my $f, ">$ppmConfigFile") || die;

print $f XMLout ($ppmxml, rootname => undef );

close $f;

