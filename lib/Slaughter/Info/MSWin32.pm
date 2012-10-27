#!/usr/bin/perl -w

=head1 NAME

Slaughter::Info::MSWin32 - Perl Automation Tool Helper Windows info implementation

=cut

=head1 SYNOPSIS

This module is the Windows versions of the Slaughter information-gathering
module.

Modules beneath the Slaughter::Info namespace are called when slaughter
is executed, they are intended to populate a hash with system information
about the current host.

This module is loaded only on Windows systems, and will determine such details
as the operating system version, the processor type, etc.

Usage is:


=for example begin

    use Slaughter::Info::linux;

    my %info;
    MetaInformation( \%info );

    # use info now ..
    print $info{'arch'} . " architecture\n";

=for example end

=cut


=head1 AUTHOR

 Steve
 --
 http://www.steve.org.uk/

=cut

=head1 LICENSE

Copyright (c) 2010-2012 by Steve Kemp.  All rights reserved.

This module is free software;
you can redistribute it and/or modify it under
the same terms as Perl itself.
The LICENSE file contains the full text of the license.

=cut





=head2 MetaInformation

This function retrieves meta-information about the current host,
and is invoked on Microsoft Windows systems.

=for example begin

  my %data;
  MetaInformation( \%data );

=for example end

NOTE:  This has only been tested under Strawberry perl.

=cut

sub MetaInformation
{
    my ($ref) = (@_);

    #
    #  Kernel version.
    #
    $ref->{ 'kernel' } = $ENV{ 'OS' };
    chomp( $ref->{ 'kernel' } );

    #
    #  Are we i386/amd64?
    #
    my $type = $ENV{ 'PROCESSOR_ARCHITECTURE' };
    if ( $type =~ /x86/i )
    {
        $ref->{ 'arch' } = "i386";
        $ref->{ 'bits' } = 32;
    }
    else
    {
        $ref->{ 'arch' } = "amd64";
        $ref->{ 'bits' } = 64;
    }


    #
    #  IP address(es).
    #
    my $ip = undef;

    $ip = "ipconfig";

    if ( defined($ip) )
    {
        my $count = 1;

        foreach my $line ( split( /[\r\n]/, `$ip` ) )
        {
            next if ( !defined($line) || !length($line) );
            chomp($line);

            #
            #  This matches something like:
            #
            #  IP Address. . . . . . . . . . . . : 10.6.11.138
            #
            #
            if ( $line =~ /IP Address.* : (.*)/ )
            {
                my $ip = $1;

                #
                # Save away the IP address in "ip0", "ip1", "ip2" .. etc.
                #
                $ref->{ "ip" . $count } = $ip;
                $count += 1;
            }
        }

        if ( $count > 0 )
        {
            $ref->{ 'ipcount' } = ( $count - 1 );
        }
    }


    #
    #  Find the name of our release
    #
    my @win_info = Win32::GetOSVersion();
    my $version  = $win_info[0];
    my $distrib  = Win32::GetOSName();

    # work around for historical reasons
    $distrib = 'WinXP' if $distrib =~ /^WinXP/;
    $ref->{ 'version' }      = $version;
    $ref->{ 'distribution' } = $distrib;

}

1;
