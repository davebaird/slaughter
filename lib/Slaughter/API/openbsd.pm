#!/usr/bin/perl -w

=head1 NAME

Slaughter::API::openbsd - Perl Automation Tool Helper OpenBSD implementation

=cut

=head1 SYNOPSIS


This module is the one that gets loaded upon OpenBSD systems, after the generic
API implementation.  It implements the platform-specific parts of our primitives.

We also attempt to load C<Slaughter::API::Local::openbsd>, where site-specific primitives
may be implemented.  If the loading of this additional module fails we report no error/warning.

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


use strict;
use warnings;


package Slaughter::API::openbsd;




#
#  Package abstraction helpers.
#
use Slaughter::Packages::openbsd;


=begin doc

Export all subs in this package into the main namespace.

This is nasty.

=end doc

=cut

sub import
{
    ## no critic
    no strict 'refs';
    ## use critic

    my $caller = caller;

    while ( my ( $name, $symbol ) = each %{ __PACKAGE__ . '::' } )
    {
        next if $name eq 'BEGIN';     # don't export BEGIN blocks
        next if $name eq 'import';    # don't export this sub
        next unless *{ $symbol }{ CODE };    # export subs only

        my $imported = $caller . '::' . $name;
        *{ $imported } = \*{ $symbol };
    }
}




=head2 InstallPackage

The InstallPackage primitive will allow you to install a system package.

This method uses C<Slaughter::Packages::openbsd>.

=for example begin

  foreach my $package ( qw! bash tcsh ! )
  {
      if ( PackageInstalled( Package => $package ) )
      {
          print "$package installed\n";
      }
      else
      {
          InstallPackage( Package => $package );
      }
  }

=for example end

The following parameters are available:

=over

=item Package [mandatory]

The name of the package to install.

=back

=cut

sub InstallPackage
{
    my (%params) = (@_);

    my $package = $params{ 'Package' } || return;

    #
    #  Gain access to the package helper.
    #
    my $helper = Slaughter::Packages::openbsd->new();

    #
    #  If we recognise the system, install the package
    #
    if ( $helper->recognised() )
    {
        $helper->installPackage( $params{ 'Package' } );
    }
    else
    {
        print "Unknown package-type.  Packaging support not present.\n";
    }
}




=head2 PackageInstalled

Test whether a given system package is installed.

This method uses C<Slaughter::Packages::openbsd>.

=for example begin

  if ( PackageInstalled( Package => "exim4-config" ) )
  {
      print "$package installed\n";
  }

=for example end

The following parameters are supported:

=over 8

=item Package

The name of the package to test.

=back

The return value will be a 0 if not installed, or 1 if it is.

=cut

sub PackageInstalled
{
    my (%params) = (@_);

    my $package = $params{ 'Package' } || return;

    #
    #  Gain access to the package helper.
    #
    my $helper = Slaughter::Packages::openbsd->new();

    #
    #  If we recognise the system, test the package installation state.
    #
    if ( $helper->recognised() )
    {
        $helper->isInstalled($package);
    }
    else
    {
        print "Unknown package-type.  Packaging support not present.\n";
    }
}




=head2 RemovePackage

Remove the specified system package from the system.

This method uses C<Slaughter::Packages::openbsd>.

=for example begin

  if ( PackageInstalled( Package => 'telnetd' ) )
  {
      RemovePackage( Package => 'telnetd' );
  }

=for example end

The following parameters are supported:

=over 8

=item Package

The name of the package to remove.

=back

=cut

sub RemovePackage
{
    my (%params) = (@_);

    my $package = $params{ 'Package' } || return;

    #
    #  Gain access to the package helper.
    #
    my $helper = Slaughter::Packages::openbsd->new();

    #
    #  If we recognise the system, remove the package
    #
    if ( $helper->recognised() )
    {
        $helper->removePackage( $params{ 'Package' } );
    }
    else
    {
        print "Unknown package-type.  Packaging support not present.\n";
    }
}


=head2 UserCreate

Create a new user for the system.

=for example begin

  # TODO

=for example end

The following parameters are required:

=over 8

=item Login

The username to create.

=item UID

The UID for the user.

=item GID

The primary GID for the user.

=back

You may optionally specify the GCos field to use.

=cut

sub UserCreate
{
    my (%params) = (@_);

    #
    #  Ensure we have the variables we need.
    #
    foreach my $variable (qw! Login UID GID !)
    {
        if ( !defined( $params{ $variable } ) )
        {

            #
            #  Return undef..
            #
            return ( $params{ $variable } );
        }
    }

    #
    #  If the GCos field isn't set then define it.
    #
    $params{ 'Gcos' } = $params{ 'Login' } if ( !$params{ 'Gcos' } );


    my $cmd =
      "useradd -vc \"$params{ 'Gcos' }\"" . " -g =uid" . " -G wheel" . " -m" .
      " -u $params{ 'UID' }" . " -L staff" . " $params{ 'Login' }";

    # useradd -c name -d /home/user -g adm -m -u 801 user
    RunCommand( Cmd => $cmd );
}

1;
