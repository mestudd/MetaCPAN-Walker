package MetaCPAN::Walker;

use strict;
use 5.10.0;
use CHI;
use CPAN::Meta;
use HTTP::Tiny::Mech;
use MetaCPAN::Client;
use MetaCPAN::Walker::Release;
use WWW::Mechanize::Cached;

use Moo;
use namespace::clean;
our $VERSION = '0.01';


has action => (
	is => 'ro',
#	coerce => &_coerce_object,
	builder => 1,
	handles => 'MetaCPAN::Walker::Action',
);

has local => (
	is => 'ro',
#	coerce => &_coerce_object,
	builder => 1,
	handles => 'MetaCPAN::Walker::Local',
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
	handles => 'MetaCPAN::Walker::Policy',
);

has releases => (
	is => 'ro',
	default => sub { {}; },
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

# get release with metacpan client, create walker release object, populate
# _module_release with provides
sub _release_for_distribution {
	my ($self, $name) = @_;

	if (!exists $self->releases->{$name}) {
		my $r = $self->metacpan->release($name);
		return undef unless ($r);

		my $release = $self->releases->{$name} = MetaCPAN::Walker::Release->new(
			cpan_meta        => CPAN::Meta->new($r->metadata),
			download_url     => $r->download_url,
			version_latest   => version->parse($r->version),
			version_local    => version->parse($self->local_version($r)),
			version_required => version->parse('v0.0.0'),
		);

		map $self->_module_release->{$_} = $release, @{ $r->provides // [] };
	}
	return $self->releases->{$name};
}

sub release_for_module {
	my ($self, $module) = @_;

	if (!exists $self->_module_release->{$module}) {
		eval {
			my $file = $self->metacpan->module($module);
			return undef unless ($file);

			my $name = $file->distribution;
			if ($name =~ s/::/-/g) { # namespace-clean 0.26; others?
				warn $name, ' has package instead of release name';
			}
			my $release = $self->_release_for_distribution($file->distribution);

			# FIXME: is this needed, or should assume _release_for_distribution
			# does it?
			$self->_module_release->{$module} = $release
				if ($release);
		};
		if ($@) {
			warn $@;
		}
	}
	return $self->_module_release->{$module};
}

sub _walk_modules {
	my $self = shift;
	my $path = shift;
	my @dependencies = @_;

	foreach my $dep (@dependencies) {
		# Retrieve release and check if we should process it
		my $release = $self->release_for_module($dep);
		if (!$release) {
			$self->missing_module($dep);
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
		$self->_walk_modules($path, sort $release->required_modules);
# TODO: can update minimum version here?
		$self->end_release($path, $release);
		pop @$path;
	}
}

sub walk_from_modules {
	my $self = shift;
	my @dependencies = @_;

	$self->_walk_modules([], @dependencies);
}

1;
__END__

=encoding utf-8

=head1 NAME

MetaCPAN::Walker - Walk release dependencies using MetaCPAN

=head1 SYNOPSIS

  use MetaCPAN::Walker;
  use MetaCPAN::Walker::Action::PrintOrder;
  use MetaCPAN::Walker::Local::Nop;
  use MetaCPAN::Walker::Policy::Fixed;
  
  my $walker = MetaCPAN::Walker->new(
      action => MetaCPAN::Walker::Action::PrintOrder->new(),
      local  => MetaCPAN::Walker::Local::Nop->new(),
      policy => MetaCPAN::Walker::Policy::Fixed->new_with_options(),
  );
  
  $walker->release_for_module('Test::Most');
  $walker->walk_from_modules(qw(namespace::clean Test::Most));

=head1 DESCRIPTION

MetaCPAN::Walker provides easy ways to walk sets of CPAN releases.

=head1 Attributes

=head2 action

Implementation of L<MetaCPAN::Walker::Action> role defining actions to take
for releases and errors.

=head2 local

Implementation of L<MetaCPAN::Walker::Local> role to retrieve the locally
installed release version.

=head2 metacpan

L<MetaCPAN::Client> object for accessing L<MetaCPAN|https://metacpan.org/>.
The default value provides caching.

=head2 policy

Implementation of L<MetaCPAN::Walker::Policy> role defining which releases
and dependencies to walk.

=head1 Methods

=head2 release_for_module($name)

Get the L<MetaCPAN::Walker::Release> object that provides the given module.

=head2 release_for_module(@names)

Walk the dependency trees for all given module names, using the policy for
which parts of the tree to walk, and execute actions.

=head1 AUTHOR

Malcolm Studd E<lt>mestudd@gmail.comE<gt>

=head1 COPYRIGHT

Copyright 2015- Recognia Inc.

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
