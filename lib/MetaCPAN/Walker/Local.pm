package MetaCPAN::Walker::Local;
use v5.10.0;

use Moo::Role;
use strictures 2;

our $VERSION = '0.01';

requires qw(local_version);

1;
__END__

=encoding utf-8

=head1 NAME

MetaCPAN::Walker::Local - Role defining methods for local releases

=head1 SYNOPSIS

  package My::Local;
  use Moo;
  use strictures 2;
  
  with qw(MetaCPAN::Walker::Local);
  
  sub local_version {
      my ($self, $release) = @_;
  }

  use MetaCPAN::Walker;
  use My::Local;
  
  my $walker = MetaCPAN::Walker->new(
      local => My::Local->new(),
  );
  
  $walker->walk_from_modules(qw(namespace::clean Test::Most));

=head1 DESCRIPTION

MetaCPAN::Walker::Local defines methods for determining local release
information.

=head1 Methods

=head2 local_version($release)

Implement method called to detect local version.

The C<$release> parameter contains the L<MetaCPAN::Client::Release>
object defining the release.

FIXME: Maybe this should be MetaCPAN::Walker::Release object for consistency?

=head1 AUTHOR

Malcolm Studd E<lt>mestudd@gmail.comE<gt>

=head1 COPYRIGHT

Copyright 2015- Recognia Inc.

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
