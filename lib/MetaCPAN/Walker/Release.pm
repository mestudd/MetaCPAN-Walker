package MetaCPAN::Walker::Release;

use strict;
use warnings;

use version;
 
use Moo;
use namespace::clean;
our $VERSION = '0.01';

has release => ( is => 'ro', required => 1 );

has name => ( is => 'ro', required => 1 );

has version_latest => ( is => 'rw' );

has version_local => ( is => 'rw' );

has version_required => ( is => 'rw' );

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
