package MapReduceZero::Agent::Info;
use Moo;
use JSON qw(decode_json encode_json);
use ZMQ::LibZMQ3;
use ZMQ::Constants qw(ZMQ_REP);
use MapReduceZero;

has store => (
    is      => 'ro',
    default => sub { {} },
);

with 'MapReduceZero::Agent';

sub run {
    my ($self) = @_;
    
    my $zmq_ctxt = zmq_init();
    
    my $info_sock = zmq_socket($zmq_ctxt, ZMQ_REP);
    zmq_bind($info_sock, 'tcp://127.0.0.1:9994');
    
    while (1) {
        my $request_json = zmq_msg_data( zmq_recvmsg($info_sock) );
        
        my $request = decode_json($request_json);
        
        my $id    = $request->{id}    // '';
        my $key   = $request->{key}   // '';
        my $value = $request->{value} // '';
        
        debug "Info: Received request for %s => %s (%s)", $id, $key, $value;
        
        my $store = $self->store->{$id} //= {};
        
        my $response;
        
        if ($key && $value) {
            $store->{$key} = $value;
        }
        
        if ($key) {
            $response = { value => $store->{$key} };
        }
        
        my $response_json = encode_json($response);
       
        zmq_sendmsg($info_sock, $response_json);
    }
}

1;

