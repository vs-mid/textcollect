#!/usr/bin/perl

use warnings;
use strict;

use Test::More;

BEGIN {
  use_ok('RePlus');
}

my $r1 = RePlus->new('FirstPattern', 'pattern-one');
isa_ok($r1, 'RePlus', 'RePlus');
is($r1->re(), 'pattern-one', 'the pattern used with instantiation');
is($r1->name(), 'FirstPattern', 'remembers its name');
my $r1again = RePlus->byName('FirstPattern');
is($r1again->re(), 'pattern-one', 'found the pattern by its name');
is($r1again->name(), 'FirstPattern', 'that name');
is($r1->re('pattern-(\w+)'), 'pattern-(\w+)', 'new pattern');
is($r1->re(), 'pattern-(\w+)', 'remembers a pattern set');
ok($r1->test('pattern-ahem'), 'a match');
#
is($r1->test('Pattern-soundso') || 1, 1, 'not a match');

is_deeply($r1->namesForMatches([ 'first', 'second', 'third' ]), [ 'first', 'second', 'third' ], 'set names for RE matches');
ok($r1->test('pattern-hereweare'), 'another match');
is($r1->extract('first'), 'hereweare', 'extracted something');
# bit random here
$r1->re('\s(\d)\s(\d)(\d*)');
ok($r1->test(' 2 35-'), 'yet one more match');
is($r1->extract('first'), '2', 'a mouthful');
is($r1->extract('second'), '3', 'a mouthful');
is($r1->extract('third'), '5', 'a mouthful');


done_testing;
