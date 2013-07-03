package MapReduceZero;
use Moo;
use Exporter qw(import);
use Storable qw(nfreeze thaw);
use Sys::Hostname qw(hostname);
use Try::Tiny;
use ZMQ::LibZMQ3;
use ZMQ::Constants qw(ZMQ_REP ZMQ_REQ ZMQ_POLLIN);

use constant DEBUG => $ENV{MRZ_DEBUG} // 1;

our @EXPORT = qw( debug DEBUG );

sub debug {
    if (DEBUG) {
        my ($format, @args) = @_;
        printf STDERR $$.' '.$format."\n", @args;
    }
}

1;

