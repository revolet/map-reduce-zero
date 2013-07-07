package MapReduceZero::Agent::Work;
use Moo;
use JSON qw(decode_json encode_json);
use File::Temp;
use IPC::Open2;
use ZMQ::LibZMQ3;
use ZMQ::Constants qw(ZMQ_PUSH ZMQ_PULL);
use MapReduceZero;
use MapReduceZero::Info;

has maps => (
    is      => 'ro',
    default => sub { {} },
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

with 'MapReduceZero::Agent';

sub run {
    my ($self) = @_;

    my $zmq_ctxt = zmq_init();
    
    my $vent_sock = zmq_socket($zmq_ctxt, ZMQ_PULL);
    zmq_bind($vent_sock, 'tcp://127.0.0.1:9991');
    
    my $sink_sock = zmq_socket($zmq_ctxt, ZMQ_PUSH);
    zmq_connect($sink_sock, 'tcp://127.0.0.1:9992');
    
    while (1) {
        my $input_json = zmq_msg_data( zmq_recvmsg($vent_sock) );
        
        debug "Worker $$: Received from Vent and processing";

        my $input = decode_json($input_json);
        
        my $map = $self->maps->{ $input->{id} } //= $self->_get_info( $input->{id} => 'map' );

        my $fh = File::Temp->new();
        $fh->print($map);
        $fh->close();
        qx{chmod +x $fh};

        my($chld_out, $chld_in);
        my $pid = open2($chld_out, $chld_in, $fh->filename);

        print $chld_in encode_json($input)."\n";
        my $mapped_json = <$chld_out>;
        
        debug "Worker $$: Processed and sending to Sink";

        zmq_sendmsg($sink_sock, $mapped_json);
    }
}

1;

