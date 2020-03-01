package Output::Context::Yaml;

use warnings;
use strict;

use parent qw(Output::Context);

sub new {
  my ($proto, $id, $output) = (@_);

  printf "%s: %4d: an output is a %s;\n", __PACKAGE__, __LINE__, ref $output; # muell
  my $self = $proto->SUPER::new($id, $output);
  # $self->{'indentlevel'} = 0;
  $self->{'numberofthings'} = 0;
  $self->{'piledupforemission'} = [ "$id:" ];
  return $self;
}
sub emit {
  my ($self, $thing) = (@_);

  printf "emit(): EMISSION will be using a ''%s'';\n", ref $self->output; # muell
  my $prematerial;
  if (++$self->{'numberofthings'} == 1) {
    $prematerial = "  - ";
  } else {
    $prematerial = " " x 4;
  }
  my $value = $thing->value;
  if (ref $value eq 'ARRAY') {
    push @{$self->{'piledupforemission'}}, sprintf("%s%s: |",
     $prematerial, $thing->name);
    foreach my $line (@$value) {
      push @{$self->{'piledupforemission'}}, sprintf("%s  %s", $prematerial, $line);
    }
    # printf "Piled up: %s;\n", join '\n', @{$self->{'piledupforemission'}}; # muell
  } else {
    push @{$self->{'piledupforemission'}}, sprintf ("%s%s: %s",
     $prematerial, $thing->name, $thing->value);
  }
  return $self;
}
sub newline {
  my ($self) = (@_);

  $self->{'numberofthings'} = 0;
  printf "%s %4d: Still seeing a ''%s'' as an Output;\n", __PACKAGE__, __LINE__, ref $self->output; # muell
  return $self;
}
sub closeContext {
  my ($self) = (@_);

  printf "closeContext(): EMISSION will be using a ''%s'';\n", ref $self->output; # muell
  print "closeContext(): "; # muell
  printf "EMISSION of a pile of stuff: %s (%s lines);\n", # muell
   $self->id, # muell
   $#{$self->{'piledupforemission'}} + 1; # muell
  foreach my $line (@{$self->{'piledupforemission'}}) {
    printf "    EMISSION of a line using a %s: %s;\n", ref $self->{'Output'}, $line; # muell
    $self->output->emit($line);
  }
  print "EMISSION DONE.\n";
  #$self->output->emit(join "\\n", @{$self->{'piledupforemission'}});
}
1;
