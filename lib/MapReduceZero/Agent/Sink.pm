package MapReduceZero::Agent::Sink;
use Moo;
use ZMQ::LibZMQ3;
use ZMQ::Constants qw(ZMQ_PUSH ZMQ_PULL);

with 'MapReduceZero::Agent';

sub run {
    my ($self) = @_;

    my $ctxt = zmq_init();
    
    my $worker = zmq_socket($ctxt, ZMQ_PULL);
    zmq_bind($worker, 'tcp://127.0.0.1:9992');
    
    my $client = zmq_socket($ctxt, ZMQ_PUSH);
    zmq_bind($client, 'tcp://127.0.0.1:9993');
    
    while (1) {
        my $msg = zmq_recvmsg($worker);

        my $data = zmq_msg_data($msg);
        
        print STDERR "Sink: Received from Worker and sending to Client: $data\n";

        zmq_sendmsg($client, $data);
    }
}

1;

