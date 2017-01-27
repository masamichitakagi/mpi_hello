.SUFFIXES:	# Clear suffixes
.SUFFIXES:	.c

CWD := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

CC = /work/0/gg10/e29005/project/mpich/install/bin/mpicc
#CC = mpiicc

OPTNPROCS = -n
OPTHOSTFILE = -machinefile

LD=$(CC)

CFLAGS = -g -O2
LDFLAGS = 
TOP = mpi_hello
SRCS = $(TOP).c
OBJS = $(SRCS:.c=.o)
DSRCS = $(SRCS:.c=.d)

$(TOP): $(OBJS)
	$(LD) $(LDFLAGS) -o $@ $^

%.o: %.c
	$(CC) $(CFLAGS) -c $<

clean:
	rm -f $(TOP) $(OBJS) $(DSRCS)

-include $(DSRCS)
