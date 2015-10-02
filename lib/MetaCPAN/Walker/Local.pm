package MetaCPAN::Walker::Local;
use v5.10.0;

use Moo::Role;
use strictures 2;

our $VERSION = '0.01';

# returns the installed version number for a release
requires qw(installed_release_version);

1;
