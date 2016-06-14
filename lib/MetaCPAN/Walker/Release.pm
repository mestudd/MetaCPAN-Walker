package MetaCPAN::Walker::Release;

use strict;
use warnings;

use CPAN::Meta;
use version;
 
use Moo;
use namespace::clean;
our $VERSION = '0.0.2';

# CPAN::Meta object
has cpan_meta => (
	is      => 'rw',
	required => 1,
	handles => [qw(name version abstract description licenses
		effective_prereqs features feature 
		provides resources)],
);

has download_url => ( is => 'rw' );

has requirements => (
	is      => 'rw',
	lazy    => 1,
	builder => '_build_requirements',
	handles => ['required_modules'],
);

has version_latest => ( is => 'rw' );

has version_local => ( is => 'rw' );

has version_required => ( is => 'rw' );

sub _build_requirements {
	my $self = shift;

	return CPAN::Meta::Requirements->new();
}

sub update_available {
	my $self = shift;

	return $self->version_local
		&& $self->version_latest > $self->version_local;
}

sub update_requested {
	my $self = shift;

	return $self->version_local
		&& $self->version > $self->version_local;
}

sub update_required {
	my $self = shift;

	return $self->version_local
		&& $self->version_required > $self->version_local;
}

# keep the maximum of the minimum versions required
sub update_version_required {
	my ($self, $version) = @_;

	my $new = version->parse($version);
	if ($new > $self->version_required) {
		$self->version_required($new);
	}

	return $self->version_required;
}

1;
__END__

=encoding utf-8

=head1 NAME

MetaCPAN::Walker::Release - Object describing CPAN release

=head1 SYNOPSIS

  use MetaCPAN::Walker::Release;

  my $release = MetaCPAN::Walker::Release->new(
      cpan_meta        => $cpan_meta,
      download_url     => 'https://example.org/download',
      version_latest   => '0.3.2',
      version_local    => '0.3.1',
      version_required => '0.2.0',
  );

=head1 DESCRIPTION

MetaCPAN::Walker::Release extends CPAN::Meta object to hold release information
for walking MetaCPAN.

=head1 Attributes

=head2 cpan_meta

L<CPAN::Meta> object defining the release from its META file.

=head3 name version abstract description licenses features feature provides resources

Attributes forwarded to C<cpan_meta> object.

=head2 download_url

The URL to the source file for the release.

=head2 requirements

L<CPAN::Meta::Requirements> object containing the calculated required modules
for the release. A policy usually populates this, possibly removing or adding
modules from the set in the META file.

=head2 version_latest, version_local, version_required

The release versions: latest available, locally available, and minimum
required.

=head1 METHODS

=head2 effective_prereqs

Forwarded to C<cpan_meta>.

=head2 required_modules

Forwarded to C<required_modules>

=head2 update_available, update_required

Methods to check if there is an update available or required, based on
the local version.

=head2 update_version_required($version)

Updates the version_required value. Replace C<version_required> if C<$version>
is newer than the current required.

=head1 AUTHOR

Malcolm Studd E<lt>mestudd@gmail.comE<gt>

=head1 COPYRIGHT

Copyright 2015- Recognia Inc.

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
