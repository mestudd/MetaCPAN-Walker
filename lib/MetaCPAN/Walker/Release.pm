package MetaCPAN::Walker::Release;

use strict;
use warnings;
 
use Moo;
use namespace::clean;
our $VERSION = '0.01';

my %REQ_LEVEL = (
	requires => 0,
	recommends => 1,
	suggests => 2,
);

has cpan_meta => ( is => 'ro', required => 1 );

has name => ( is => 'ro', required => 1 );

has required => ( is => 'rw', required => 1 );

has _requires => ( is => 'ro', default => sub { {}; } );

sub add_requires {
	my ($self, $release) = @_;

	$self->_requires->{$release} = 1;
}

sub requires {
	my $self = shift;

	return sort keys %{$self->_requires};
}

sub update_required {
	my ($self, $level) = @_;

	if ($REQ_LEVEL{$level} < $self->required) {
		$self->required($REQ_LEVEL{$level});
		return $level eq 'requires';
	}

	return 0;
}

1;
