package MetaCPAN::Walker::Local::Require;
use v5.10.0;

use Config;

use Moo;
use strictures 2;
use namespace::clean;

our $VERSION = '0.01';

my $VERSION_CHECK = 'eval "require $ARGV[0]" and print $ARGV[0]->VERSION';

with qw(MetaCPAN::Walker::Local);

has perl => (
	is      => 'rw',
	lazy    => 1,
	builder => 1,
);

has versions => (
	is      => 'ro',
	lazy    => 1,
	default => sub { {} },
);

sub _build_perl {
	# Taken from perlvar
	my $this_perl = $Config{perlpath};
	if ($^O ne 'VMS') {
		$this_perl .= $Config{_exe}
			unless $this_perl =~ m/$Config{_exe}$/i;
	}

	return $this_perl;
}

sub local_version {
	my ($self, $release) = @_;

	if (!exists $self->versions->{$release->name}) {
		my $version = undef;
		my $use_perl = $self->perl;

		# Heuristic: take first set version from provided modules.
		my @provides;

		# Spec says provides is a map, but real data can be array?
		if (ref($release->provides) eq 'HASH') {
			@provides = sort keys %{$release->provides};
		} elsif (ref($release->provides) eq 'ARRAY') {
			@provides = @{$release->provides};
		}
		foreach my $module (@provides) {
			last if ($version = `$use_perl -le '$VERSION_CHECK' $module`);
		}
		$version = 'v0' unless (defined $version && $version ne '');
		chomp $version;
		$self->versions->{$release->name} = $version;
	}

	return $self->versions->{$release->name};
}

1;
__END__

=encoding utf-8

=head1 NAME

MetaCPAN::Walker::Local::Require - Check local release via local perl

=head1 SYNOPSIS

  use MetaCPAN::Walker;
  use MetaCPAN::Walker::Local::Nop;
  
  my $walker = MetaCPAN::Walker->new(
      local => MetaCPAN::Walker::Local::Nop->new(),
  );
  
  $walker->walk_from_modules(qw(namespace::clean Test::Most));

=head1 DESCRIPTION

MetaCPAN::Walker::Local::Nop implements the local role with looking at the
local perl install.

=head1 AUTHOR

Malcolm Studd E<lt>mestudd@gmail.comE<gt>

=head1 COPYRIGHT

Copyright 2015- Recognia Inc.

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
