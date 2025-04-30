#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

extern void yield(void);

int printing = 0;

void acquire_lock() {
  while (__sync_lock_test_and_set(&printing, 1) != 0);
}

void release_lock() {
  __sync_lock_release(&printing);
}

int main() {
  printf("Setting scheduling policy to HRRN (3)...\n");
  set_sched(3);
  int start_time = uptime();

  int pid1 = fork();
  if (pid1 == 0) {
    int mypid = getpid();

    acquire_lock();
    printf("Child1 (long task) PID=%d STARTED at %d ticks\n", mypid, uptime() - start_time);
    release_lock();

    
    volatile int x = 0;
    for (volatile int i = 0; i < 100000000; i++) {
      x++;
    }

    acquire_lock();
    printf("Child1 YIELDING at %d ticks\n", uptime() - start_time);
    release_lock();

    yield();

    
    
    acquire_lock();
    printf("Child1 RESUMED at %d ticks\n", uptime() - start_time);
    release_lock();

    
    for (volatile int i = 0; i < 100000000; i++) {
      x++;
    }

    acquire_lock();
    printf("Child1 DONE at %d ticks\n", uptime() - start_time);
    release_lock();

    exit(0);
  }

  int pid2 = fork();
  if (pid2 == 0) {
    int mypid = getpid();

    acquire_lock();
    printf("Child2 (short task) PID=%d STARTED at %d ticks\n", mypid, uptime() - start_time);
    release_lock();

    
    volatile int x = 0;
    for (volatile int i = 0; i < 80000000; i++) {
      x++;
    }

    acquire_lock();
    printf("Child2 YIELDING at %d ticks\n", uptime() - start_time);
    release_lock();

    yield();

    

    acquire_lock();
    printf("Child2 RESUMED at %d ticks\n", uptime() - start_time);
    release_lock();

 
    for (volatile int i = 0; i < 80000000; i++) {
      x++;
    }

    acquire_lock();
    printf("Child2 DONE at %d ticks\n", uptime() - start_time);
    release_lock();

    exit(0);
  }

  wait(0);
  wait(0);

  acquire_lock();
  printf("Parent done.\n");
  release_lock();

  exit(0);
}
