package MapReduceZero::V1;
use Moo;
use MapReduceZero::Agent::Vent;
use MapReduceZero::Agent::Work;
use MapReduceZero::Agent::Sink;
use MapReduceZero::Agent::Info;
use MapReduceZero::Client;
use MapReduceZero::Info;

sub vent_agent {
    my ($self, %args) = @_;
    
    return MapReduceZero::Agent::Vent->new(%args);
}

sub work_agent {
    my ($self, %args) = @_;
    
    return MapReduceZero::Agent::Work->new(%args);
}

sub sink_agent {
    my ($self, %args) = @_;
    
    return MapReduceZero::Agent::Sink->new(%args);
}

sub info_agent {
    my ($self, %args) = @_;
    
    return MapReduceZero::Agent::Info->new(%args);
}

sub client {
    my ($self, %args) = @_;
    
    return MapReduceZero::Client->new(%args);
}

sub info {
    my ($self, %args) = @_;
    
    return MapReduceZero::Info->new(%args);
}

1;

