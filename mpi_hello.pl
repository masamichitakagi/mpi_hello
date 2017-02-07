#!/usr/bin/perl

use File::Basename;
@command = split /\s+/, basename($0);
@fn = split /\./, $command[0];

if($ARGV[1] <= 128) {
    $rg = 'debug-flat';
} else {
    $rg = 'regular-flat';
}

$prefix = '/work/0/gg10/e29005/project/mpich/install';
$post_mpicc = '/bin/mpicc';

%mpicc = (
    'opt', $prefix.'_opt'.$post_mpicc,
    'old', $prefix.'_old'.$post_mpicc,
    'prof', $prefix.'_prof'.$post_mpicc,
    'prof_mid', $prefix.'_prof_mid'.$post_mpicc,
    'prof_prev', $prefix.'_prof_prev'.$post_mpicc,
    'manyconn', $prefix.'_manyconn'.$post_mpicc,
    'intel', 'mpiicc',
    );

$post_mpiexec = '/bin/mpiexec.hydra';
%mpiexec = (
    'opt', $prefix.'_opt'.$post_mpiexec,
    'old', $prefix.'_old'.$post_mpiexec,
    'prof', $prefix.'_prof'.$post_mpiexec,
    'prof_mid', $prefix.'_prof_mid'.$post_mpiexec,
    'prof_prev', $prefix.'_prof_prev'.$post_mpiexec,
    'manyconn', $prefix.'_manyconn'.$post_mpiexec,
    'intel', 'mpiexec.hydra',
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
    s/\@rg@/$rg/g;
    s/\@mpiexec@/$mpiexec{$ARGV[2]}/g;
    s/\@limit@/$limit{$ARGV[1]}/g;
    print OUT $_;
}
close(IN);
close(OUT);

system("gcc -O2 ../gettimeofday.c -o ./gettimeofday");
system("$mpicc{$ARGV[2]} ../$fn[0].c -o $fn[0]");
system("pjsub -m b -s -L proc-crproc=16384 ./job.sh");
