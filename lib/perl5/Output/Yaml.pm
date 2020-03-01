package Output::Yaml;

use warnings;
use strict;

use IO::File;

use Output::Context::Yaml;

# TODO we'd better inherit from something like Output::ToFile
# and save ourselves from typing in ->new().
use parent qw(Output);

sub new {
  my ($proto, $outputfilename) = (@_);

  my $self = $proto->SUPER::new;

  my $fh = IO::File->new(">$outputfilename");
  if (!defined $fh) {
    warn "cannot write file $outputfilename";
    return undef;
  }
  $self->{'outputfilehandle'} = $fh;
  return $self;
}
sub emit {
  my ($self, $text) = (@_);

  print "EMISSION, the very one.\n"; # muell
  my $fh = $self->{'outputfilehandle'};
  print $fh "$text\n";
  return $self;
}
sub getOutputContext {
  my ($self, $id) = (@_);

  return $self->registerOutputContext(Output::Context::Yaml->new($id, $self));
}
1;
