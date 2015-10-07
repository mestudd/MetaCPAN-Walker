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
		# Heuristic: take first set version from provided modules.
		foreach my $module (sort keys %{$release->release->provides}) {
			my $use_perl = $self->perl;
			last if ($version = `$use_perl -le '$VERSION_CHECK' $module`);
		}
		$version = 'v0' unless (defined $version && $version ne '');
		$self->versions->{$release->name} = $version;
	}

	return $self->versions->{$release->name};
}

1;
