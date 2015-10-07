package MetaCPAN::Walker::Local::Nop;
use v5.10.0;

use Moo;
use strictures 2;
use namespace::clean;

our $VERSION = '0.01';

with qw(MetaCPAN::Walker::Local);

sub local_version {
	return 'v0';
}

1;
