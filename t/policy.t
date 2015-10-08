#!perl -T
use strict;
use Test::More;
use CPAN::Meta;
use MetaCPAN::Walker::Release;
use Role::Tiny;


my $release = MetaCPAN::Walker::Release->new(
	cpan_meta => CPAN::Meta->new({
		name      => 'Release-Name',
		abstract       => 'Abstract',
		author         => ['me'],
		dynamic_config => 0,
		generated_by   => 'hand',
		license        => ['perl_5'],
		'meta-spec'    => { version => '2' },
		release_status => 'stable',
		version        => 'v0.0.1',
		prereqs => {
			runtime => {
				requires   => {
					'runtime::requires' => '0',
					'Module::CoreList' => '0',
				},
				recommends => { 'runtime::recommends' => '0' },
				suggests   => { 'runtime::suggests'   => '0' },
				conflicts  => { 'runtime::conflicts'  => '0' },
			},
			test => {
				requires   => { 'test::requires'   => '0' },
				recommends => { 'test::recommends' => '0' },
				suggests   => { 'test::suggests'   => '0' },
				conflicts  => { 'test::conflicts'  => '0' },
			},
			build => {
				requires   => { 'build::requires'   => '0' },
				recommends => { 'build::recommends' => '0' },
				suggests   => { 'build::suggests'   => '0' },
				conflicts  => { 'build::conflicts'  => '0' },
			},
			configure => {
				requires   => { 'configure::requires'   => '0' },
				recommends => { 'configure::recommends' => '0' },
				suggests   => { 'configure::suggests'   => '0' },
				conflicts  => { 'configure::conflicts'  => '0' },
			},
			develop => {
				requires   => { 'develop::requires'   => '0' },
				recommends => { 'develop::recommends' => '0' },
				suggests   => { 'develop::suggests'   => '0' },
				conflicts  => { 'develop::conflicts'  => '0' },
			},
		},
		optional_features => {
			option => { prereqs => { runtime => {
				requires   => { 'option::requires'   => '0' },
				recommends => { 'option::recommends' => '0' },
			}}},
		}
	}),
);


# Fixed policy

require_ok 'MetaCPAN::Walker::Policy::Fixed';
isa_ok my $policy = MetaCPAN::Walker::Policy::Fixed->new(),
	'MetaCPAN::Walker::Policy::Fixed', 'policy:fixed is policy:fixed';
ok Role::Tiny::does_role($policy, 'MetaCPAN::Walker::Policy'),
	'policy:fixed does MetaCPAN::Walker::Policy';

# Test release
ok $policy->process_release([], $release),
	'policy:fixed release processed';
is_deeply [ sort $release->required_modules ],
	[qw(runtime::requires)],
	'policy:fixed only non-core runtime requires by default';
ok !$policy->process_release([], $release),
	'policy:fixed repeat release not processed';
my $seen = MetaCPAN::Walker::Policy::Fixed->new(seen => 1);
$seen->process_release([], $release);
ok $seen->process_release([], $release),
	'policy:fixed repreat release processed with seen option';


# Test core
my $core = MetaCPAN::Walker::Policy::Fixed->new(core => 1);
$core->process_release([], $release);
is_deeply [ sort $release->required_modules ],
	[qw(Module::CoreList runtime::requires)],
	'policy:fixed core module processed with option';


# Test phases
my $configure = MetaCPAN::Walker::Policy::Fixed->new(configure => 1);
$configure->process_release([], $release);
is_deeply [ sort $release->required_modules ],
	[qw(configure::requires runtime::requires)],
	'policy:fixed phase configure processed with option';
my $build = MetaCPAN::Walker::Policy::Fixed->new(build => 1);
$build->process_release([], $release);
is_deeply [ sort $release->required_modules ],
	[qw(build::requires runtime::requires)],
	'policy:fixed phase build processed with option';
my $test = MetaCPAN::Walker::Policy::Fixed->new(test => 1);
$test->process_release([], $release);
is_deeply [ sort $release->required_modules ],
	[qw(runtime::requires test::requires)],
	'policy:fixed phase test processed with option';
my $develop = MetaCPAN::Walker::Policy::Fixed->new(develop => 1);
$develop->process_release([], $release);
is_deeply [ sort $release->required_modules ],
	[qw(develop::requires runtime::requires)],
	'policy:fixed phase develop processed with option';


# Test relationships
my $recommends = MetaCPAN::Walker::Policy::Fixed->new(recommends => 1);
$recommends->process_release([], $release);
is_deeply [ sort $release->required_modules ],
	[qw(runtime::recommends runtime::requires)],
	'policy:fixed relationship recommends processed with option';
my $suggests = MetaCPAN::Walker::Policy::Fixed->new(suggests => 1);
$suggests->process_release([], $release);
is_deeply [ sort $release->required_modules ],
	[qw(runtime::requires runtime::suggests)],
	'policy:fixed relationship suggests processed with option';
my $conflicts = MetaCPAN::Walker::Policy::Fixed->new(conflicts => 1);
$conflicts->process_release([], $release);
is_deeply [ sort $release->required_modules ],
	[qw(runtime::conflicts runtime::requires)],
	'policy:fixed relationship conflicts processed with option';


# Test features
my $feature = MetaCPAN::Walker::Policy::Fixed->new(features => 1);
$feature->process_release([], $release);
is_deeply [ sort $release->required_modules ],
	[qw(option::requires runtime::requires)],
	'policy:fixed features processed with option';

my $mixed = MetaCPAN::Walker::Policy::Fixed->new(
	features   => 1,
	recommends => 1,
	suggests   => 1,
	test       => 1,
);
$mixed->process_release([], $release);
is_deeply [ sort $release->required_modules ],
	[qw(option::recommends option::requires runtime::recommends runtime::requires
		runtime::suggests test::recommends test::requires test::suggests)],
	'policy:fixed mixed options work together';


done_testing;
