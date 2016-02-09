###############################################################################
#
# File:         IISScriptMap.pl
# Description:  Creates script mappings in the IIS metabase.
#
# Copyright (c) 2000-2003 ActiveState Corp.  All rights reserved.
#
###############################################################################
BEGIN {
    $tmp = $ENV{'TEMP'} || $ENV{'tmp'} || 
	($Config{'osname'} eq 'MSWin32' ? 'c:/temp' : '/tmp');
    open(STDERR, ">> $tmp/ActivePerlInstall.log");
}

use strict;
use Win32::OLE;

my $error = AddFileExtMapping(@ARGV);
exit(0);

sub AddFileExtMapping {
    my $serverID	    = shift;

    if ($serverID =~ /;/) {
	my @rest = @_;
	my @servers = split /;/, $serverID;
	for my $id (@servers) {
	    AddFileExtMapping($id,@rest);
	}
	return;
    }

    my $virtDir		    = shift;

    if ($virtDir =~ /;/) {
	my @rest = @_;
	my @dirs = split /;/, $virtDir, -1;
	for my $dir (@dirs) {
	    AddFileExtMapping($serverID,$dir,@rest);
	}
	return;
    }

    my $fileExt		    = shift;
    my $execPath	    = shift;
    my $flags		    = shift;
    my $methodExclude	    = shift;

    my $node = "IIS://localhost/W3SVC";

    # NOTE: A serverID of "0" is treated as the W3SVC root; any supplied
    # virtual directory for this case is ignored.

    $node .= "/$serverID/ROOT" if $serverID > 0;
    $node .= "/$virtDir" if $serverID > 0 and length($virtDir) > 0;

    # Get the IIsVirtualDir Automation Object
    my $server = Win32::OLE->GetObject($node) ||
	return;
    
    # create our new script mapping entry
    my $scriptMapping = "$fileExt,$execPath";
    $scriptMapping .= ",$flags";
    $scriptMapping .= ",$methodExclude";
    
    my @ScriptMaps = @{$server->{ScriptMaps}};
    my @NewScriptMaps = map { 
	/^\Q$fileExt,\E.*/ ? $scriptMapping : $_ } @ScriptMaps;
    push(@NewScriptMaps, $scriptMapping) 
	unless grep {/^\Q$fileExt,\E.*/} @NewScriptMaps;
    print join("\n", @NewScriptMaps);
    
    $server->{ScriptMaps} = \@NewScriptMaps;

    # Save the new script mappings
    $server->SetInfo(); 
}
