BEGIN {				# Magic Perl CORE pragma
    if ($ENV{PERL_CORE}) {
        chdir 't' if -d 't';
        @INC = '../lib';
    }
}

use Test::More tests => 3;
use strict;
use warnings;

use threads;
use threads::shared;

use_ok( 'Thread::Detach' ); # just for the record

ok( my $thread = threads->new( sub { 1 } ), "Start thread\n" );
$thread->detach;
eval {$thread->join};
ok( !$@,"Check whether detached thread could be joined ok" );
