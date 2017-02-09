#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>
#include <unistd.h>
#include <stdint.h>
#include <sys/mman.h>
#include <sys/time.h>

int main(int argc, char** argv) {
  int nproc, rank, ierr, pmi_rank;
  struct timeval tv_start, tv_stop;
  char* buf = (char*)malloc(1024*1024*128);
  setvbuf(stdout, buf, _IOFBF, 1024*1024*128);

  pmi_rank = atoi(getenv("PMI_RANK"));
  gettimeofday(&tv_start, NULL);
  if(pmi_rank == 0) printf("Before-MPI_Init %ld.%06ld\n", tv_start.tv_sec, tv_start.tv_usec);
  ierr = MPI_Init(&argc, &argv);
  gettimeofday(&tv_stop, NULL);
  if(pmi_rank == 0) printf("main-MPI_Init %.6f\n", (tv_stop.tv_sec - tv_start.tv_sec) + (tv_stop.tv_usec - tv_start.tv_usec)/1000000.0);

  ierr = MPI_Comm_size(MPI_COMM_WORLD, &nproc);
  ierr = MPI_Comm_rank(MPI_COMM_WORLD, &rank);

  gettimeofday(&tv_start, NULL);
  MPI_Finalize();
  gettimeofday(&tv_stop, NULL);
  if(pmi_rank == 0) printf("main-MPI_Finalize %.6f\n", (tv_stop.tv_sec - tv_start.tv_sec) + (tv_stop.tv_usec - tv_start.tv_usec)/1000000.0);

  gettimeofday(&tv_start, NULL);
  if(pmi_rank == 0) printf("After-MPI_Finalize %ld.%06ld\n", tv_start.tv_sec, tv_start.tv_usec);
  fflush(stdout);

 fn_exit:
  return 0;
 fn_fail:
  goto fn_exit;
}
