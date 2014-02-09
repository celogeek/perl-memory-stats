package Memory::Stats;

# ABSTRACT: Memory Usage Consumption of your process

use strict;
use warnings;
# VERSION
use Proc::ProcessTable;
use Carp qw/croak/;
use Moo;
use MooX::PrivateAttributes;

my $pt = Proc::ProcessTable->new;

private_has '_current_memory_usage' => (is => 'rw');
private_has '_delta_memory_usage' => (is => 'rw');

sub _get_current_memory_usage {
	my %info = map { $_->pid => $_ } @{$pt->table};
	return $info{$$}->rss;
}

=method start

Init the recording

=cut
sub start {
  shift->_current_memory_usage(_get_current_memory_usage);
	return;
}

=method stop

Stop the recording

=cut
sub stop {
  my $self = shift;
	croak "Please call the method 'start' first !" if !defined $self->_current_memory_usage;
	$self->_delta_memory_usage(_get_current_memory_usage() - $self->_current_memory_usage);
	$self->_current_memory_usage(undef);
	return;
}

=method get_memory_usage

Return the last recording memory in KB

=cut
sub get_memory_usage {
  my $self = shift;
	croak "Please call the method 'start' then 'stop' first !" if !defined $self->_delta_memory_usage;
	return $self->_delta_memory_usage;
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

=head1 DESCRIPTION

This module give you the memory usage (resident RSS), of a part of your process. It use L<Proc::ProcessTable> and should work on all platforms supported by this module.

You can check this link to for explanation : L<http://blog.celogeek.com/201312/394/perl-universal-way-to-get-memory-usage-of-a-process/>

