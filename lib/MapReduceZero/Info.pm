package MapReduceZero::Info;
use Moo;
use JSON qw(encode_json decode_json);
use ZMQ::LibZMQ3;
use ZMQ::Constants qw(ZMQ_REQ);
use MapReduceZero;

has _zmq_ctxt => (
    is => 'lazy',
);

has _info_sock => (
    is => 'lazy',
);

sub _build__zmq_ctxt { zmq_init() }

sub _build__info_sock {
    my ($self) = @_;
    
    return zmq_socket($self->_zmq_ctxt, ZMQ_REQ);
}

sub BUILD {
    my ($self) = @_;
    
    zmq_connect($self->_info_sock, 'tcp://127.0.0.1:9994');
}

sub get {
    my ($self, $id, $key) = @_;

    my $request_json = encode_json({ id => $id, key => $key });
    
    debug "Client: Getting info for %s => %s", $id, $key;
    
    zmq_sendmsg($self->_info_sock, $request_json);
    
    my $response_json = zmq_msg_data( zmq_recvmsg($self->_info_sock) );
    
    my $response = decode_json($response_json);
    
    debug "Client: Got result from Info: %s", $response->{value};
    
    return $response->{value};
}

sub set {
    my ($self, $id, $key, $value) = @_;
    
    my $request_json = encode_json({ id => $id, key => $key, value => $value });
    
    debug "Client: Setting info for %s => %s to %s", $id, $key, $value;
    
    zmq_sendmsg($self->_info_sock, $request_json);
    
    my $response_json = zmq_msg_data( zmq_recvmsg($self->_info_sock) );
    
    my $response = decode_json($response_json);
    
    debug "Client: Got result from Info: %s", $response->{value};
    
    return $response->{value};
}

1;


