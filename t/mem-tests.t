#!perl

use Test::More;
use Memory::Stats;

my $stats = Memory::Stats->new;
my $stats2 = Memory::Stats->new;

ok !eval {$stats->stop; 1}, 'start recording first';
like $@, qr{\QPlease call the method 'start' first !\E}, 'error message ok';

ok !eval {$stats->get_memory_usage; 1}, 'start and stop recording first';
like $@, qr{\QPlease call the method 'start' then 'stop' first !\E}, 'error message ok';

$stats->start;
$stats2->start;

my %c = map { $_ => 1 } (1..100_000);
ok !eval {$stats->get_memory_usage; 1}, 'start and stop recording first';
like $@, qr{\QPlease call the method 'start' then 'stop' first !\E}, 'error message ok';
$stats->stop;

%c = map { $_ => 1 } (1..200_000);
$stats2->stop;

like $stats->get_memory_usage, qr{^\d+$}, 'memory usage ok';
like $stats2->get_memory_usage, qr{^\d+$}, 'memory usage ok';
ok $stats->get_memory_usage < $stats2->get_memory_usage, 'second stats should be greater than the first one';

done_testing;
