package MetaCPAN::Walker::Action::PrintOrder;
use v5.10.0;

use Moo;
use strictures 2;
use namespace::clean;

our $VERSION = '0.0.2';

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
__END__

=encoding utf-8

=head1 NAME

MetaCPAN::Walker::Action::PrintOrder - Print release build order

=head1 SYNOPSIS

  use MetaCPAN::Walker;
  use MetaCPAN::Walker::Action::PrintOrder;
  
  my $walker = MetaCPAN::Walker->new(
      action => MetaCPAN::Walker::Action::PrintOrder->new(),
  );
  
  $walker->walk_from_modules(qw(namespace::clean Test::Most));

=head1 DESCRIPTION

MetaCPAN::Walker::Action::PrintOrder prints the release name in the
C<end_release> method, thus showing required release build order.

=head1 AUTHOR

Malcolm Studd E<lt>mestudd@gmail.comE<gt>

=head1 COPYRIGHT

Copyright 2015- Recognia Inc.

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
