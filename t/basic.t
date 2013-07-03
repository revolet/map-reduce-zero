#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
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

done_testing;

