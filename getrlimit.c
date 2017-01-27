#include <stdio.h>
#include <sys/time.h>
#include <sys/resource.h>

int main() {
  struct rlimit rlim;
  getrlimit(RLIMIT_NPROC, &rlim);
  printf("RLIMIT_NPROC, %d, %d\n", rlim.rlim_cur, rlim.rlim_max);
}
