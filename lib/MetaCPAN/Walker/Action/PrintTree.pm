package MetaCPAN::Walker::Action::PrintTree;
use v5.10.0;

use Moo;
#use strictures 2;
use namespace::clean;

our $VERSION = '0.01';

with qw(MetaCPAN::Walker::Action);

sub begin_release {
	my ($self, $path, $release) = @_;

	say "  " x $#$path, $release->name;
}

# Nothing to do at end
sub end_release {}

sub missing_module {
	my ($self, $path, $module) = @_;

	warn "No release for module: $module";
}

# Do nothing?
sub circular_dependency {}

1;
