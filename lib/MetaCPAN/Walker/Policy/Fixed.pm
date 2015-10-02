package MetaCPAN::Walker::Policy::Fixed;
use v5.10.0;

use Moo;
use strictures 2;
use namespace::clean;

# Keep these in namespace
use MooX::Options protect_argv => 0;

our $VERSION = '0.01';

with qw(MetaCPAN::Walker::Policy);

# Configure each phase
option configure => (is => 'ro', default => 0);
option build     => (is => 'ro', default => 0);
option test      => (is => 'ro', default => 0);
option runtime   => (is => 'ro', default => 1);
option develop   => (is => 'ro', default => 0);

# Configure each relationship
option requires   => (is => 'ro', default => 1);
option recommends => (is => 'ro', default => 0);
option suggests   => (is => 'ro', default => 0);
option conflicts  => (is => 'ro', default => 0);

# Configure whether to follow already seen releases
option seen => (
	is      => 'ro',
	lazy    => 1,
	default => sub { {} },
);


sub process_dependency {
	my ($self, $path, $release, $dependency) = @_;

	my $phase = $dependency->{phase};
	my $relationship = $dependency->{relationship};

	return $self->$phase && $self->$relationship;
}

sub process_release {
	my ($self, $path, $release) = @_;

	my $seen = $self->seen->{$release->name};
	$self->seen->{$release->name} = 1;

	return !$seen;
}

1;
