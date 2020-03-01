#!/usr/bin/perl

use warnings;
use strict;

use Test::More;

BEGIN {
  use_ok("Field");
}

my $appendField = Field->new('Field1', 'Append');
isa_ok($appendField, 'Field', "a Field");
is($appendField->value(), undef, "initially no value");
is($appendField->value("eins"), "eins", "submitted a value");
is($appendField->value("zwei"), "eins\nzwei", "appended a value");
is($appendField->value(), "eins\nzwei", "this is our value");

my $updateField = Field->new('Field2', 'Update');
isa_ok($updateField, 'Field', 'a Field');
is($updateField->value(), undef, "no value, initially");
is($updateField->value('firstValue'), 'firstValue', 'first submission');
is($updateField->value('secondValue'), 'secondValue', 'replaced by second submission');
is($updateField->value(), 'secondValue', 'remembers that value');

my $pushField = Field->new('Field3', 'Push');
isa_ok($pushField, 'Field', 'another Field');
is($pushField->value(), undef, 'no value');
is_deeply($pushField->value('first'), [ 'first' ], 'setting a value returns a list');
is_deeply($pushField->value(), [ 'first' ], 'retrieving the first value');
is_deeply($pushField->value('second'), [ 'first', 'second' ], 'stacking values');
is_deeply($pushField->value(), [ 'first', 'second' ], 'getting two values back');

my $assertUniqueField = Field->new('Field4', 'AssertUnique');
isa_ok($assertUniqueField, 'Field', 'yet another');
is($assertUniqueField->value(), undef, 'no value yet');
is($assertUniqueField->value('somethinghere'), 'somethinghere', 'set a value');
is($assertUniqueField->value(), 'somethinghere', "it's still there");
is($assertUniqueField->value('somethinghere'), undef, "won't take another value");
is($assertUniqueField->value('somethingthere'), undef, "won't take another value");
is($assertUniqueField->value(), 'somethinghere', 'but keeps the first value');

my $assertEqualField = Field->new('Field5', 'AssertEqual');
isa_ok($assertEqualField, 'Field', 'yet one more');
is($assertEqualField->value(), undef, 'nothing there, initially');
is($assertEqualField->value('high'), 'high', 'set a value');
is($assertEqualField->value('low'), undef, 'impossible to change');
is($assertEqualField->value(), 'high', 'value unchanged');

is(Field->byName('Field1')->value(), "eins\nzwei", 'found that Field by its name');
is(Field->byName('Field2')->value(), 'secondValue', 'found another Field by its respective name');
is_deeply(Field->byName('Field3')->value(), [ 'first', 'second' ], 'got these stacked values back');
is(Field->byName('Field4')->value(), 'somethinghere', "did't forget");
is(Field->byName('Field5')->value(), 'high', 'indeed kept the old value');

# This is testing Named, actually.
is(Field->byName('Field1'), $appendField, 'discovered something by name');
is(Field->byName('Field4'), $assertUniqueField, 'discovered something else by name');

is($assertEqualField->deleteValue(), undef, 'deleted a value ...');
is($assertEqualField->value(), undef, '... successfully');

done_testing;
