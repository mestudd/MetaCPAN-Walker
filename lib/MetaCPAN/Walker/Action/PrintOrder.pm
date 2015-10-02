package MetaCPAN::Walker::Action::PrintOrder;
use v5.10.0;

use Moo;
use strictures 2;
use namespace::clean;

our $VERSION = '0.01';

with qw(MetaCPAN::Walker::Action);

has seen => (
	is      => 'ro',
	lazy    => 1,
	default => sub { {} },
);


# Nothing to do at begin
sub begin_release {}

sub end_release {
	my ($self, $path, $release) = @_;

	say $release->name if (!$self->seen->{$release->name});
	$self->seen->{$release->name} = 1;
}

# Do nothing?
sub missing_module {}

# Do nothing?
sub circular_dependency {}

1;
