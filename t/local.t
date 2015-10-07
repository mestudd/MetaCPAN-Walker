#!perl -T
use strict;
use Test::More;
use MetaCPAN::Client::Release;
use MetaCPAN::Walker::Release;
use Role::Tiny;


my $release1 = MetaCPAN::Walker::Release->new(
	name      => 'Release-Name',
	required  => 0,
	release   => MetaCPAN::Client::Release->new({ data => {
		provides => {
			'Release::Name' => { file => 'lib/Release/Name.pm' },
		},
	}}),
);
my $release2 = MetaCPAN::Walker::Release->new(
	name      => 'Role-Tiny',
	required  => 2,
	release   => MetaCPAN::Client::Release->new({ data => {
		provides => {
			'Role::Tiny' => { file => 'lib/Role/Tiny.pm' },
			'Role::Tiny::With' => { file => 'lib/Role/Tiny/With.pm' },
		},
	}}),
);

# use "require $module" as heuristic
require_ok 'MetaCPAN::Walker::Local::Require';
isa_ok my $local = MetaCPAN::Walker::Local::Require->new(),
	'MetaCPAN::Walker::Local::Require', 'local:fixed is local:fixed';
ok Role::Tiny::does_role($local, 'MetaCPAN::Walker::Local'),
	'local:fixed does MetaCPAN::Walker::Local';

local $ENV{PATH} = '';
is $local->local_version($release1),
	'v0', 'local:require does not find non-existent release';
like $local->local_version($release2),
	qr/^\d+\.\d+/, 'local:require does find real release';


# don't even try to check for local version
require_ok 'MetaCPAN::Walker::Local::Nop';
isa_ok $local = MetaCPAN::Walker::Local::Nop->new(),
	'MetaCPAN::Walker::Local::Nop', 'local:nop is local:fixed';
ok Role::Tiny::does_role($local, 'MetaCPAN::Walker::Local'),
	'local:nop does MetaCPAN::Walker::Local';

is $local->local_version($release1),
	'v0', 'local:nop does not find non-existent release';
is $local->local_version($release2),
	'v0', 'local:require does not find real release';

done_testing;
