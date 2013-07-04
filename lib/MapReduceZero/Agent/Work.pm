package MapReduceZero::Agent::Work;
use Moo;
use JSON qw(decode_json);
use File::Temp;
use IPC::Open2;
use ZMQ::LibZMQ3;
use ZMQ::Constants qw(ZMQ_PUSH ZMQ_PULL);

with 'MapReduceZero::Agent';

sub run {
    my ($self) = @_;

    my $ctxt = zmq_init();
    
    my $vent = zmq_socket($ctxt, ZMQ_PULL);
    zmq_bind($vent, 'tcp://127.0.0.1:9991');
    
    my $sink = zmq_socket($ctxt, ZMQ_PUSH);
    zmq_connect($sink, 'tcp://127.0.0.1:9992');
    
    while (1) {
        my $msg = zmq_recvmsg($vent);

        my $data = zmq_msg_data($msg);
        
        print STDERR "Worker $$: Received from Vent and processing: $data\n";

        my $job = decode_json($data);

        my $fh = File::Temp->new();

        $fh->print($job->{map});
        $fh->close();
        
        qx{chmod +x $fh};

        my($chld_out, $chld_in);
        
        my $pid = open2($chld_out, $chld_in, $fh->filename);

        print $chld_in $data."\n";
        my $result = <$chld_out>;
        
        print STDERR "Worker $$: Processed and sending to Sink: $result\n";

        zmq_sendmsg($sink, $result);
    }
}

1;

