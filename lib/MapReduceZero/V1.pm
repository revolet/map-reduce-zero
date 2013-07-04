package MapReduceZero::V1;
use Moo;
use MapReduceZero::Agent::Vent;
use MapReduceZero::Agent::Work;
use MapReduceZero::Agent::Sink;
use MapReduceZero::Client;

sub vent {
    my ($self) = @_;
    
    return MapReduceZero::Agent::Vent->new();
}

sub work {
    my ($self) = @_;
    
    return MapReduceZero::Agent::Work->new();
}

sub sink {
    my ($self) = @_;
    
    return MapReduceZero::Agent::Sink->new();
}

sub client {
    my ($self, %args) = @_;
    
    return MapReduceZero::Client->new(%args);
}

1;

