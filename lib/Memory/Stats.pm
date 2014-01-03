package Memory::Stats;

# ABSTRACT: Memory Usage Consumption of your process

use strict;
use warnings;
# VERSION
use Proc::ProcessTable;
use Carp qw/croak/;
use Moo;

my $pt = Proc::ProcessTable->new;
my $current_memory_usage;
my $delta_memory_usage;

sub _get_current_memory_usage {
	my %info = map { $_->pid => $_ } @{$pt->table};
	return $info{$$}->rss;
}

=method start

Init the recording

=cut
sub start {
	$current_memory_usage = _get_current_memory_usage();
	return;
}

=method stop

Stop the recording

=cut
sub stop {
	croak "Please call the method 'start' first !" if !defined $current_memory_usage;
	$delta_memory_usage = _get_current_memory_usage() - $current_memory_usage;
	$current_memory_usage = undef;
	return;
}

=method get_memory_usage

Return the last recording memory in KB

=cut
sub get_memory_usage {
	croak "Please call the method 'start' then 'stop' first !" if !defined $delta_memory_usage;
	return $delta_memory_usage;
}

1;

__END__
=head1 SYNOPSIS

  use Memory::Stats;

  my $stats = Memory::Stats->new;

  $stats->start;
  # do something
  $stats->stop;
  say "Memory consumed : ", $stats->get_memory_usage;

