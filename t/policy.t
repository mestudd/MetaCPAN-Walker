#!perl -T
use strict;
use Test::More;
use Role::Tiny;


require_ok 'MetaCPAN::Walker::Policy::Fixed';
isa_ok my $policy = MetaCPAN::Walker::Policy::Fixed->new(),
	'MetaCPAN::Walker::Policy::Fixed', 'policy:fixed is policy:fixed';
ok Role::Tiny::does_role($policy, 'MetaCPAN::Walker::Policy'),
	'policy:fixed does MetaCPAN::Walker::Policy';

# TODO: pass correct data and test real functionality once implemented
ok $policy->process_dependency([], undef, undef), 'TODO policy:fixed process top level';
ok !$policy->process_dependency([], 'defined', undef), 'TODO policy:fixed no recursion';
ok $policy->process_release, 'TODO policy:fixed process_dependency';

done_testing;
