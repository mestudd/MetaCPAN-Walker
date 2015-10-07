#!perl -T
use strict;
use Test::More;
use CPAN::Meta;
use MetaCPAN::Walker::Release;
use Role::Tiny;
use version;


my $at_latest = MetaCPAN::Walker::Release->new(
	name      => 'Release-Name',
	required  => 0,
	release   => undef,
	version_latest   => version->parse('v1.10'),
	version_local    => version->parse('v1.10'),
	version_required => version->parse('v1.3'),
);

my $update_available = MetaCPAN::Walker::Release->new(
	name      => 'Release-Name',
	required  => 0,
	release   => undef,
	version_latest => version->parse('v1.10'),
	version_local  => version->parse('v1.2'),
);

my $update_required = MetaCPAN::Walker::Release->new(
	name      => 'Release-Name',
	required  => 0,
	release   => undef,
	version_latest   => version->parse('v1.10'),
	version_local    => version->parse('v1.2'),
	version_required => version->parse('v1.3'),
);

# use "require $module" as heuristic
require_ok 'MetaCPAN::Walker::Local::Require';
isa_ok my $local = MetaCPAN::Walker::Local::Require->new(),
	'MetaCPAN::Walker::Local::Require', 'local:fixed is local:fixed';

ok !$at_latest->update_required, 'no update required at latest';
ok !$at_latest->update_available, 'no update available at latest';

ok !$update_available->update_required, 'no update required when local >= required';
ok $update_available->update_available, 'update available when local < latest';

ok $update_required->update_required, 'update required when local < required';
ok $update_required->update_available, 'update available when required';

done_testing;
