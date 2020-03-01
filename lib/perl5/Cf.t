#!/usr/bin/perl

use warnings;
use strict;

use Test::More;

BEGIN {
  use_ok('Cf');
}

my $cf = Cf->new('Output');
isa_ok($cf, 'Cf');
is($cf->value('outputsomething'), 'outputsomething', 'set');
is($cf->value(), 'outputsomething', 'got');
is(Cf->byName('Output')->value(), 'outputsomething', 'got again');

done_testing;
