#!perl

use Test::More;
use Memory::Stats;

my $stats = Memory::Stats->new;

ok !eval {$stats->stop; 1}, 'start recording first';
like $@, qr{\QPlease call the method 'start' first !\E}, 'error message ok';

ok !eval {$stats->get_memory_usage; 1}, 'start and stop recording first';
like $@, qr{\QPlease call the method 'start' then 'stop' first !\E}, 'error message ok';

$stats->start;
my %c = map { $_ => 1 } (1..100_000);
ok !eval {$stats->get_memory_usage; 1}, 'start and stop recording first';
like $@, qr{\QPlease call the method 'start' then 'stop' first !\E}, 'error message ok';
$stats->stop;
like $stats->get_memory_usage, qr{^\d+$}, 'memory usage ok';

done_testing;
