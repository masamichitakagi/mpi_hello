#!/usr/bin/perl

print $ARGV[0]."\n";
print "\n";
$ARGV[0] =~ /[^_]+_\d+_(\d+)_/;
print "$1\n";

$rank = 0;
@lines = <>;
foreach (@lines) {
    if($_ =~ /Before-mpiexec ([0-9\.]+)/) {
        $before_mpiexec = $1; #print $1."bm\n";
    }
    if($_ =~ /\[$rank\] Before-MPI_Init ([0-9\.]+)/) {
        $before_mpi_init = $1; #print $1."bi\n";
    }
    if($_ =~ /\[$rank\] After-MPI_Finalize ([0-9\.]+)/) {
        $after_mpi_finalize = $1; #print $1."af\n";
    }
    if($_ =~ /After-mpiexec ([0-9\.]+)/) {
        $after_mpiexec = $1; #print $1."am\n";
    }
    if($_ =~ /real\s+([0-9]+)m([0-9\.]+)s/) {
        $real_min = $1; $real_sec = $2; #print "$1m$2s\n";
    }
    if($_ =~ /bcast_keyvals ([0-9\.]+) ([0-9\.]+)/) {
	$time = $1;
	$ts = $2;
        push @time_bcast, $time;
	push @ts_bcast, $ts;
	#print $time.' '.$ts."\n";
    }
    if($_ =~ /put_sum ([0-9\.]+) ([0-9\.]+)/) {
	$time = $1;
	$ts = $2;
        push @time_put_sum, $time;
	push @ts_put_sum, $ts;
	#print $time.' '.$ts."\n";
    }
}

$delim = " ";
printf("${delim}%f\n",  $before_mpi_init - $before_mpiexec); # process launch

foreach (@lines) {
    if($_ =~ /\[$rank\] (MPII_Comm_init) ([0-9\.]+)/) {
        printf("${delim}${delim}${delim}%f\n", $2); # MPI_Init()->MPIR_Init_thread()->MPII_Comm_init
    }
    if($_ =~ /\[$rank\] (PMI_Init) ([0-9\.]+)/) {
        printf("${delim}${delim}${delim}${delim}%f\n", $2); # MPI_Init()->MPIR_Init_thread()->MPID_Init()->PMI_Init()
    }
    if($_ =~ /\[$rank\] (av_insert-PMI_Barrier|shm_seg_commit-PMI_Barrier) ([0-9\.]+) ([0-9\.]+)/) {
	$section = $1;
	$ndelim = $section eq 'av_insert-PMI_Barrier' ? 5 : 6;
	$time_bar = $2;
	$ts_bar = $3;
	#print 'ts_bar='.$ts_bar.' ts_bcast='.$ts_bcast[0].' time_bcast='.$time_bcast[0].' #ts_bcast='.$#ts_bcast."\n";

	$time = 0;
	if($#ts_put_sum >= 0 && $ts_put_sum[0] < $ts_bar) {
	    $time = shift(@time_put_sum);
	    shift(@ts_put_sum);
	}
	foreach (1..($ndelim+1)) { print $delim; } printf("%f\n", $time);

	$time = 0;
	if($#ts_bcast >= 0 && $ts_bcast[0] < $ts_bar) {
	    $time = shift(@time_bcast);
	    shift(@ts_bcast);
	}
	foreach (1..($ndelim+1)) { print $delim; } printf("%f\n", $time);

        foreach (1..$ndelim) { print $delim; } printf("%f\n", $time_bar); # MPI_Init()->MPIR_Init_thread()->MPID_Init()->MPIDI_(NM|SHM)_mpi_init_hook()->stmts
    } elsif($_ =~ /\[$rank\] (provider_init1|av_insert|shm_posix_init)\S+ ([0-9\.]+)/) {
        printf("${delim}${delim}${delim}${delim}${delim}%f\n", $2); # MPI_Init()->MPIR_Init_thread()->MPID_Init()->MPIDI_(NM|SHM)_mpi_init_hook()->stmts
    } elsif($_ =~ /\[$rank\] (shm_seg_commit)\S+ ([0-9\.]+)/) {
        foreach (1..6) { print $delim; } printf("%f\n", $2); # MPI_Init()->MPIR_Init_thread()->MPID_Init()->MPIDI_(NM|SHM)_mpi_init_hook()->shm_seg_commit()->stmts
    } 
    if($_ =~ /\[$rank\] (provider_init2)\S+ ([0-9\.]+)/) {
        printf("${delim}${delim}${delim}${delim}${delim}${delim}%f\n", $2); # MPI_Init()->MPIR_Init_thread()->MPID_Init()->MPIDI_(NM|SHM)_mpi_init_hook()->block->stmts
    }
    if($_ =~ /\[$rank\] MPIDI_(NM|SHM)_mpi_init_hook ([0-9\.]+)/) {
        printf("${delim}${delim}${delim}${delim}%f\n", $2); # MPI_Init()->MPIR_Init_thread()->MPID_Init()->MPIDI_(NM|SHM)_mpi_init_hook()
    }
    if($_ =~ /\[$rank\] (MPID_Init) ([0-9\.]+)/) {
        printf("${delim}${delim}${delim}%f\n", $2); # MPI_Init()->MPIR_Init_thread()->MPID_Init()
    }
    if($_ =~ /\[$rank\] (MPIR_Init_thread) ([0-9\.]+)/) {
        printf("${delim}${delim}%f\n", $2); # MPI_Init()->MPIR_Init_thread()
    }
    if($_ =~ /\[$rank\] (MPID_Finalize) ([0-9\.]+)/) {
        printf("${delim}${delim}%f\n", $2); # MPI_Finalize()->MPID_Finalize()
    }
    if($_ =~ /\[$rank\] (MPI_Finalize\S+) ([0-9\.]+)/) {
        printf("${delim}${delim}%f\n", $2); # MPI_Finalize()->stmts
    }
    if($_ =~ /\[$rank\] (main-MPI_Finalize|main-MPI_Init) ([0-9\.]+)/) {
        printf("${delim}%f\n", $2); # MPI_Init()|MPI_Finalize()
    }
#     if($_ =~ /\[$rank\] (MPI_Finalize|MPI_Init) ([0-9\.]+)/) {
#         printf("${delim}%f\n", $2); # MPI_Init()|MPI_Finalize()
#     }
 }

printf("${delim}%f\n",  $after_mpiexec - $after_mpi_finalize);
printf("%f\n", $real_min*60+$real_sec);
