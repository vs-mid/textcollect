package Named;

# We want to refer to something by a name. That name should be given
# in Configuration. We want to be able to find Named things by
# calling them with their name. We want to find out if a thing by a
# given name exists. We give a thing a name upon its creation.

# Is Named a factory class? Rather not. We still use the
# constructor of the thing we want to use.

# TODO Consider this: Use this as a factory for objects that we
# will reference by names later. Instantiate these objects by
# handing over to them an object that provides Configuration.
#
# Get that Configuration from a Config file, eventually.

our %byTypeAndName; # well, all the objects

##
# So that there's an instance of this
sub new {
  my $proto = shift;
  my $name = shift;

  my $class = ref $proto || $proto;
  if (!defined $name or ref $name ne '') {
    warn "A $class is Named, so wants a name";
    return undef;
  }

  my $self = {};
  bless $self, $class;
  $self->giveName($name);
  return $self;
}
##
# tells our name
#
# accessor
sub name {
  my $self = shift;
  my $nono = shift;

  if (defined $nono) {
    warn "WASNICHRICHTICH: can't rename";
  }

  return $self->{'name'};
}
##
# gives a us a name
sub giveName {
  my ($self, $name) = (@_);

  my $ourType = ref $self;

  if (exists $byTypeAndName{$ourType}{$name}) {
    # TODO mention the type of $self?
    warn sprintf "a %s named ''%s'' exists", ref $self, $name;
    return $self; # TODO or return undef?
  }
  if (exists $self->{'name'}) {
    warn "WASNICHRICHTICH: don't rename";
    return $self;
  }
  $self->{'name'} = $name;
  return $byTypeAndName{$ourType}{$name} = $self;
}

##
# Returns
#
#   a thing if there's one by a given name or
#   undef otherwise
#
# This may be used as a class method
sub byName {
  my ($self, $name) = (@_);

  my $ourType = ref $self || $self; # TODO does that work as a class method?

  if (exists $byTypeAndName{$ourType}{$name}) {
    return $byTypeAndName{$ourType}{$name};
  }
  warn sprintf "%s: nothing known named ''%s''", $ourType, $name;
  return undef;
}
##
#
sub type {
  my $self = shift;

  return ref $self || $self;
}
sub namesAndThings {
  my $self = shift;

  my $ourType = ref $self || $self;
  printf "%s: %4d: our type: %s;\n", __PACKAGE__, __LINE__, $ourType; # muell
  return \%{$byTypeAndName{$ourType}};
}
1;
