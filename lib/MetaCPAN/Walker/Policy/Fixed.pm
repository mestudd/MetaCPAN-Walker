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

# Configure other dependencies to follow
option core     => (is => 'ro', default => 0, negativable => 1);
option features => (is => 'ro', default => 0, negativable => 1);
option seen     => (is => 'ro', default => 0, negativable => 1);

# Configure the version of perl targetted
option perl => (is => 'ro', format=> 's', default => '5.22.0');

has _seen => (
	is      => 'ro',
	lazy    => 1,
	default => sub { {} },
);


sub process_release {
	my ($self, $path, $release) = @_;

	return 0 if ($release->name eq 'perl');

	my $seen = $self->_seen->{$release->name};
	$self->_seen->{$release->name} = 1;

	if (!$seen) {
		my @features;
		push @features, map $_->identifier, $release->features
			if ($self->features);
		my $prereqs = $release->effective_prereqs(\@features);

		my @phases;
		push @phases, 'configure' if ($self->configure);
		push @phases, 'build' if ($self->build);
		push @phases, 'test' if ($self->test);
		push @phases, 'runtime' if ($self->runtime);
		push @phases, 'develop' if ($self->develop);

		my @relationships;
		push @relationships, 'requires' if ($self->requires);
		push @relationships, 'recommends' if ($self->recommends);
		push @relationships, 'suggests' if ($self->suggests);
		push @relationships, 'conflicts' if ($self->conflicts);

		my $reqs = $prereqs->merged_requirements(\@phases, \@relationships);
		$reqs->clear_requirement('perl');
		unless ($self->core) {
			foreach my $module ($reqs->required_modules) {
				if (Module::CoreList::is_core($module, undef, $self->perl)) {
					$reqs->clear_requirement($module);
				}
			}
		}

		$release->requirements($reqs);
	}

	return $self->seen || !$seen;
}

1;
