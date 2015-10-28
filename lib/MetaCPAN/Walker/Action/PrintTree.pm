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
__END__

=encoding utf-8

=head1 NAME

MetaCPAN::Walker::Action::PrintTree - Print release dependency tree

=head1 SYNOPSIS

  use MetaCPAN::Walker;
  use MetaCPAN::Walker::Action::PrintTree;
  
  my $walker = MetaCPAN::Walker->new(
      action => MetaCPAN::Walker::Action::PrintTree->new(),
  );
  
  $walker->walk_from_modules(qw(namespace::clean Test::Most));

=head1 DESCRIPTION

MetaCPAN::Walker::Action::PrintTree prints the release name in the
C<begin_release> method, indented by the path length.

=head1 AUTHOR

Malcolm Studd E<lt>mestudd@gmail.comE<gt>

=head1 COPYRIGHT

Copyright 2015- Recognia Inc.

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
