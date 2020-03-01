package Output::Simple;

use warnings;
use strict;

use IO::File;

use Output::Context::Simple;

use parent qw(Output);

sub new {
  my ($proto, $outputfilename) = (@_);

  my $class = ref $proto || $proto;
  my $self = {};
  bless $self, $class;
  my $fh = IO::File->new(">$outputfilename");
  return undef unless defined $fh;
  print $fh "# Start\n";
  $self->{'outputfilehandle'} = $fh;
  return $self;
}
##
# TODO not yet. See the OutputContext class.
# sub currentOutputContext {
# }
##
# Args
#
#   $name -- typically the name of an Action
#
# We may keep a memory here which OutputContext is the current
# one. When there is a change in OutputContext, we may close
# the old OutputContext, and open the one we change to. --
# E. g., YAML may need at least some opening material with
# the beginning of output under a given context. -- If we're
# using Excel::Writer::XLSX, we may not need to know which
# OutputContext was used generating the last output.
#
# TODO Changed: This always returns a new OutputContext.
# Users may decide whether to reuse an existing OutputContext.
# Subclasses may do some caching here.
sub getOutputContext {
  my ($self, $id) = (@_);

  # If this kind of thing is needed, have a subclass do it.
  # if (exists $self->{'OutputContextByName'}{$id}) {
  #   return $self->{'OutputContextByName'}{$id};
  #  }
  return $self->{'OutputContextByName'} = Output::Context::Simple->new($id, $self);
}

sub emit {
  my ($self, $text) = (@_);

  my $fh = $self->{'outputfilehandle'};
  print $fh "$text\n";
  return $self;
}

# Each Action knows an OutputContext by a corresponding name.
# When an Action finishes, we either decrement the reference count
# of the OutputContext or destroy the object. Destroying the
# OutputContext means that we may emit something e. g. like a
# closing tag, and that next time we invoke an action by that name,
# we have a chance to emit e. g. an opnening tag.

sub DESTROY {
  my ($self) = (@_);

  my $fh = $self->{'outputfilehandle'};
  print $fh "# The End\n";
  $self->{'outputfilehandle'}->close;
}
1;
