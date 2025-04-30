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

void simulate_workload(int loops, int print_every, int id, int start_time, const char *label) {
  volatile int x = 0;
  for (volatile int i = 0; i < loops; i++) {
    x++;
    if (i % print_every == 0) {
      int now = uptime();
      acquire_lock();
      printf("[%s] PID=%d running at tick=%d (+%d) (i=%d)\n",
             label, id, now, now - start_time, i);
      release_lock();
    }
  }
}

int main() {
  int boot_ticks = uptime();
  printf("Current system tick at test start: %d\n", boot_ticks);

  printf("Setting scheduling policy to MLFQ (4)...\n");
  set_sched(4);
  int start_time = uptime();

  int pid1 = fork();
  if (pid1 == 0) {
    int mypid = getpid();
    int now = uptime();
    acquire_lock();
    printf("Child1 (CPU-bound) PID=%d STARTED at tick=%d (+%d)\n", mypid, now, now - start_time);
    release_lock();

    
    simulate_workload(200000000, 20000000, mypid, start_time, "Child1-Phase1");

    now = uptime();
    acquire_lock();
    printf("Child1 DONE at tick=%d (+%d)\n", now, now - start_time);
    release_lock();
    exit(0);
  }
  sleep(5);
  int pid2 = fork();
  if (pid2 == 0) {
    int mypid = getpid();
    int now = uptime();
    acquire_lock();
    printf("Child2 (short-task x2) PID=%d STARTED at tick=%d (+%d)\n", mypid, now, now - start_time);
    release_lock();

    
    simulate_workload(40000000, 10000000, mypid, start_time, "Child2-Phase1");
    

    now = uptime();
    acquire_lock();
    printf("Child2 DONE at tick=%d (+%d)\n", now, now - start_time);
    release_lock();
    exit(0);
  }

  wait(0);
  wait(0);

  int now = uptime();
  acquire_lock();
  printf("Parent done at tick=%d (+%d).\n", now, now - start_time);
  release_lock();

  exit(0);
}
