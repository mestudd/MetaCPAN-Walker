package MetaCPAN::Walker;

use strict;
use 5.008_005;
use Moo;
use namespace::clean;
our $VERSION = '0.01';

use CHI;
use HTTP::Tiny::Mech;
use MetaCPAN::Client;
use WWW::Mechanize::Cached;

has metacpan => (
	is => 'ro',
	lazy => 1,
	builder => sub {
		MetaCPAN::Client->new(
			ua => HTTP::Tiny::Mech->new(
				mechua => WWW::Mechanize::Cached->new(
					cache => CHI->new(
						driver   => 'File',
						root_dir => '/tmp/metacpan-cache',
					),
				),
			),
		)
	},
);

=cut
sub releases_for_module {
	my $self = shift;
	my $post = pop;
	my $pre = pop;

	foreach my $m (@_) {
#		my $module = $self->metacpan->release($m);# , undef, { join => 'release'} );
		my $file = $self->metacpan->module($m);
		die "Module $_ not found\n" if (!$file);

		my $release = $self->metacpan->release($file->distribution);
		die "Release $_ not found\n" if (!$file);

		my $recurse = &$callback($m, $release);
		if ($recurse) {
			foreach my $d (@{$release->dependency}) {
#				use Data::Dumper; warn Dumper($d);
				$self->releases_for_module($d->{module});
			}
		}
	}
}
=cut

sub releases_for_dependency {
	my $self = shift;

	$self->_releases_for_dependency(0, @_);
}

sub _releases_for_dependency {
	my $self = shift;
	my $level = shift;
	my $post = pop;
	my $pre = pop;

	# FIXME: merge dependencies into releases, so release is only shown once?
	# would need to merge the phases and/or relationships
	foreach my $dep (@_) {
		eval {
			my $file = $self->metacpan->module($dep->{module});
			die "Module $dep->{module} not found\n" if (!$file);

			my $dist = $file->distribution;
			my $release = $self->metacpan->release($dist);
			die "Release $dist not found\n" if (!$file);

			my $recurse = &$pre($dep, $release, $level);
			if ($recurse) {
				$self->_releases_for_dependency($level + 1, @{$release->dependency}, $pre, $post);
			}
			&$post($dep, $release, $level);
		};
		if ($@) {
			warn $@;
		}
	}
}

1;
__END__

=encoding utf-8

=head1 NAME

MetaCPAN::Walker - Walk release dependencies using MetaCPAN

=head1 SYNOPSIS

  use MetaCPAN::Walker;

=head1 DESCRIPTION

MetaCPAN::Walker provides easy ways to walk sets of CPAN releases.

=head1 AUTHOR

Malcolm Studd E<lt>mestudd@gmail.comE<gt>

=head1 COPYRIGHT

Copyright 2015- Recognia Inc.

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

=cut
