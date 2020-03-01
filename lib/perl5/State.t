#!/usr/bin/perl

use warnings;
use strict;

use Test::More;

BEGIN {
  use_ok('State');
}

my $s1 = State->new('Start');
isa_ok($s1, 'State', 'a State');
my $s2 = State->new('SecondState');
isa_ok($s2, 'State', 'another State');
is($s1->name, 'Start', 'remembers its name');
is($s2->name, 'SecondState', 'another State remembers its name');

is($s1->onEntry('EntryAction'), 'EntryAction', 'set an Action');
is($s1->onExit('ExitAction'), 'ExitAction', 'set another Action');
is($s1->onEntry(), 'EntryAction', 'remembered an Action');
is($s1->onExit(), 'ExitAction', 'remembered the other Action');

is($s2->onEntry('OnEntryToTheSecondState'), 'OnEntryToTheSecondState', 'set an action to the second state');

my $s3;
isa_ok($s3 = $s1->newState('SecondState'), 'State', 'switched to another state');

isa_ok($s3, 'State', 'the new State');
is($s3->name(), 'SecondState', 'transited');
isa_ok($s3 = $s3->newState('Start'), 'State', 'switched back ...');
is($s3->name(), 'Start', '... successfully, as it seems');

done_testing;
