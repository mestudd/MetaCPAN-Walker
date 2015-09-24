#!/usr/bin/perl 
use strict;
use warnings;
use v5.10.0;

use Data::Dumper;
use MetaCPAN::Walker;
use Module::CoreList;

my $walk = MetaCPAN::Walker->new();

=cut
#$walk->releases_for_module(qw(DBI DBD::Pg Test::Builder), sub {
#$walk->releases_for_module('DBI', sub {
for (qw(DBI DBD::Pg Test::Builder)) {
	$walk->releases_for_module($_, sub {
		my $module = shift;
		my $release = shift;

		say sprintf '%s is from %s, version %s (status %s)', $module, $release->distribution, $release->version, $release->status;
#		say Dumper($release->name);
	});
}
=cut

my $specdir = '/home/mstudd/dev/rpmbuild.6/SPECS';
my %seen = ();
my @deps = map +{
	module => $_,
	phase  => 'runtime',
	relationship => 'requires',
}, qw(DBI DBD::Pg Moose);
my @order = ();
my %built = ();

print "Truncated dependency tree\n";
$walk->releases_for_dependency(@deps,
	sub {
		my ($dep, $release, $level) = @_;

		my $distribution = $release->distribution;
		my $have = 'MISSING';

		return 0 if (Module::CoreList::is_core($dep->{module})
				|| $seen{$distribution}
				|| $dep->{relationship} eq 'conflicts'
				|| $dep->{phase} eq 'develop');

		if (-e "$specdir/perl-$distribution.spec") {
			$have = `grep -i '^version:' "$specdir/perl-$distribution.spec"`;
			$have =~ s/^version:\W*//i;
			$have =~ s/\W*$//;
		}
		say sprintf '%s\\ %s is %s; from %s version %s (status %s) (have %s)',
			'|   ' x $level, $dep->{module}, $dep->{relationship},
			$distribution, $release->version, $release->status, $have;

		$seen{$distribution} = 1;
		return 1;
	},
	sub {
		my ($dep, $release, $level) = @_;

		my $distribution = $release->distribution;
		if (!exists($built{$distribution})) {
			$built{$distribution} = 1;
			push @order, $distribution;
		}
	},
);

print "\n\nBuild order\n";
print join("\n", @order);
print "\n\n";


####
# To build tree, would need parent
#
