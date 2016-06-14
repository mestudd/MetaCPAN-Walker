# NAME

MetaCPAN::Walker - Walk release dependencies using MetaCPAN

# SYNOPSIS

    use MetaCPAN::Walker;
    use MetaCPAN::Walker::Action::PrintOrder;
    use MetaCPAN::Walker::Local::Nop;
    use MetaCPAN::Walker::Policy::Fixed;
    
    my $walker = MetaCPAN::Walker->new(
        action => MetaCPAN::Walker::Action::PrintOrder->new(),
        local  => MetaCPAN::Walker::Local::Nop->new(),
        policy => MetaCPAN::Walker::Policy::Fixed->new_with_options(),
    );
    
    $walker->release_for_module('Test::Most');
    $walker->walk_from_modules(qw(namespace::clean Test::Most));

# DESCRIPTION

MetaCPAN::Walker provides easy ways to walk sets of CPAN releases.

# Attributes

## action

Implementation of [MetaCPAN::Walker::Action](https://metacpan.org/pod/MetaCPAN::Walker::Action) role defining actions to take
for releases and errors.

## local

Implementation of [MetaCPAN::Walker::Local](https://metacpan.org/pod/MetaCPAN::Walker::Local) role to retrieve the locally
installed release version.

## metacpan

[MetaCPAN::Client](https://metacpan.org/pod/MetaCPAN::Client) object for accessing [MetaCPAN](https://metacpan.org/).
The default value provides caching.

## policy

Implementation of [MetaCPAN::Walker::Policy](https://metacpan.org/pod/MetaCPAN::Walker::Policy) role defining which releases
and dependencies to walk.

# Methods

## release\_for\_module($name)

Get the [MetaCPAN::Walker::Release](https://metacpan.org/pod/MetaCPAN::Walker::Release) object that provides the given module.

## walk\_from\_modules(@names)

Walk the dependency trees for all given module names, using the policy for
which parts of the tree to walk, and execute actions.

# AUTHOR

Malcolm Studd &lt;mestudd@gmail.com>

# COPYRIGHT

Copyright 2015- Recognia Inc.

# LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.
