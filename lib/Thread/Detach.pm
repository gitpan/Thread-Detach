package Thread::Detach;

# Make sure we have version info for this module

$VERSION = '0.01';

# Make sure we do this before anything else
#  If we're on a Windows system, or we fake it to be a Win32 system
#   If we have a crippled detach
#    Make sure we do everything by the book from now on
#    Make sure we can do threads
#    Make sure we can do shared variables
#    Create the hash that keeps detached information
#    Create the hash that keeps threads that are done information

BEGIN {
    if ($^O =~ m#Win32# or $ENV{THIS_IS_WIN32}) {
        if ($] < 5.008004) {  # not sure what to do about blead...
            use strict;
            require threads;
            require threads::shared;
            my %detached : shared;
            my %done : shared;

#    Get Thread::Exit
#    Set up the necessary Thread::Exit capabilities
#     Make sure that all subsequent threads get the same

            require Thread::Exit;
            Thread::Exit->import( 
             inherit => 1,

#     Begin each thread with
#      Lock the detached threads hash
#      For each detached thread
#       Reap the thread if it was detached and is now done

             begin => sub {
                 lock( %done );
                 while (my $tid = each %done) {
                     threads->object( $tid )->join if delete $done{$tid};
                 }
             },

#     End this thread with
#      Mark this thread as done

             end => sub { $done{threads->tid} = 1 }
            );

#    Allow for dirty tricks
#    Replace the detach method with one that just sets the detached flag

            no warnings 'redefine';
            *threads::detach = sub { $detached{threads->tid} = 1 };
        }
    }
} #BEGIN

# Satisfy -require-

1;

#---------------------------------------------------------------------------

__END__

=head1 NAME

Thread::Detach - fix broken threads->detach on Windows

=head1 SYNOPSIS

    use Thread::Detach ();   # apply the fix

=head1 DESCRIPTION

                  *** A note of CAUTION ***

 This module only functions on Perl versions 5.8.0 and later.
 And then only when threads are enabled with -Dusethreads.  It
 is of no use with any version of Perl before 5.8.0 or without
 threads enabled.

                  *************************

Perl versions before 5.8.4 don't support the "detach" method of the L<threads>
module B<on Windows>!.  This module provides a temporary fix for this problem
if it is running under Windows and with a version of Perl that has the problem.
In any other situation, this module does B<nothing>.

=head1 THEORY OF OPERATION

All of this happens on Windows B<only> and if the version of the Perl executor
is known to have the problem.

This module replaces the standard C<threads->detach> method with another
subroutine that just sets an internal flag to mark the thread as "detached".

Futhermore it uses L<Thread::Exit> to register a subroutine that is executed
after each thread is finished executing: this subroutine marks the thread as
"done" if the thread was marked as "detached" earlier.

Lastly, it uses L<Thread::Exit> to register a subroutine that is executed
at the beginning of each thread: this subroutine reaps all the threads that
were marked "done", hence providing the necessary cleanup.

=head1 REQUIRED MODULES

 Thread::Exit (0.08)

=head1 TODO

Maybe the reliance on Thread::Exit should be replaced by some more direct
magic.  Using Thread::Exit made this module all the more simple, though.

Examples should be added.

=head1 AUTHOR

Elizabeth Mattijsen, <liz@dijkmat.nl>.

Please report bugs to <perlbugs@dijkmat.nl>.

=head1 COPYRIGHT

Copyright (c) 2004 Elizabeth Mattijsen <liz@dijkmat.nl>. All rights
reserved.  This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=head1 SEE ALSO

L<threads>, L<Thread::Exit>.

=cut
