require 5.008;
use threads (); # just to force breakage if threads are not available
use ExtUtils::MakeMaker;
eval "use Devel::Required";

BEGIN {
    die "Doesn't make sense to install Thread::Detach on this system\n"
     unless ($^O =~ m#Win32# or $ENV{THIS_IS_WIN32}) and
      $] < 5.008004 # not sure what to do about blead...
    ;
} #BEGIN

WriteMakefile (
 NAME		=> "Thread::Detach",
 AUTHOR		=> 'Elizabeth Mattijsen (liz@dijkmat.nl)',
 ABSTRACT	=> 'fix broken threads->detach on Windows',
 VERSION_FROM	=> 'lib/Thread/Detach.pm',
 PREREQ_PM	=> { qw(
		    Thread::Exit   0.08
                   )},
);
