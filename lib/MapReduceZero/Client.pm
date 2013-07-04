package MapReduceZero::Client;
use Moo;
use JSON qw(encode_json decode_json);
use ZMQ::LibZMQ3;
use ZMQ::Constants qw(ZMQ_PUSH ZMQ_PULL);

has map => (
    is       => 'ro',
    required => 1,
);

has _ctxt => (
    is      => 'ro',
    builder => 1,
);

has _vent => (
    is      => 'ro',
    builder => 1,
);

has _sink => (
    is      => 'ro',
    builder => 1,
);

sub _build__ctxt { zmq_init() }

sub _build__vent {
    my ($self) = @_;
    
    return zmq_socket($self->_ctxt, ZMQ_PUSH);
}

sub _build__sink {
    my ($self) = @_;
    
    return zmq_socket($self->_ctxt, ZMQ_PULL);
}

sub BUILD {
    my ($self) = @_;

    zmq_connect($self->_vent, 'tcp://127.0.0.1:9990');
    zmq_connect($self->_sink, 'tcp://127.0.0.1:9993');
}

sub send {
    my ($self, $data) = @_;
    
    my $msg = encode_json({
        map  => $self->map,
        data => $data,
        end  => 0,
    });
    
    print STDERR "Client: Sending to Vent: $msg\n";
    
    zmq_sendmsg($self->_vent, $msg);
}

sub recv {
    my ($self) = @_;
    
    my $msg = zmq_recvmsg($self->_sink);

    my $data = zmq_msg_data($msg);
    
    print STDERR "Client: Got result from Sink: $data\n";

    my $job = decode_json($data);
    
    return $job;
}

sub recv_all {
    my ($self) = @_;
    
    # TODO
    return [];
}

1;

