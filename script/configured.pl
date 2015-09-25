#!/usr/bin/env perl 
use strict;
use warnings;
use utf8;
use v5.10.0;

use Data::Dumper;
use MetaCPAN::Walker::Configured;

my $walk = MetaCPAN::Walker::Configured->new();

my $SPECDIR = '/home/mstudd/dev/rpmbuild.6/SPECS';

my @deps = split /\s+/, `ack -h 'perl\\((.*)\\)' /home/mstudd/dev/rpmbuild.trunk/SPECS/deps-* --output '\$1' | sort | uniq`;

$walk->build_from_initial_modules(@deps);
#$walk->build_from_initial_modules(qw(DBI DBD::Pg Moose));

sub check_spec_version {
	my $distribution = shift;

	my $have = 'MISSING';
	if (-e "$SPECDIR/perl-$distribution.spec") {
		$have = `grep -i '^version:' "$SPECDIR/perl-$distribution.spec"`;
		$have =~ s/^version:\W*//i;
		$have =~ s/\W*$//;
	}
	return $have;
}

say 'Suggested Releases';
foreach ($walk->suggested) {
	say sprintf '%s: want %s (have %s) wanted by %s',
		$_->name, $_->cpan_meta->version, check_spec_version($_->name),
		join(' ', $_->wanted_by);
}

say '';
say 'Recommended Releases';
foreach ($walk->recommended) {
	say sprintf '%s: want %s (have %s) wanted by %s',
		$_->name, $_->cpan_meta->version, check_spec_version($_->name),
		join(' ', $_->wanted_by);
}

say '';
say 'Required Releases';
my @have;
foreach ($walk->required) {
	# Check for RPM spec
	my $distribution = $_->name;
	my $have = check_spec_version($distribution);
	if ($have eq $_->cpan_meta->version) {
		push @have, $distribution;
		next;
	}

	say sprintf '%s: want %s (have %s)', $distribution, $_->cpan_meta->version, $have;
}

say 'Already have';
say join(' ', @have);

say '';
say 'Build order';
my @order = $walk->ordered;
say join(' ', map $_->name, @order);
