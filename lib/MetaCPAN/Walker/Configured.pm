package MetaCPAN::Walker::Configured;

use strict;
use warnings;
use v5.10.0;
 
use Moo;
use namespace::clean;
our $VERSION = '0.01';

use CPAN::Meta;
use JSON::XS;
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

has config_file => (
	is => 'ro',
	default => './etc/config.json',
);

has _configuration => (
	is => 'ro',
	lazy => 1,
	builder => '_read_config_file',
);

has _conflicts => (
	is => 'ro',
	default => sub { {}; },
);

has existing_versions => (
	is => 'ro',
	default => sub { {}; },
);

has releases => (
	is => 'ro',
	default => sub { {}; },
);

has _walker => (
	is => 'ro',
	lazy => 1,
	default => sub { MetaCPAN::Walker->new(); },
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

sub _add_relationship {
	my ($self, $parent, $distribution, $level) = @_;

	$self->releases->{$parent}->add_requires($distribution, $level);
	$self->releases->{$distribution}->add_wanted_by($parent, $level);
}

# Track release information.
# Returns if releas was already known.
sub _add_release {
	my ($self, $release, $relationship) = @_;

	my $distribution = $release->distribution;

	if (exists($self->releases->{$distribution})) {
		return $self->releases->{$distribution}
			->update_required($relationship);
	} else {
#		use Data::Dumper; print Dumper($release->metadata);
#		die;
		$self->releases->{$distribution} = MetaCPAN::Walker::Release->new(
			cpan_meta => CPAN::Meta->new($release->metadata),
			name      => $distribution,
			required  => $REQ_LEVEL{$relationship},
		);

		# Only recurse if required
		# TODO hook in configuration to mark 
		return $relationship eq 'requires';
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

	$self->_walker->releases_for_dependency(@modules,
		sub {
			my ($dep, $release, $level) = @_;
			my $distribution = $release->distribution;
			my $parent = $path[-1];

			push @path, $distribution;
			push @relationship, $REQ_LEVEL{$dep->{relationship}};

			my $config = $self->_configuration->{$distribution} || {};

			# Completely ignore core, development, and ignored modules
			return 0 if (Module::CoreList::is_core($dep->{module}, undef, '5.22.0')
				|| $dep->{phase} eq 'develop')
				|| (defined($config->{build}) && $config->{build} eq 'no');

			# Keep track of conflicting releases
			if ($dep->{relationship} eq 'conflicts') {
				$self->_add_conflict($release, [ @path ]);
				return 0;
			}

			# If we're building it anyway, up it to required everywhere
			my $relationship = $dep->{relationship};
			if (defined($config->{build}) && $config->{build} eq 'yes') {
				$relationship = 'requires';
			}
			my $return = $self->_add_release($release, $relationship);

			$self->_add_relationship($parent, $distribution, $dep->{relationship})
				if (defined $parent && $parent ne 'root');

			return $return;
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

	my @path;
	my @order;
	my $r;
	$r = sub {
		foreach my $release (@_) {
			next if ($release->required != 0);
			next if (grep $_->name eq $release->name, @order);
			if (grep $_ eq $release->name, @path) {
				warn 'recursive loop '.join(' ', @path, $release->name);
				next;
			}
			push @path, $release->name;

			my $config = $self->_configuration->{$release->name} || {};
			my @requires;
			foreach my $r ($release->requires) {
				if (!grep
						$self->_walker->release_for_module($_)->distribution eq $r,
						@{ $config->{exclude_requires} || [] },
						@{ $config->{exclude_build_requires} || [] },
				) {
					push @requires, $self->releases->{$r};
				}
			}
			&$r(@requires);
			push @order, $release;
			pop @path;
		}
	};

	&$r($self->required);

	return @order;
}

sub _read_config_file {
	my $self = shift;

	local $/;
	open( my $fh, '<', $self->config_file );
	my $json_text = <$fh>;
	close ($fh);
	return decode_json($json_text);
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
