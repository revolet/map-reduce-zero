package MapReduceZero::Agent::Sink;
use Moo;
use JSON qw(decode_json encode_json);
use ZMQ::LibZMQ3;
use ZMQ::Constants qw(ZMQ_PUSH ZMQ_PULL);
use MapReduceZero;

with 'MapReduceZero::Agent';

sub run {
    my ($self) = @_;

    my $zmq_ctxt = zmq_init();
    
    my $work_sock = zmq_socket($zmq_ctxt, ZMQ_PULL);
    zmq_bind($work_sock, 'tcp://127.0.0.1:9992');
    
    my $client_sock = zmq_socket($zmq_ctxt, ZMQ_PUSH);
    zmq_bind($client_sock, 'tcp://127.0.0.1:9993');
    
    while (1) {
        my $mapped_json = zmq_msg_data( zmq_recvmsg($work_sock) );
        
        debug "Sink: Received from Worker and sending to Client";

        zmq_sendmsg($client_sock, $mapped_json);
    }
}

1;

