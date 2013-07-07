package MapReduceZero::Agent::Vent;
use Moo;
use ZMQ::LibZMQ3;
use ZMQ::Constants qw(ZMQ_PUSH ZMQ_PULL);
use MapReduceZero;

with 'MapReduceZero::Agent';

sub run {
    my ($self) = @_;
    
    my $zmq_ctxt = zmq_init();
    
    my $client_sock = zmq_socket($zmq_ctxt, ZMQ_PULL);
    zmq_bind($client_sock, 'tcp://127.0.0.1:9990');
    
    my $work_sock = zmq_socket($zmq_ctxt, ZMQ_PUSH);
    zmq_connect($work_sock, 'tcp://127.0.0.1:9991');
    
    while (1) {
        my $input_json = zmq_msg_data( zmq_recvmsg($client_sock) );
        
        debug "Vent: Received from Client and sending to Worker";
       
        zmq_sendmsg($work_sock, $input_json);
    }
}

1;

