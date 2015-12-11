package MetaCPAN::Walker::Policy::Fixed;
use v5.10.0;

use Module::CoreList;

use Moo;
use strictures 2;
use namespace::clean;

# Keep these in namespace
use MooX::Options protect_argv => 0;

our $VERSION = '0.0.1';

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
__END__

=encoding utf-8

=head1 NAME

MetaCPAN::Walker::Policy::Fixed - Static walk policy

=head1 SYNOPSIS

  use MetaCPAN::Walker;
  use MetaCPAN::Walker::Policy::Fixed;
  
  my $policy = MetaCPAN::Walker::Policy::Fixed->new(
      # Configure each phase
      configure => 0,
      build     => 0,
      test      => 0,
      runtime   => 1,
      develop   => 0,
  
      # Configure each relationship
      requires   => 1,
      recommends => 0,
      suggests   => 0,
      conflicts  => 0,
  
      # Configure other dependencies to follow
      core     => 0,
      features => 0,
      seen     => 0,
  
      # Configure the version of perl targetted
      perl => '5.22.0',
  );
  my $walker = MetaCPAN::Walker->new(
      policy => $policy,
  );
  
  $walker->walk_from_modules(qw(namespace::clean Test::Most));

=head1 DESCRIPTION

MetaCPAN::Walker::Policy::Fixed defines a fixed, static policy for walks.
That is, every release is treated exactly alike.

=head1 Attributes

=head2 develop, configure, build, test, runtime

Set true to walk the requirements of each phase. c<runtime> defaults to true;
the rest default to false.

=head2 requires, recommends, suggests, conflicts

Set true to walk the requirements of each relationship. c<requires> defaults to
true; the rest default to false.

head2 core

Set true to walk core modules (those included with perl). Defaults to false.

=head2 features

Set true to walk all optional features. Defaults to false.

=head2 seen

Set true to walk each release every time it appears. Set false to only walk
each release the first time it appears. Defaults to false

=head2 perl

Set the version of perl targetted. Defaults to 5.22.0.

=head1 AUTHOR

Malcolm Studd E<lt>mestudd@gmail.comE<gt>

=head1 COPYRIGHT

Copyright 2015- Recognia Inc.

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
