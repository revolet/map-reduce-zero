#!/usr/bin/env perl
use strict;
use warnings;
use Test::Most;
use MapReduceZero::V1;

my $mrz = MapReduceZero::V1->new();

my $vent_agent = $mrz->vent_agent;
my $work_agent = $mrz->work_agent;
my $sink_agent = $mrz->sink_agent;
my $info_agent = $mrz->info_agent;

isa_ok $vent_agent, 'MapReduceZero::Agent::Vent';
isa_ok $work_agent, 'MapReduceZero::Agent::Work';
isa_ok $sink_agent, 'MapReduceZero::Agent::Sink';
isa_ok $info_agent, 'MapReduceZero::Agent::Info';

$vent_agent->start;
$work_agent->start;
$sink_agent->start;
$info_agent->start;

my $client = $mrz->client(
    map => q{#!/usr/bin/env perl
        use strict;
        use warnings;
        use IO::Handle;
        use JSON qw( encode_json decode_json );
        
        while (my $json = <STDIN>) {
            my $input = decode_json($json);
            
            $input->{num}++;
            $input->{num} *= 2;
            
            my $result = encode_json($input);
            
            STDOUT->printflush($result."\n");
        }
    }
);

my $info = $mrz->info;

is $info->set( 1234 => ( foo => 'bar' ) ), 'bar';

is $info->get( 1234 => 'foo'), 'bar';

$client->send([ { num => 1 }, { num => 10 } ]);

is $client->recv->{num}, 4;
is $client->recv->{num}, 22;

done_testing;

