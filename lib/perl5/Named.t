#!/usr/bin/perl

use warnings;
use strict;

use Data::Dumper;

use Test::More;

BEGIN {
  use_ok('Named');
  use_ok('Thing1');
  use_ok('Thing2');
}

my $n = Named->new('eins');
isa_ok($n, 'Named', 'instantiated');
is($n->name(), 'eins', 'remembers its name');
isa_ok($n->giveName('zwooh'), 'Named', 'an error message here');
is($n->name(), 'eins', 'still remembers its name');
my $another = Named->new('zwei');
isa_ok($another, 'Named', 'another instance');

my $one = Named->byName('eins');
isa_ok($one, 'Named', 'found by name');
my $two = Named->byName('zwei');
isa_ok($two, 'Named', 'found another');
is($one->name(), 'eins', 'found the right one');
is($two->name(), 'zwei', 'right with the other, too');

my $t1 = Thing1->new('eins-null');
isa_ok($t1, 'Thing1', 'instantiated');
my $t2 = Thing2->new('zwei-null');
isa_ok($t2, 'Thing2', 'instantiated');
my $whatsthat = Thing1->byName('eins-null');
isa_ok($whatsthat, 'Thing1', 'found something');
$whatsthat = Thing2->byName('eins-null');
is($whatsthat, undef, 'a type has its own namespace');
is(Thing2->type(), 'Thing2', 'class method returns the type');
is(Named->type(), 'Named', 'interface method returns the interface name');
$whatsthat = Thing2->byName('zwei-null');
isa_ok($whatsthat, 'Thing2', 'called something by name');
is($whatsthat->name(), 'zwei-null', 'named as expected');

is(Thing1->new(), undef, 'no thing without a name');
my $stuff = Thing2->namesAndThings();
isa_ok($stuff, 'HASH', 'names and things');

done_testing;

__END__
