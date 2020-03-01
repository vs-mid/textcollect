package Cf;

# makes available some global Configuration

# TODO currently this is only a simple way to pass the global
# Output object from the main program to the Action class.

# We are using this to make available an Output object rather
# than textual values that could come from a Configuration file.

use warnings;
use strict;

use parent qw(Named);

##
# A Cf is named, that's all. For now.
sub new {
  my ($proto, $name) = (@_);

  my $class = ref $proto || $proto;
  my $self = $proto->SUPER::new($name);
  return $self;
}
##
# gets or sets the Output object to use
#
# TODO instead of having Cf return the Output object, we may
# choose an Output object using a class method of Output, like
#
#   Output->byName('Excel');
# (TODO Umm --, why?)
sub value {
  my ($self, $value) = (@_);

  if (defined $value) {
    return $self->{'value'} = $value;
  }
  return $self->{'value'};
}
##
# meant to allow destruction of the thing ref'd
#
# TODO Do we need to use this?
sub deleteValue {
  my ($self) = (@_);

  $self->{'value'} = undef;
  return $self;
}
1;
