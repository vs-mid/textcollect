package Action;

use warnings;
use strict;

use parent qw(Named);

use Field; # We'll be acting on Field values
use Output::Record;

# Configuration: Action
#
# An Action is a set of things to do about a value.
# ...

##
# Args
# 
#   $name -- a name to this Action
#
#   $act -- a name for what to do. This resolved to actual activiy
#     in here and hardcodedly.
#
#
# Returns
#
#   an Action or undef
sub new {
  my ($proto, $name, $dothis) = (@_);

  my $class = ref $proto || $proto;
  my $self = $proto->SUPER::new($name);
  $self->{'dothis'} = [ ];
  $self->dothis($dothis);
  return $self;
}
##
# Args
#
#   $dothis -- something to do: This is a ref to an array with elements
#
#     Act -- A name for what to do. This is resolved here, hardcodedly
#
#     On -- The name of a Field to act on
#
# Returns
#
#   a ref to an array with all things to do. Each thing to do
#     is an array ref, like the $dothis Arg. See there.
#
#   undef if there's something wrong with the Args
#
# We keep a list of things to do. This stacks another item on this list.
#
# This is Configuration.
#
# If the Arg cannot be understood, undef is returned, however, the
# dothis field is not changed.
sub dothis {
  my ($self, $dothis) = (@_);

  if (defined $dothis) {
    if (ref $dothis ne 'ARRAY' or $#{$dothis} ne 1) {
      warn "WASNICHRHICHTICH: tell what to do, and on which Field";
      return undef;
    }
    push @{$self->{'dothis'}}, $dothis;
  }
  return $self->{'dothis'};
}
##
# This sets of gets the sub that receives the values
# emitted with the ''emitValue'' action.
#
# Arg
#
#   a sub ref, or undef
#
# TODO This should really be global. So, what's global Configuration?
#sub emitCallback {
#  my ($self, $callback) = (@_);
#
#  if (defined $callback) {
#    if (ref $callback ne 'CODE') {
#      warn "WASNICHRICHTICH: expecting a piece of CODE here";
#      return undef;
#    }
#    return $self->{'emitCallback'} = $callback;
#  }
#  return $self->{'emitCallback'};
#}
##
# We fetch our OutputContext from the Output object.
#
# It may be here where we see if there's a change with
# our OutputContext.
sub getOutputContext {
  my ($self) = (@_);

  if (defined $self->{'OutputContext'} and $self->{'OutputContext'}->id eq $self->name) {
    return $self->{'OutputContext'};
  }
  # TDOO how about finding the Output as Output->byName('Excel')?
  # TODO make sure the OutputContext object is destroyed when we're
  # not using a ref to it, that is, after the ->act().
  return $self->{'OutputContext'} = Cf->byName('Output')->value->getOutputContext($self->name);
}
##
# TODO keep the OutputContext local to the ->act() method and have it
# go out of scope. That means, don't have Output remember the
# OutputContext object it has generated for us.
sub __NONO__deleteOutputContext {
  my ($self) = (@_);

  Cf->byName('Output')->deleteOutputContext();
  return $self;
}
##
# This sub is meant to know all the actions by their keywords,
# e. g., like ''DeleteFieldValue'', and is able to act on Field
# values also named by ->dothis().
#
# TODO The Emit* Actions seem to rely on unique field names.
# The EmitLiteral Action creates its own Field name ''_Literal''. Shall we ()
# give each Field created by EmitLiteral a new unique name, e. g.
# by including a value that we increment, or the line number where
# the Action is confg'd, or () have all the EmitLiteral utterings
# appear in one Field, e. g. in an array? Config'ing the Field
# should be cumbersome. -- For the moment, we'll include an incrememting
# number in the name of the field created by EmitLiteral.
sub act {
  my ($self) = (@_);

  # Output::Record creates an Output::Context for the first 
  # emission within an Action if we need that. TODO This
  # could still not handle multiple Outputs.
  my $record = Output::Record->new($self);
  printf "%s: %4d: about to ->act()\n", __PACKAGE__, __LINE__; # muell
  foreach my $todo (@{$self->dothis}) {
    my ($act, $on) = (@$todo);
    printf "%s: %4d: acting as ''%s'';\n", __PACKAGE__, __LINE__, $act; # muell

    if ($act eq 'EmitField') {
      $record->emit(Field->byName($on));
      next;
    } elsif ($act eq 'DeleteValue') {
      printf "%s: %s: attempting to delete value for %s;\n",
       __PACKAGE__, $self->name, $on;
      Field->byName($on)->deleteValue;
      next;
    } elsif ($act eq 'EmitLiteral') {
      # TODO Problem: This creates multiple fields by name _Literal, and the output
      # TODO becomes unparseable as YAML.
      Field->byName(
       '_Literal'
       )->value($on);
      $record->emit(Field->byName('_Literal'));
      next;
    } elsif ($act eq 'Log') {
      # TODO logging
      my $message = Field->byName($on)->value;
      if (ref $message eq 'ARRAY') {
        printf "%s: %s: $on: ...\n", __PACKAGE__, $self->name, $on;
	foreach my $i (0 .. $#{$message}) {
	  printf "%s: %s: %s %4d: ... %s\n",
	   __PACKAGE__, $self->name, $on,
	   $i, $message->[$i];
	}
      } else {
        printf "%s: %s: %s: %s\n", __PACKAGE__, $self->name, $on, Field->byName($on)->value;
      }
      next;
    } elsif ($act eq 'LogLiteral') {
      # TODO logging
      printf "%s: %s: %s\n", __PACKAGE__, $self->name, $on;
      next;
    } elsif ($act eq 'OtherAction') {
      # TODO error handling
      # TDOO This has never run. This is untested.
      if (!Action->byName($on)->isa('Action')) {
        warn "need an action to act";
	next;
      }
      Action->byName($on)->act;
      next;
    }
    warn sprintf "NOT IMPLMENTED: should act like %s on ''%s'';\n",
     $act, $on;
    next;
  }
  printf "%s: %4d: ->act()ed successfully\n", __PACKAGE__, __LINE__; # muell
  return 1; # oder was?
}
1;
