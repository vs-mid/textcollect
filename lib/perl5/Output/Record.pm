package Output::Record;

# The idea is to have this independent of the Output and the
# Output::Context. Basically, we want to be able to know when
# there is a change in the Output::Context, or when an Output::Context
# is used for the first time, or when it is not going to be used
# again (really the latter?).

# This finds ways to get to the appropriate Output::Context. See
# ->getOutputContext() for how it does this.
#
# This is used to invoke Output::Context->newline() without
# actually having to think of it: The expriy of an Output::Record
# is taken as the end of a record.

##
# Args
#
#   $action -- something Named or that can ->getOutputContext(),
#     not expecting an Arg. TODO weird here.
sub new {
  my ($proto, $action) = (@_);

  my $class = ref $proto || $proto;
  my $self = {};
  $self->{'Action'} = $action;
  $self->{'OutputContext'} = undef;
  printf "%s %4d: a new Record\n", __PACKAGE__, __LINE__;
  bless $self, $class;
}
##
# This is meant to cause instantiation of the Output::Context to
# use here.
#
# When this is instantiated, either a method to instantiate the
# OutputContext or the $id of the OutputContext is known. So, would
# we overload ->new() to accept either something can
# ->getOutputContext() but doesn't accept an arguemnt, or a scalar
# $id to use with Output::getOutputContext();
sub getOutputContext {
  my ($self) = (@_);

  unless (defined $self->{'OutputContext'}) {
    my $action = $self->{'Action'};
    my $context;
    my $output = Cf->byName('Output')->value;
    if (ref $action) {
      if ($action->can('getOutputContext')) {
	$context = $action->getOutputContext();
      } elsif ($action->can('name')) {
	$context = $output->getOutputContext($action->name);
      } else {
	warn "Cannot get Output::Context";
      }
    } else {
      $context = $output->getOutputContext($action);
    }
    printf "%s: %4d: just found an Output::Context ''%s'' with an output of ''%s'';\n",
     __PACKAGE__, __LINE__, ref $context, ref $context->output;
    return $self->{'OutputContext'} = $context;
  }
  printf "%s: %4d: using an Output::Context ''%s'' with an output of ''%s'';\n",
   __PACKAGE__, __LINE__, ref $self->{'OutputContext'}, ref $self->{'OutputContext'}->output();
  return $self->{'OutputContext'};
}
##
#
sub emit {
  my ($self, $thing) = (@_);

  $self->getOutputContext->emit($thing);
}
##
# TODO ugly
sub DESTROY {
  my ($self) = (@_);

  printf "%s: %4d: done with a Record\n", __PACKAGE__, __LINE__; # muell
  printf "%s: %4d: the Output used here appears to be a ''%s'';\n", __PACKAGE__, __LINE__, ref $self->getOutputContext()->output(); # muell
  if (defined $self->{'OutputContext'}
   and $self->{'OutputContext'}->can('newline')) {
    $self->getOutputContext->newline;
    printf "%s: %4d: there was a newline for a %s (''%s'');\n", __PACKAGE__, __LINE__, ref $self->getOutputContext(), ref $self->getOutputContext()->output(); # muell
  }
  else {
    printf "%s: %4d: no newline\n", __PACKAGE__, __LINE__; # muell
  }
}
1;
