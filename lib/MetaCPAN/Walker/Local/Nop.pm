package MetaCPAN::Walker::Local::Nop;
use v5.10.0;

use Moo;
use strictures 2;
use namespace::clean;

our $VERSION = '0.01';

with qw(MetaCPAN::Walker::Local);

sub local_version {
	return 'v0';
}

1;
__END__

=encoding utf-8

=head1 NAME

MetaCPAN::Walker::Local::Nop - Don't look for locally available release

=head1 SYNOPSIS

  use MetaCPAN::Walker;
  use MetaCPAN::Walker::Local::Nop;
  
  my $walker = MetaCPAN::Walker->new(
      local => MetaCPAN::Walker::Local::Nop->new(),
  );
  
  $walker->walk_from_modules(qw(namespace::clean Test::Most));

=head1 DESCRIPTION

MetaCPAN::Walker::Local::Nop implements the local role with a no-operation.
It never returns a version.

=head1 AUTHOR

Malcolm Studd E<lt>mestudd@gmail.comE<gt>

=head1 COPYRIGHT

Copyright 2015- Recognia Inc.

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
