#!perl -T
use strict;
use Test::More;
use MetaCPAN::Walker::Release;
use Role::Tiny;


my $release = MetaCPAN::Walker::Release->new(
	name      => 'Release-Name',
	required  => 0,
	release   => undef,
);

sub dep {
	my ($module, $phase, $relationship) = @_;
	return {module => $module, phase => $phase, relationship => $relationship};
}


# Fixed policy

require_ok 'MetaCPAN::Walker::Policy::Fixed';
isa_ok my $policy = MetaCPAN::Walker::Policy::Fixed->new(),
	'MetaCPAN::Walker::Policy::Fixed', 'policy:fixed is policy:fixed';
ok Role::Tiny::does_role($policy, 'MetaCPAN::Walker::Policy'),
	'policy:fixed does MetaCPAN::Walker::Policy';

# Test phases
ok $policy->process_dependency(
	[], $release, dep(qw(Dep::Module runtime requires))
), 'policy:fixed runtime requires processed by default';
ok !$policy->process_dependency(
	[], $release, dep(qw(Dep::Module configure requires))
), 'policy:fixed phase configure not processed by default';
ok !$policy->process_dependency(
	[], $release, dep(qw(Dep::Module build requires))
), 'policy:fixed phase build not processed by default';
ok !$policy->process_dependency(
	[], $release, dep(qw(Dep::Module test requires))
), 'policy:fixed phase test not processed by default';
ok !$policy->process_dependency(
	[], $release, dep(qw(Dep::Module develop requires))
), 'policy:fixed phase develop not processed by default';

my $configure = MetaCPAN::Walker::Policy::Fixed->new(configure => 1);
ok $configure->process_dependency(
	[], $release, dep(qw(Dep::Module configure requires))
), 'policy:fixed phase configure processed with option';
my $build = MetaCPAN::Walker::Policy::Fixed->new(build => 1);
ok $build->process_dependency(
	[], $release, dep(qw(Dep::Module build requires))
), 'policy:fixed phase build processed with option';
my $test = MetaCPAN::Walker::Policy::Fixed->new(test => 1);
ok $test->process_dependency(
	[], $release, dep(qw(Dep::Module test requires))
), 'policy:fixed phase test processed with option';
my $develop = MetaCPAN::Walker::Policy::Fixed->new(develop => 1);
ok $develop->process_dependency(
	[], $release, dep(qw(Dep::Module develop requires))
), 'policy:fixed phase develop processed with option';


# Test relationships
ok !$policy->process_dependency(
	[], $release, dep(qw(Dep::Module runtime recommends))
), 'policy:fixed relationship recommends not processed by default';
ok !$policy->process_dependency(
	[], $release, dep(qw(Dep::Module runtime suggests))
), 'policy:fixed relationship suggests not processed by default';
ok !$policy->process_dependency(
	[], $release, dep(qw(Dep::Module runtime conflicts))
), 'policy:fixed relationship conflicts not processed by default';

my $recommends = MetaCPAN::Walker::Policy::Fixed->new(recommends => 1);
ok $recommends->process_dependency(
	[], $release, dep(qw(Dep::Module runtime recommends))
), 'policy:fixed relationship recommends processed with option';
my $suggests = MetaCPAN::Walker::Policy::Fixed->new(suggests => 1);
ok $suggests->process_dependency(
	[], $release, dep(qw(Dep::Module runtime suggests))
), 'policy:fixed relationship suggests processed with option';
my $conflicts = MetaCPAN::Walker::Policy::Fixed->new(conflicts => 1);
ok $conflicts->process_dependency(
	[], $release, dep(qw(Dep::Module runtime conflicts))
), 'policy:fixed relationship conflicts processed with option';

# Test core
ok !$policy->process_dependency(
	[], $release, dep(qw(Module::CoreList runtime requires))
), 'policy:fixed core module not processed by default';
my $core = MetaCPAN::Walker::Policy::Fixed->new(core => 1);
ok $core->process_dependency(
	[], $release, dep(qw(Module::CoreList runtime requires))
), 'policy:fixed core module processed with option';


# Test release
ok $policy->process_release([], $release),
	'policy:fixed release processed';
ok !$policy->process_release([], $release),
	'policy:fixed repeat release not processed';
my $seen = MetaCPAN::Walker::Policy::Fixed->new(seen => 1);
$seen->process_release([], $release);
ok $seen->process_release([], $release),
	'policy:fixed repreat release processed with seen option';

done_testing;
