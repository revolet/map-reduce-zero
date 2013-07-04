package MapReduceZero::Agent::Vent;
use Moo;
use ZMQ::LibZMQ3;
use ZMQ::Constants qw(ZMQ_PUSH ZMQ_PULL);

with 'MapReduceZero::Agent';

sub run {
    my ($self) = @_;
    
    my $ctxt = zmq_init();
    
    my $client = zmq_socket($ctxt, ZMQ_PULL);
    zmq_bind($client, 'tcp://127.0.0.1:9990');
    
    my $worker = zmq_socket($ctxt, ZMQ_PUSH);
    zmq_connect($worker, 'tcp://127.0.0.1:9991');
    
    while (1) {
        my $msg = zmq_recvmsg($client);

        my $data = zmq_msg_data($msg);
        
        print STDERR "Vent: Received from Client and sending to Worker: $data\n";
       
        zmq_sendmsg($worker, $data);
    }
}

1;

