package RePlus;

# keeps an RE plus more

# This provides methods to test against the RE, report if there's
# a match, and bite out values from the sample.

# We'll use this to get values out of a string. Eventually, we
# may want named values. In this case, each pair of parenthesis
# will have to have a name associated with it.

use parent qw(Named);

##
# Configuration: Arg $re
#
# Args
#
#   $re -- may contain pairs of ()s, as Perl is used to
sub new {
  my $proto = shift;
  my ($name, $re) = (@_);

  my $class = ref $proto || $proto;

  my $self = $proto->SUPER::new($name);
  $self->re($re);
  return $self;
}
##
# gets or sets the RE
sub re {
  my ($self, $re) = (@_);

  if (defined $re) {
    return $self->{'re'} = $re;
  } else {
    return $self->{'re'};
  }
}
##
# gives names to the things bit out
#
# Args
#
#   @names -- we're not keeping a copy, so don't change these
#
# Mo 25. Jan 18:27:09 CET 2016 -- vs -- TODO @names in documentation, while $matchNames in the sub def.
#   Check doc.
sub namesForMatches {
  my ($self, $matchNames) = (@_);

  if ($#{$matchNames} >= 0) {
    my (%matches, @names); for my $name (@$matchNames) {
      push @names, $name;
      # TODO maybe check here for name dupes
      $matches{$name} = undef;
    }
    $self->{'namesForMatches'} = \@names;
    $self->{'matchesByName'} = \%matches;
    return $matchNames;
  } else {
    return exists $self->{'namesForMatches'} ? $self->{'namesForMatches'} : [];
  }
}
##
# tests a string against the RE
#
# Returns
#
#   whether there's a match
sub test {
  my ($self, $against) = (@_);

  my $re = $self->re();
  my $r = $against =~ /$re/;

  if (0) {
  if ($r) {
    printf "RE matched: %s;\n", $self->name; # muell
  } else {
    printf "RE no match: %s \"%s\" against /%s/;\n", $self->name, $against, $re; # muell
  }
  }

  my $matches = $self->{'matchesByName'};
  my $matchnames = $self->namesForMatches;
  foreach my $i (0 .. @{$self->namesForMatches}) {
    my $thisMatch = ${$i + 1};
    last unless defined $thisMatch;
    $matches->{$matchnames->[$i]} = ${$i + 1};
  }
  return $r;
} 
##
# Returns
#
#   what the RE bit out
#
# Args
#
#   $name -- a name for a mouthful
sub extract {
  my ($self, $name) = (@_);

  return $self->{'matchesByName'}{$name};
}
1;
