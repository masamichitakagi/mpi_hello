#!/usr/bin/perl

$rank = 0;
while(<>) {
    if($_ =~ /Before-mpiexec ([0-9\.]+)/) { $before_mpiexec = $1; #print $1."bm\n";
    }
    if($_ =~ /After-mpiexec ([0-9\.]+)/) { $after_mpiexec = $1; #print $1."am\n";
    }
    if($_ =~ /\[$rank\] Before-MPI_Init ([0-9\.]+)/) { $before_mpi_init = $1; #print $1."bi\n";
}
    if($_ =~ /\[$rank\] After-MPI_Init ([0-9\.]+)/) { $after_mpi_init = $1; #print $1."ai\n";
}
    if($_ =~ /\[$rank\] Before-MPI_Finalize ([0-9\.]+)/) { $before_mpi_finalize = $1; #print $1."bf\n";
}
    if($_ =~ /\[$rank\] After-MPI_Finalize ([0-9\.]+)/) { $after_mpi_finalize = $1; #print $1."af\n";
}
    if($_ =~ /real\s+([0-9]+)m([0-9\.]+)s/) { $real_min = $1; $real_sec = $2; #print "$1m$2s\n";
}
    if($_ =~ /\[$rank\] shm_seg_commit ([0-9\.]+)/) { $shm_seg_commit = $1; #print $1."s\n";
}
    if($_ =~ /\[$rank\] PMI_KVS_Get ([0-9\.]+)/) { $pmi_kvs_get = $1; #print $1."g\n";
}
}
printf("%f %f %f %f %f %f %f\n", $real_min*60+$real_sec, $before_mpi_init - $before_mpiexec, $after_mpi_init - $before_mpi_init, 
       $shm_seg_commit, $pmi_kvs_get, $after_mpi_finalize - $before_mpi_finalize,
    $after_mpiexec - $after_mpi_finalize);
