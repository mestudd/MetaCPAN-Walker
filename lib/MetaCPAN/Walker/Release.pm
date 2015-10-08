package MetaCPAN::Walker::Release;

use strict;
use warnings;

use CPAN::Meta;
use version;
 
use Moo;
use namespace::clean;
our $VERSION = '0.01';

# CPAN::Meta object
has cpan_meta => (
	is      => 'ro',
	required => 1,
	handles => [qw(name version abstract description licenses
		effective_prereqs features feature 
		provides resources)],
);

has requirements => (
	is      => 'rw',
	lazy    => 1,
	builder => '_build_requirements',
	handles => ['required_modules'],
);

has version_latest => ( is => 'rw' );

has version_local => ( is => 'rw' );

has version_required => ( is => 'rw' );

sub _build_cpan_meta {
	my $self = shift;

	return CPAN::Meta->new($self->release->metadata);
}

sub _build_requirements {
	my $self = shift;

	return CPAN::Meta::Requirements->new();
}

sub update_available {
	my $self = shift;

	return $self->version_local
		&& $self->version_latest > $self->version_local;
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
