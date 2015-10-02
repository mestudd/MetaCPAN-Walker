package MetaCPAN::Walker::Policy::Fixed;
use v5.10.0;

use Moo;
use strictures 2;
use namespace::clean;

our $VERSION = '0.01';

with qw(MetaCPAN::Walker::Policy);

sub process_dependency {
	my ($self, $path, $release, $dependency) = @_;

	return !defined $release;
}

sub process_release {
	my ($self, $path, $release) = @_;

	return 1;
}

1;
