package Output::Context::Simple;

# If we're filling in an Excel workbook, we use the
# OutputContext to keep the number of the current line.
#
# We remember here which objects to use to deliver the
# Field content. The Output object should know how to
# deliver the content.

use warnings;
use strict;

use parent qw(Output::Simple);

use Field;

##
# Args
#
#   $id -- the ID of this, typically the name of the
#     Action
#
#   $output -- the Output object that knows the rest of how
#     deliver the Field contents
sub new {
  my ($proto, $id, $output) = (@_);

  my $class = ref $proto || $proto;
  my $self = {};
  bless $self, $class;
  $self->{'Output'} = $output;
  $self->{'Id'} = $id;
  $self->openContext;
  return $self;
}
sub output {
  my ($self) = (@_);

  return $self->{'Output'};
}
sub id {
  my ($self) = (@_);

  return $self->{'Id'};
}
##
# Args
#
#   $context -- a scalar. This is the name of the Action we act on behalf of
sub __GONE__context {
  my ($self, $context) = (@_);

  if (defined $context) {
    if (defined $self->{'context'}) {
      if ($context ne $self->{'context'}) {
        $self->closeContext;
	$self->openContext($context);
	return $self->{'context'};
      }
      return $self->{'context'} = $context;
    }
    return $self->openContext($context);
  }
  return $self->{'context'};
}
sub openContext {
  my ($self) = (@_);

  $self->output->emit(sprintf "# Start of %s (%s: %d)", $self->id,
   __PACKAGE__, __LINE__);
  return $self;
}
sub closeContext {
  my ($self) = (@_);

  $self->output->emit(sprintf "# End of %s (%s: %d)", $self->id,
   __PACKAGE__, __LINE__);
}
sub DESTROY {
  my ($self) = (@_);

  $self->closeContext;
}
sub emit {
  my ($self, $field) = (@_);

  # TODO have Output find out if there was a change
  # and invoke the local ->closeContext() and ->openContext().
  # $self->output->currentOutputContext($self->id);

  my $value = $field->value;
  my $textref;
  if (ref $value eq 'ARRAY') {
    $textref = $value;
  } else {
    $textref = [ $value ];
  }
  foreach my $text (@$textref) {
    $self->output->emit(sprintf "%s: %s: %s", $self->id, $field->name, $text);
  }
  return $self;
}
1;
