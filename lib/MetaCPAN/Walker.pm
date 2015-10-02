package MetaCPAN::Walker;

use strict;
use 5.008_005;
use Moo;
use namespace::clean;
our $VERSION = '0.01';

use CHI;
use HTTP::Tiny::Mech;
use MetaCPAN::Client;
use WWW::Mechanize::Cached;

has action => (
	is => 'ro',
#	coerce => &_coerce_object,
	builder => 1,
	handles => [ qw(begin_release end_release) ],
);

has local => (
	is => 'ro',
#	coerce => &_coerce_object,
	builder => 1,
	handles => [ qw(installed_release_version) ],
);

has metacpan => (
	is => 'ro',
	lazy => 1,
	builder => sub {
		MetaCPAN::Client->new(
			ua => HTTP::Tiny::Mech->new(
				mechua => WWW::Mechanize::Cached->new(
					cache => CHI->new(
						driver   => 'File',
						root_dir => '/tmp/metacpan-cache',
					),
				),
			),
		)
	},
);

has _module_release => (
	is => 'ro',
	default => sub { {}; },
);

has policy => (
	is => 'ro',
#	coerce => &_coerce_object,
	builder => 1,
	handles => [ qw(process_dependency process_release) ],
);

sub _build_action {
	require 'MetaCPAN::Walker::Action::PrintTree';
	return MetaCPAN::Walker::Action::PrintTree->new();
}

sub _build_local {
	require MetaCPAN::Walker::Local::Require;
	return MetaCPAN::Walker::Local::Require->new();
}

sub _build_policy {
	require 'MetaCPAN::Walker::Policy::Fixed';
	return MetaCPAN::Walker::Policy::Fixed->new();
}

sub _coerce_object {
	ref($_[0]) eq 'SCALAR' && $_[0] =~ /^[\w:]+$/ and require $_[0] and $_[0]->new();
}

=cut
sub releases_for_module {
	my $self = shift;
	my $post = pop;
	my $pre = pop;

	foreach my $m (@_) {
#		my $module = $self->metacpan->release($m);# , undef, { join => 'release'} );
		my $file = $self->metacpan->module($m);
		die "Module $_ not found\n" if (!$file);

		my $release = $self->metacpan->release($file->distribution);
		die "Release $_ not found\n" if (!$file);

		my $recurse = &$callback($m, $release);
		if ($recurse) {
			foreach my $d (@{$release->dependency}) {
#				use Data::Dumper; warn Dumper($d);
				$self->releases_for_module($d->{module});
			}
		}
	}
}
=cut

sub release_for_module {
	my ($self, $module) = @_;

	if (!exists $self->_module_release->{$module}) {
		my $file = $self->metacpan->module($module);

		$self->_module_release->{$module} = $self->metacpan->release($file->distribution)
			if ($file);
	}
	return $self->_module_release->{$module};
}

sub walk_dependencies {
	my $self = shift;

	$self->_walk_dependencies([], undef, @_);
}

sub _walk_dependencies {
	my $self = shift;
	my $path = shift;
	my $release = shift;

	# FIXME: merge dependencies into releases, so release is only shown once?
	# would need to merge the phases and/or relationships
	foreach my $dep (@_) {
		if (!$self->process_dependency($path, $release, $dep)) {
			next;
		}

		# Retrieve release and check if we should process it
		my $release = $self->release_for_module($dep->{module});
		if (!$release) {
			$self->missing_module($dep->{module});
			next;
		}
		next unless ($self->process_release($path, $release));

		# Check for circular dependencies
		if (grep $_ eq $release->name, @$path) {
			$self->circular_dependency($path, $release);
			next;
		}

		# Process release and its dependencies
		push @$path, $release->name;
		$self->begin_release($path, $release);
		$self->_walk_dependencies($path, @{$release->dependency});
		$self->end_release($path, $release);
		pop @$path;
	}
}

sub walk_from_modules {
	my $self = shift;

	my @dependencies = map +{
		    module => $_,
			phase  => 'runtime',
			relationship => 'requires',
		}, @_;
	$self->walk_dependencies(@dependencies);
}

1;
__END__

=encoding utf-8

=head1 NAME

MetaCPAN::Walker - Walk release dependencies using MetaCPAN

=head1 SYNOPSIS

  use MetaCPAN::Walker;

=head1 DESCRIPTION

MetaCPAN::Walker provides easy ways to walk sets of CPAN releases.

=head1 AUTHOR

Malcolm Studd E<lt>mestudd@gmail.comE<gt>

=head1 COPYRIGHT

Copyright 2015- Recognia Inc.

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

=cut
