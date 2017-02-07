#!/usr/bin/perl

use File::Basename;
@command = split /\s+/, basename($0);
@fn = split /\./, $command[0];

%rg = (
    'opt', 'debug-flat',
    'old', 'debug-flat',
    'prof', 'debug-flat',
    'prof_mid', 'debug-flat',
    'prof_prev', 'debug-flat',
    'manyconn', 'debug-flat',
    'intel', 'debug-flat',
    );

%mpicc = (
    'opt', '/work/0/gg10/e29005/project/mpich/install_opt/bin/mpicc',
    'old', '/work/0/gg10/e29005/project/mpich/install_old/bin/mpicc',
    'prof', '/work/0/gg10/e29005/project/mpich/install_prof/bin/mpicc',
    'prof_mid', '/work/0/gg10/e29005/project/mpich/install_prof_mid/bin/mpicc',
    'prof_prev', '/work/0/gg10/e29005/project/mpich/install_prof_prev/bin/mpicc',
    'manyconn', '/work/0/gg10/e29005/project/mpich/install_manyconn/bin/mpicc',
    'intel', 'mpiicc',
    );

%mpiexec = (
    'opt', '/work/0/gg10/e29005/project/mpich/install_opt/bin/mpiexec.hydra',
    'old', '/work/0/gg10/e29005/project/mpich/install_old/bin/mpiexec.hydra',
    'prof', '/work/0/gg10/e29005/project/mpich/install_prof/bin/mpiexec.hydra',
    'prof_mid', '/work/0/gg10/e29005/project/mpich/install_prof_mid/bin/mpiexec.hydra',
    'prof_prev', '/work/0/gg10/e29005/project/mpich/install_prof_prev/bin/mpiexec.hydra',
    'manyconn', '/work/0/gg10/e29005/project/mpich/install_manyconn/bin/mpiexec.hydra',
    'intel', 'mpiexec.hydra',
    );

%prof = (
    'opt', '',
    'old', '',
    'prof', '',
    'prof_mid', '',
    'prof_prev', '',
    'manyconn', '',
    'intel', '',
    );

%limit = (
'1', '00:10:00',
'2', '00:10:00',
'4', '00:10:00',
'8', '00:10:00',
'16', '00:10:00',
'32', '00:10:00',
'64', '00:05:00',
'128', '00:05:00',
'256', '00:10:00',
'512', '00:15:00',
'1024', '00:15:00',
'2048', '00:30:00',
    );

$dir=$ARGV[2].'_'.$ARGV[0].'_'.$ARGV[1].'_'.`date +%Y%m%d_%H%M%S`;
print $dir."\n";
chomp($dir);
mkdir $dir;
chdir $dir;
open(IN, "../$fn[0].sh.in");
open(OUT, ">./job.sh");
while(<IN>) {
    s/\@jobname@/$fn[0]/g;
    s/\@nprocs@/$ARGV[0]/g;
    s/\@nnodes@/$ARGV[1]/g;
    s/\@rg@/$rg{$ARGV[2]}/g;
    s/\@mpiexec@/$mpiexec{$ARGV[2]}/g;
    s/\@limit@/$limit{$ARGV[1]}/g;
    print OUT $_;
}
close(IN);
close(OUT);

system("gcc -O2 ../gettimeofday.c -o ./gettimeofday");
system("$mpicc{$ARGV[2]} $prof{$ARGV[2]} ../$fn[0].c -o $fn[0]");
system("pjsub -m b -s -L proc-crproc=16384 ./job.sh");
