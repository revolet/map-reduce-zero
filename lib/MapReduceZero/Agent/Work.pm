package MapReduceZero::Agent::Work;
use Moo;
use JSON;
use Try::Tiny;
use ZMQ::LibZMQ3;
use ZMQ::Constants qw(ZMQ_REP ZMQ_REQ ZMQ_POLLIN);

with 'MapReduceZero::Agent';

sub run {
    my ($self) = @_;

    sleep 1;
}

1;

