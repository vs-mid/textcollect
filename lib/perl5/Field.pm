package Field;

# meant to tell what to do with the contents of a field

use parent qw(Named);

# Configuration: Action
# TODO No: Configuration: Keep. That's how we intend to keep the values.

# We keep the value of one field in here.

sub new {
  my ($proto, $name, $actas) = (@_);

  my $class = ref $proto || $proto;
  my $self = $proto->SUPER::new($name);
  $self->actas($actas);
  return $self;
}
##
# Actually, we should not need to change that after instantiation.
sub actas {
  my ($self, $actas) = (@_);

  if (defined $actas) {
    return $self->{'actas'} = $actas;
  }
  return $self->{'actas'};
}
##
# Args
#
#   $value -- a scalar we act on.
#
# TODO since we want to be able to pile up values in a list,
# we may want to have $value be a Perl object rather than
# a scalar or an array ref. Change things accordingly.
sub value {
  my ($self, $value) = (@_);

  if (defined $value) {
    if ($self->actas() eq 'AssertEqual') {
      if (defined $self->{'value'}) {
        if ($value ne $self->{'value'}) {
	  warn sprintf "%s ''%s'': won't change value ''%s'' to ''%s''",
	   ref $self, $self->name, $self->{'value'}, $value;
	  return undef;
	}
	return $self->{'value'};
      }
      return $self->{'value'} = $value;

    # don't allow setting a value that's defined
    } elsif ($self->actas() eq 'AssertUnique') {
      if (defined $self->value()) {
        warn sprintf "%s ''%s'': value ''%s'' unexpected new value ''%s''",
	 ref $self, $self->name, $self->{'value'}, $value;
        return undef;
      }
      return $self->{'value'} = $value;

    # keep a list of values
    } elsif ($self->actas() eq 'Push') {
      push @{$self->{'value'}}, $value;
      return $self->{'value'};

    # replace the value
    } elsif ($self->actas() eq 'Update') {
      return $self->{'value'} = $value;

    } elsif ($self->actas() eq 'Append') {
      if (defined ($self->{'value'})) {
        $self->{'value'} .= "\n$value";
      } else {
        $self->{'value'} = $value;
      }
      return $self->{'value'};
    }
    warn sprintf "can't make sense of how to Collect (%s)", $self->actas();
    return undef;
  }
  return $self->{'value'};
}
##
# replaces the value with undef
sub deleteValue {
  my ($self) = (@_);

  printf "%s: %s: deleting the value.\n", __PACKAGE__, $self->name;
  $self->{'value'} = undef;
}
1;
