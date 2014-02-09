package Memory::Stats;

# ABSTRACT: Memory Usage Consumption of your process

use strict;
use warnings;
# VERSION
use Proc::ProcessTable;
use Carp qw/croak/;
use Moo;

my $pt = Proc::ProcessTable->new;

has '_memory_usage' => (is => 'rw', default => sub {[]});

sub _get_current_memory_usage {
  my ($info) = grep { $_->pid eq $$ } @{$pt->table};
  my $memory_usage;
  eval { $memory_usage = $info->rss };
  return $@ ? -1 : $memory_usage;
}

=method start

 $mu->start

=cut
sub start {
  my $self = shift;
  $self->_memory_usage([["start",_get_current_memory_usage()]]);
	return;
}

=method checkpoint

Mark a step in the recording,

  $mu->checkpoint('title of the checkpoint');

=cut
sub checkpoint {
  my $self = shift;
  my $title = shift // 'checkpoint';
  croak "Please start first !" if ! scalar @{$self->_memory_usage} || $self->_memory_usage->[-1][0] eq 'stop';
  push @{$self->_memory_usage}, [$title, _get_current_memory_usage()];
  return;
}

=method stop

Stop the recording

=cut
sub stop {
  my $self = shift;
  croak "Please start first !" if ! scalar @{$self->_memory_usage} || $self->_memory_usage->[-1][0] eq 'stop';
  push @{$self->_memory_usage}, ['stop', _get_current_memory_usage()];
	return;
}


=method delta_usage

Get the current delta memory usage since the last checkpoint

  $mu->start;
  ...
  say $mu->delta_usage

=cut
sub delta_usage {
  my $self = shift;
  my $last_memory_usage = $self->_memory_usage->[-1][1]
    or return;
  return (_get_current_memory_usage() - $last_memory_usage);
}

=method usage

Get the full usage

  $mu->start;
  ...
  $mu->stop;

  say "Memory::Usage: ", $mu->usage;

=cut
sub usage {
  my $self = shift;
  croak "Please start and stop before !" if scalar @{$self->_memory_usage} < 2 || $self->_memory_usage->[-1][0] ne 'stop';
  return $self->_memory_usage->[-1][1] - $self->_memory_usage->[0][1];

}


=method dump

Dump the full stack

=cut

sub dump {
  my $self = shift;
  print "--- Memory Usage ---\n";
  my $prev;
  for my $row(@{$self->_memory_usage}) {
    if ($prev) {
      if ($row->[0] eq 'stop') {
        printf("%s: %d - delta: %d - total: %d\n", @$row, $row->[1] - $prev, $row->[1] - $self->_memory_usage->[0][1]);
      } else {
        printf("%s: %d - delta: %d\n", @$row, $row->[1] - $prev);
      }
    } else {
      printf("%s: %d\n", @$row);
    }
    $prev = $row->[1];
  }
  print "--- Memory Usage ---\n";
}

1;

__END__
=head1 SYNOPSIS

  use Memory::Stats;

  my $stats = Memory::Stats->new;

  $stats->start;
  # do something
  $stats->stop;
  say "Memory consumed: ", $stats->get_memory_usage;

=head1 DESCRIPTION

This module give you the memory usage (resident RSS), of a part of your process. It use L<Proc::ProcessTable> and should work on all platforms supported by this module.

You can check this link to for explanation: L<http://blog.celogeek.com/201312/394/perl-universal-way-to-get-memory-usage-of-a-process/>

