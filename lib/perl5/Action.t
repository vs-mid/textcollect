#!/usr/bin/perl

use warnings;
use strict;

use Test::More;

BEGIN {
  use_ok('Action');
}

my $a1 = Action->new('ActionOne', [ 'DeleteFieldValue', 'BookingTextOtherLine' ]);
isa_ok($a1, 'Action', 'an Action');
is_deeply($a1->dothis(), [[ 'DeleteFieldValue', 'BookingTextOtherLine' ]], 'remembered configuration from instantiation');
is_deeply($a1->dothis([ 'SaveFieldValue', 'BookingDateWert' ]), [
 [ 'DeleteFieldValue', 'BookingTextOtherLine' ],
 [ 'SaveFieldValue', 'BookingDateWert' ]
], 'more configuration');
is_deeply($a1->dothis(), [
 [ 'DeleteFieldValue', 'BookingTextOtherLine' ],
 [ 'SaveFieldValue', 'BookingDateWert' ]
], 'remembered configuration');
is_deeply(Action->byName('ActionOne')->dothis(), [
 [ 'DeleteFieldValue', 'BookingTextOtherLine' ],
 [ 'SaveFieldValue', 'BookingDateWert' ],
], 'obviously found that Action by its name');

is($a1->act('sampleField'), 0); # not a test

my $a2 = Action->new('ActionTwo', [ 'DeleteValue', 'SampleField' ]);
isa_ok($a2, 'Action', 'an Action');

my $sampleField = Field->new('SampleField', 'Update');
isa_ok($sampleField, 'Field', 'got a sample Field to play with');

is($sampleField->value('A'), 'A', 'set a value');
is($sampleField->value(), 'A', 'the value is still there');

is($a2->act(), 1, 'acted');
is($sampleField->value(), undef, 'deleted a value via an Action');
is($sampleField->value('B'), 'B', 'set a value');

my $a3 = Action->new('ActionThree', [ 'EmitValue', 'SampleField' ]);
isa_ok($a3, 'Action', 'an Action');
is($a3->act(), 0, 'no sub to use');
isa_ok($a3->emitCallback(sub {
 my ($field, $action) = (@_);
 printf "Action %s: should emit %s;\n", $action->name(), $field->value();
}), 'CODE', 'defined a sub to use with EmitValue');
isa_ok($a3->emitCallback(), 'CODE', 'seems to remember the callback');
is($a3->act(), 1, 'should have invoked a sub');
my $stuffToEmit;
isa_ok($a3->emitCallback(sub {
 my ($field, $action) = (@_);
 printf "About to emit ''%s'';\n", $field->value(); # muell
 $stuffToEmit .= $field->value();
}), 'CODE', 'changed that sub');
is_deeply($a3->dothis([ 'DeleteValue', 'SampleField' ]), [
 [ 'EmitValue', 'SampleField' ],
 [ 'DeleteValue', 'SampleField' ]
], 'another act');

is($a3->act(), 1, 'attempted to emit, then delete');
is($stuffToEmit, 'B', 'we have an emission');
is($sampleField->value(), undef, 'part of our Action has deleted a value');

done_testing;
