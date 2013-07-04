#!/usr/bin/env perl
use strict;
use warnings;
use Test::Most;
use MapReduceZero::V1;

my $mrz = MapReduceZero::V1->new();

my $vent = $mrz->vent;
my $work = $mrz->work;
my $sink = $mrz->sink;

isa_ok $vent, 'MapReduceZero::Agent::Vent';
isa_ok $work, 'MapReduceZero::Agent::Work';
isa_ok $sink, 'MapReduceZero::Agent::Sink';

$vent->start;
$work->start;
$sink->start;

#sleep 1;

my $client = $mrz->client(
    map => q{#!/usr/bin/env perl
        use strict;
        use warnings;
        use IO::Handle;
        use JSON qw(encode_json decode_json);
        
        while (my $json = <STDIN>) {
            my $input = decode_json($json);
            
            $input->{data}->[0]->{num}++;
            
            my $result = encode_json($input);
            
            STDOUT->printflush($result."\n");
        }
    }
);

$client->send([ { num => 1 }, { num => 10 } ]);

my $result = $client->recv;

is $result->{data}->[0]->{num}, 2;

done_testing;

