package MetaCPAN::Walker::Policy;
use v5.10.0;

use Moo::Role;
use strictures 2;

our $VERSION = '0.01';

# return true value to indicate release/dependency should be processed
requires qw(process_dependency process_release);

1;
