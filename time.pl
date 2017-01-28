#!/usr/bin/perl

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
}

printf(",%f\n",  $before_mpi_init - $before_mpiexec); # process launch

foreach (@lines) {
    if($_ =~ /\[$rank\] (MPII_Comm_init) ([0-9\.]+)/) {
        printf(",,,%f\n", $2); # MPI_Init()->MPIR_Init_thread()->MPII_Comm_init
    }
    if($_ =~ /\[$rank\] (PMI_Init) ([0-9\.]+)/) {
        printf(",,,,%f\n", $2); # MPI_Init()->MPIR_Init_thread()->MPID_Init()->PMI_Init()
    }
    if($_ =~ /\[$rank\] (provider_init1|av_insert|shm_posix_init)\S+ ([0-9\.]+)/) {
        printf(",,,,,%f\n", $2); # MPI_Init()->MPIR_Init_thread()->MPID_Init()->MPIDI_(NM|SHM)_mpi_init_hook()->stmts
    }
    if($_ =~ /\[$rank\] (provider_init2)\S+ ([0-9\.]+)/) {
        printf(",,,,,,%f\n", $2); # MPI_Init()->MPIR_Init_thread()->MPID_Init()->MPIDI_(NM|SHM)_mpi_init_hook()->block->stmts
    }
    if($_ =~ /\[$rank\] MPIDI_(NM|SHM)_mpi_init_hook ([0-9\.]+)/) {
        printf(",,,,%f\n", $2); # MPI_Init()->MPIR_Init_thread()->MPID_Init()->MPIDI_(NM|SHM)_mpi_init_hook()
    }
    if($_ =~ /\[$rank\] (MPID_Init) ([0-9\.]+)/) {
        printf(",,,%f\n", $2); # MPI_Init()->MPIR_Init_thread()->MPID_Init()
    }
    if($_ =~ /\[$rank\] (MPIR_Init_thread) ([0-9\.]+)/) {
        printf(",,%f\n", $2); # MPI_Init()->MPIR_Init_thread()
    }
    if($_ =~ /\[$rank\] (MPID_Finalize) ([0-9\.]+)/) {
        printf(",,%f\n", $2); # MPI_Finalize()->MPID_Finalize()
    }
    if($_ =~ /\[$rank\] (MPI_Finalize\S+) ([0-9\.]+)/) {
        printf(",,%f\n", $2); # MPI_Finalize()->stmts
    }
    if($_ =~ /\[$rank\] (MPI_Finalize|MPI_Init) ([0-9\.]+)/) {
        printf(",%f\n", $2); # MPI_Init()|MPI_Finalize()
    }
}

printf(",%f\n",  $after_mpiexec - $after_mpi_finalize);
printf("%f\n", $real_min*60+$real_sec);
