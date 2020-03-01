#!/usr/bin/perl

use warnings;
use strict;

use Test::More;

BEGIN {
  use_ok('Output');
}

my $filename = "/tmp/muell-$$";

my $out = Output->new($filename);
isa_ok($out, 'Output', 'an object');
$out = undef;

open IN, $filename or fail "opening the file we just created";
is(<IN>, "# Start\n", "first line of output");
is(<IN>, "# The End\n", "last line of output");
close IN;
unlink $filename;
done_testing;
