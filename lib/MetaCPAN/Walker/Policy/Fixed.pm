package MetaCPAN::Walker::Policy::Fixed;
use v5.10.0;

use Module::CoreList;

use Moo;
use strictures 2;
use namespace::clean;

# Keep these in namespace
use MooX::Options protect_argv => 0;

our $VERSION = '0.01';

with qw(MetaCPAN::Walker::Policy);

# Configure each phase
option configure => (is => 'ro', default => 0, negativable => 1);
option build     => (is => 'ro', default => 0, negativable => 1);
option test      => (is => 'ro', default => 0, negativable => 1);
option runtime   => (is => 'ro', default => 1, negativable => 1);
option develop   => (is => 'ro', default => 0, negativable => 1);

# Configure each relationship
option requires   => (is => 'ro', default => 1, negativable => 1);
option recommends => (is => 'ro', default => 0, negativable => 1);
option suggests   => (is => 'ro', default => 0, negativable => 1);
option conflicts  => (is => 'ro', default => 0, negativable => 1);

# Configure whether to follow already seen releases
option core  => (is => 'ro', default => 0, negativable => 1);
option seen  => (is => 'ro', default => 0, negativable => 1);

# Configure the version of perl targetted
option perl => (is => 'ro', format=> 's', default => '5.22.0');

has _seen => (
	is      => 'ro',
	lazy    => 1,
	default => sub { {} },
);


sub process_dependency {
	my ($self, $path, $release, $dependency) = @_;

	unless ($self->core) {
		return 0 if (Module::CoreList::is_core(
				$dependency->{module},
				undef,
				$self->perl,
		));
	}

	my $phase = $dependency->{phase};
	my $relationship = $dependency->{relationship};

	return $self->$phase && $self->$relationship;
}

sub process_release {
	my ($self, $path, $release) = @_;

	my $seen = $self->_seen->{$release->name};
	$self->_seen->{$release->name} = 1;

	return $self->seen || !$seen;
}

1;
