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

has _wanted_by => ( is => 'ro', default => sub { {}; } );

sub add_requires {
	my ($self, $release, $level) = @_;

	$self->_requires->{$release} = $level;
}

sub add_wanted_by {
	my ($self, $release, $level) = @_;

	$self->_wanted_by->{$release} = $level;
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

sub wanted_by {
	my $self = shift;

	return sort keys %{$self->_wanted_by};
}

1;
