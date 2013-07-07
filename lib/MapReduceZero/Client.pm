package MapReduceZero::Client;
use Moo;
use JSON qw(encode_json decode_json);
use ZMQ::LibZMQ3;
use ZMQ::Constants qw(ZMQ_PUSH ZMQ_PULL);
use MapReduceZero;

has id => (
    is      => 'ro',
    default => sub { join q{-}, time, $$, int( rand(2**31) ) },
);

has map => (
    is       => 'ro',
    required => 1,
);

has _info => (
    is      => 'ro',
    lazy    => 1,
    default => sub { MapReduceZero::Info->new() },
    
    handles => {
        _get_info => 'get',
        _set_info => 'set',
    },
);

has _zmq_ctxt => (
    is => 'lazy',
);

has _vent_sock => (
    is => 'lazy',
);

has _sink_sock => (
    is => 'lazy',
);

sub _build__zmq_ctxt { zmq_init() }

sub _build__vent_sock {
    my ($self) = @_;
    
    return zmq_socket($self->_zmq_ctxt, ZMQ_PUSH);
}

sub _build__sink_sock {
    my ($self) = @_;
    
    return zmq_socket($self->_zmq_ctxt, ZMQ_PULL);
}

sub BUILD {
    my ($self) = @_;

    zmq_connect($self->_vent_sock, 'tcp://127.0.0.1:9990');
    zmq_connect($self->_sink_sock, 'tcp://127.0.0.1:9993');
}

sub send {
    my ($self, $inputs) = @_;
    
    $self->_set_info( $self->id => ( map => $self->map ) );
    
    for my $input (@$inputs) {
        $self->_send_input($input);
    }
    
    $self->_set_info( $self->id => ( input_done => 1 ) );
}

sub _send_input {
    my ($self, $input) = @_;
    
    $input->{id} = $self->id;

    my $input_json = encode_json($input);
    
    debug "Client: Sending to Vent";
    
    zmq_sendmsg($self->_vent_sock, $input_json);
}

sub recv {
    my ($self) = @_;
    
    my $mapped_json = zmq_msg_data( zmq_recvmsg($self->_sink_sock) );
    
    debug "Client: Got result from Sink";

    my $mapped = decode_json($mapped_json);
    
    return $mapped;
}

sub recv_all {
    my ($self) = @_;
    
    # TODO
    return [];
}

1;

