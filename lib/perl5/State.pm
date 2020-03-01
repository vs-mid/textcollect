package State;

# meant to represent the parser state

# Each parser state has a name. A match on a RE changes the state of
# the parser. The parser state defines a set of REs to test the current
# line against. The RE that matches is used to tell the new state of
# the parser.

use parent qw(Named);

use Action;

sub new {
  my ($proto, $name) = (@_);

  my $class = ref $proto || $proto;

  my $self = $proto->SUPER::new($name);
  return $self;
}
sub testAndAction {
  my ($self, $test, $action) = (@_);

  if (defined $test) {
    push @{$self->{'testAndAction'}}, [ $test, $action ];
  }
  return $self->{'testAndAction'};
}
sub preEntry {
  my ($self, $actionname) = (@_);
  if (defined $actionname) {
    return $self->{'preEntry'} = $actionname;
  }
  return $self->{'preEntry'};
}
sub onExit {
  my ($self, $actionname) = (@_);
  if (defined $actionname) {
    return $self->{'onExit'} = $actionname;
  }
  return $self->{'onExit'};
}
##
# Error conditions:
#
#   -- A State by name $stateName does not exist.
#
#   -- An Action named by the respecitve methods ->onExit or ->preEntry
#     does not exist.
#
# TODO Both error conditions are Configuration errors and can be
# checked against before parsing starts.
sub newState {
  my ($self, $stateName) = (@_);

  if ($stateName eq $self->name) {
    return $self;
  }

  if (defined $self->onExit) {
    my $action = Action->byName($self->onExit);
    if (defined $action) {
      printf "%s: %4d: acting on exit from state %s;\n", __PACKAGE__, __LINE__, $self->name; # muell
      $action->act();
      printf "%s: %4d: -- done with onExit action.\n", __PACKAGE__, __LINE__; # muell
    } else {
      # TODO this is an error in Configuration
      warn sprintf "%s: %s: Can't invoke action %s on exit from state %s",
       __PACKAGE__, $self->name, $self->onExit, $stateName;
    }
  }
  $newState = $self->byName($stateName);
  if (defined $newState->preEntry) {
    my $action = Action->byName($newState->preEntry);
    if (defined $action) {
      printf "%s: %4d: acting on entry into state %s;\n", __PACKAGE__, __LINE__, $stateName; # muell
      $action->act();
      printf "%s: %4d: -- done with preEntry action.\n", __PACKAGE__, __LINE__; # muell
    } else {
      # TODO this is an error in Configuration
      warn sprintf "%s: %s: Can't invoke action %s on entry to state %s",
       __PACKAGE__, $self->name, $newState->preEntry, $stateName;
    }
  }
  return $newState;
}
1;
