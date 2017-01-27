#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>
#include <unistd.h>
#include <stdint.h>
#include <sys/mman.h>
#include <sys/time.h>

int main(int argc, char** argv) {
  int nproc, rank, ierr;
  struct timeval tv;

  //printf("[%d]hello\n", getpid()); fflush(stdout);
  //system("uname -n");

#ifdef PROF
  gettimeofday(&tv, NULL);
  printf("Before-MPI_Init %ld.%ld\n", tv.tv_sec, tv.tv_usec);
#endif
  ierr = MPI_Init(&argc, &argv);
#ifdef PROF
  gettimeofday(&tv, NULL);
  printf("After-MPI_Init %ld.%ld\n", tv.tv_sec, tv.tv_usec);
#endif

  ierr = MPI_Comm_size(MPI_COMM_WORLD, &nproc);
  ierr = MPI_Comm_rank(MPI_COMM_WORLD, &rank);

  //printf("rank=%d,nproc=%d\n", rank, nproc);

#ifdef PROF
  gettimeofday(&tv, NULL);
  printf("Before-MPI_Finalize %ld.%ld\n", tv.tv_sec, tv.tv_usec);
#endif
  MPI_Finalize();
#ifdef PROF
  gettimeofday(&tv, NULL);
  printf("After-MPI_Finalize %ld.%ld\n", tv.tv_sec, tv.tv_usec);
#endif

 fn_exit:
  return 0;
 fn_fail:
  goto fn_exit;
}
