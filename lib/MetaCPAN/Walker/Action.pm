package MetaCPAN::Walker::Action;
use v5.10.0;

use Moo::Role;
use strictures 2;

our $VERSION = '0.0.1';

requires qw(begin_release end_release missing_module circular_dependency);

1;
__END__

=encoding utf-8

=head1 NAME

MetaCPAN::Walker::Action - Role defining actions while walking releases

=head1 SYNOPSIS

  package My::Action;
  use Moo;
  use strictures 2;
  
  with qw(MetaCPAN::Walker::Action);
  
  sub begin_release {
      my ($self, $path, $release) = @_;
  }
  
  sub end_release {
      my ($self, $path, $release) = @_;
  }
  
  sub missing_module {
      my ($self, $name) = @_;
  }
  
  sub circular_dependency {
      my ($self, $path, $release) = @_;
  }

  use MetaCPAN::Walker;
  use My::Action;
  
  my $walker = MetaCPAN::Walker->new(
      action => My::Action->new(),
  );
  
  $walker->walk_from_modules(qw(namespace::clean Test::Most));

=head1 DESCRIPTION

MetaCPAN::Walker::Action defines actions while walking releases.

=head1 Methods

=head2 begin_release(\@path, $release)

Implement method called when descending the release tree. The c<\@path> parameter
contains the names of the releases up to the root of the tree. The C<$release>
parameter contains the L<MetaCPAN::Walker::Release> object defining the release.

When this action is called, the policy has been applied, so the release is
being processed and its dependencies have been populated.

=head2 end_release(\@path, $release)

Implement method called when ascending the release tree. The c<\@path> parameter
contains the names of the releases up to the root of the tree. The C<$release>
parameter contains the L<MetaCPAN::Walker::Release> object defining the release.

When this action is called, the policy has been applied, so the release is
being processed and its dependencies have completed processing.

=head2 missing_module($name)

Implement method called when a module cannot be found. Purely advisory.

FIXME: Allow this method to return a release object? Eg. to provide local
releases?

=head2 circular_dependency(\@path, $release)

Implement method called when a circular dependency is found in the release tree.
Purely advisory.

The c<\@path> parameter contains the names of the releases up to the root of
the tree. The C<$release> parameter contains the L<MetaCPAN::Walker::Release>
object defining the release depending on itself.

When this action is called, the policy has been applied. No actions have yet
been taken on the release or its dependencies.

=head1 AUTHOR

Malcolm Studd E<lt>mestudd@gmail.comE<gt>

=head1 COPYRIGHT

Copyright 2015- Recognia Inc.

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
