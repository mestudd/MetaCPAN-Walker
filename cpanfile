requires 'perl', '5.10.0';

requires 'CHI';
requires 'Config';
requires 'CPAN::Meta';
requires 'HTTP::Tiny::Mech';
requires 'MetaCPAN::Client';
requires 'Module::CoreList';
requires 'Moo';
requires 'Moo::Role';
requires 'MooX::Options';
requires 'namespace::clean';
requires 'strictures', '2';
requires 'version';
requires 'WWW::Mechanize::Cached';

on test => sub {
    requires 'Test::More', '0.96';
    requires 'CPAN::Meta';
    requires 'Role::Tiny';
    requires 'Test::Output';
};
