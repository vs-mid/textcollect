package Output;

use warnings;
use strict;

use Output::Context;

##
# to initialize something like a file handle
sub new {
  my ($proto) = (@_);

  my $class = ref $proto || $proto;
  my $self = {};
  bless $self, $class;
  $self->{'OutputContext'} = [];
  return $self;
}
##
# Args
#
#   $name -- typically the name of an Action TODO in more general terms?
#
# Returns
#
#   the newly generated Output::Context
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
#
# TODO When actually does the Output::Context expire. We don't
# reference it here. However, subclasses might do so.
#
# This generates an object of class Output::Context or or a subclass
# of that.
#
# An Output::Context has an ID (TODO what for). Here, it should
# not hurt to re-use an ID. TODO verify.
sub getOutputContext {
  my ($self, $id) = (@_);

  # TODO does this make sense here?
  # This is to be overridden anyway.
  # TODO We could generate the name of the Output::Context class
  # from this. But that would mean that we ''use'' a dynamically
  # named class.
  return $self->registerOutputContext(Output::Context->new($id, $self));
}
##
# Returns
#
#   $outputContext
sub registerOutputContext {
  my ($self, $outputContext) = (@_);

  push @{$self->{'OutputContext'}}, $outputContext;
  return $outputContext;
}
##
#
sub takeDownOutputContexts {
  my ($self) = (@_);

  while (defined(my $i = pop @{$self->{'OutputContext'}})) {
    if (!defined $i->output) {
      # Well, good, it doesn't happen.
      warn sprintf "Output::Context ''%s'' has lost its Output", $i->id;
    }
    $i->closeContext(); # TODO doing that multiple times causes the Output::Context to re-emit
  }
  return $self;
}

##
# nothing done here
sub emit {
  my ($self, $text) = (@_);

  print "EMISSION impossible in plain ''Output'': have a subclass.\n"; # muell
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

  printf "EMISSION done. An Output ''%s'' going away.\n", ref $self; # muell
}
1;
