package MetaCPAN::Walker::Policy;
use v5.10.0;

use Moo::Role;
use strictures 2;

our $VERSION = '0.0.2';

requires qw(process_release release_version);

1;
__END__

=encoding utf-8

=head1 NAME

MetaCPAN::Walker::Policy - Role defining methods for walking policy

=head1 SYNOPSIS

  package My::Policy;
  use Moo;
  use strictures 2;
  
  with qw(MetaCPAN::Walker::Policy);
  
  sub process_release {
      my ($self, $path, $release) = @_;
  }

  use MetaCPAN::Walker;
  use My::Policy;
  
  my $walker = MetaCPAN::Walker->new(
      policy => My::Policy->new(),
  );
  
  $walker->walk_from_modules(qw(namespace::clean Test::Most));

=head1 DESCRIPTION

MetaCPAN::Walker::Policy defines methods for determining release walking
policy.

=head1 Methods

=head2 process_release(\@path, $release)

Implement method called to provide policy for a release. The method must
populate C<$release-E<gt>requirements> and return true or false to indicate
that the walk should continue processing the release. If the release appears
multiple times in the walk, this method will be called once for each
appearance.

The C<$release> parameter contains the L<MetaCPAN::Walker::Release>
object defining the release.

=head2 release_version($release)

Implement method called to determine the desired version for a release. The
method must return the desired version.

The C<$release> parameter contains the L<MetaCPAN::Walker::Release> object
defining the latest release.

=head1 AUTHOR

Malcolm Studd E<lt>mestudd@gmail.comE<gt>

=head1 COPYRIGHT

Copyright 2015- Recognia Inc.

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
