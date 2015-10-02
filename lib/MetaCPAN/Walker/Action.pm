package MetaCPAN::Walker::Action;
use v5.10.0;

use Moo::Role;
use strictures 2;

our $VERSION = '0.01';

# callbacks for each release going down and back up the tree
requires qw(begin_release end_release missing_module circular_dependency);

1;
