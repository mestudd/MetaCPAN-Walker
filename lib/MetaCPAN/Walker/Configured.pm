package MetaCPAN::Walker::Configured;

use strict;
use warnings;
use v5.10.0;
 
use Moo;
use namespace::clean;
our $VERSION = '0.01';

use CPAN::Meta;
use List::Util qw(all);
use MetaCPAN::Walker;
use MetaCPAN::Walker::Release;
use Module::CoreList;

my %REQ_LEVEL = (
	requires => 0,
	recommends => 1,
	suggests => 2,
);

#extends 'MetaCPAN::Walker';

has build_order => (
	is => 'ro',
	default => sub { []; },
);

has _configuration => (
	is => 'ro',
	default => sub { {}; },
);

has _conflicts => (
	is => 'ro',
	default => sub { {}; },
);

has existing_versions => (
	is => 'ro',
	default => sub { {}; },
);

has _module_release => (
	is => 'ro',
	default => sub { {}; },
);

has releases => (
	is => 'ro',
	default => sub { {}; },
);

sub _add_conflict {
	my ($self, $release, $path) = @_;

	my $distribution = $release->distribution;
	if (!exists $self->_conflicts->{$distribution}) {
		$self->_conflicts->{$distribution} = {
			release => $release,
			paths   => [],
		}
	}
	push @{$self->_conflicts->{$distribution}->{paths}}, $path;
}

sub _add_requires {
	my ($self, $parent, $distribution) = @_;

	$self->releases->{$parent}->add_requires($distribution);
}

# Track release information.
# Returns if releas was already known.
sub _add_release {
	my ($self, $release, $dep) = @_;

	my $distribution = $release->distribution;

	if (exists($self->releases->{$distribution})) {
		 return $self->releases->{$distribution}
		 		->update_required($dep->{relationship});
	} else {
#		use Data::Dumper; print Dumper($release->metadata);
#		die;
		$self->releases->{$distribution} = MetaCPAN::Walker::Release->new(
			cpan_meta => CPAN::Meta->new($release->metadata),
			name      => $distribution,
			required  => $REQ_LEVEL{$dep->{relationship}},
		);

		# Only recurse if required
		# TODO hook in configuration to mark 
		return $dep->{relationship} eq 'requires';
	}
}

sub build_from_initial_modules {
	my $self = shift;
	my @modules = map +{
		    module => $_,
			phase  => 'runtime',
			relationship => 'requires',
		}, @_;

	my @path = ('root');
	my @relationship = ($REQ_LEVEL{requires});

	my $walker = MetaCPAN::Walker->new();
	$walker->releases_for_dependency(@modules,
		sub {
			my ($dep, $release, $level) = @_;
			my $distribution = $release->distribution;
$DB::single = $#path > 2;
			my $parent = $path[-1];

			push @path, $distribution;
			push @relationship, $REQ_LEVEL{$dep->{relationship}};

			# Completely ignore core and development modules
			return 0 if (Module::CoreList::is_core($dep->{module})
				|| $dep->{phase} eq 'develop');

			# Keep track of conflicting releases
			if ($dep->{relationship} eq 'conflicts') {
				$self->_add_conflict($release, [ @path ]);
				return 0;
			}

#say sprintf '%s\\ %s is %s for %s; from %s version %s',
#	'|   ' x $level, $dep->{module}, $dep->{relationship}, $dep->{phase},
#	$distribution, $release->version;

warn '$parent undef' if (!defined $parent);
			$self->_add_requires($parent, $distribution)
				if (defined $parent && $parent ne 'root');
			return $self->_add_release($release, $dep);
		},
		sub {
			my ($dep, $release, $level) = @_;

			pop @path;
			pop @relationship;
		},
	);
}

sub ordered {
	my $self = shift;

	my @order;
	my $r;
	$r = sub {
		foreach my $release (@_) {
			next if ($release->required != 0);
			next if (grep $release->name eq $release->name, @order);

			&$r(map $self->releases->{$_}, $release->requires);
			push @order, $release;
		}
	};

	&$r($self->required);

	return @order;
}
sub recommended {
	my $self = shift;

	return sort { $a->name cmp $b->name }
		grep $_->required == 1,
			values %{$self->releases};
}

sub all_releases {
	my $self = shift;

	return sort { $a->name cmp $b->name }
			values %{$self->releases}
}

sub required {
	my $self = shift;

	return sort { $a->name cmp $b->name }
		grep $_->required == 0,
			values %{$self->releases}
}

sub suggested {
	my $self = shift;

	return sort { $a->name cmp $b->name }
		grep $_->required == 2,
			values %{$self->releases}
}

1;
