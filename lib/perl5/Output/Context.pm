package Output::Context;

# If we're filling in an Excel workbook, we use the
# OutputContext to keep the number of the current line.
#
# We remember here which objects to use to deliver the
# Field content. The Output object should know how to
# deliver the content.

use warnings;
use strict;

use Data::Dumper; # muell

use Field;
use Output::Record; # TODO what do we need Record for here?

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
  $self->{'Output-Again'} = $output;
  $self->{'Id'} = $id;
  $self->openContext;
  return $self;
}
sub output {
  my ($self) = (@_);

  if (!defined $self->{'Output'}) {
    printf "Output::Context ''%s'' lost its Output\n", $self->id;
    warn sprintf "Output::Context ''%s'' lost its Output;", $self->id;
  }
  return Cf->byName('Output')->value;
  return $self->{'Output'};
}
# muell
#sub openRecord {
#  my ($self) = (@_);
#
#  return $self;
#}
##
# This isn't called by Action
#
# We might want to use a Record class.
# sub closeRecord {
#   my ($self) = (@_);
#
#   return $self;
# }
sub id {
  my ($self) = (@_);

  return $self->{'Id'};
}
sub openContext {
  my ($self) = (@_);

  # Subclasses could e. g. use $self->output->emit() here.
  return $self;
}
sub closeContext {
  my ($self) = (@_);

  # TODO better emit nothing here
  # $self->output->emit(sprintf "# End of %s (%s: %d)", $self->id, # muell
  #  __PACKAGE__, __LINE__); # muell
  return $self;
}
sub DESTROY {
  my ($self) = (@_);

  # We need to ->closeContext() by ourselves, using Output->takeThingsDown().
  # Perl's destruction order is unfortnate.
  # $self->closeContext; # no.
}
sub emit {
  my ($self, $field) = (@_);

  # TODO have Output find out if there was a change
  # and invoke the local ->closeContext() and ->openContext().
  # $self->output->currentOutputContext($self->id);
  # Subclasses of Output may have this behavior.

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
