#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int printing = 0;

void acquire_lock() {
  while (__sync_lock_test_and_set(&printing, 1) != 0);
}

void release_lock() {
  __sync_lock_release(&printing);
}

int main() {
  int pid;
  int start_time;

  printf("Setting scheduling policy to Priority (2)...\n");
  set_sched(2);
  start_time = uptime();

  int priorities[5] = {5, 3, 1, 4, 2};

  for (int i = 0; i < 5; i++) {
    pid = fork_with_priority(priorities[i]);
    if (pid == 0) {
      sleep(1);

      int mypid = getpid();

      volatile int x = 0;
      for (volatile int j = 0; j < 500000000; j++) {
        x++;
      }
      
      acquire_lock();
      printf("Child PID=%d (priority=%d) DONE at %d ticks\n", mypid, priorities[i], uptime() - start_time);
      release_lock();

      exit(0);
    }
  }

  
  for (int i = 0; i < 5; i++) {
    wait(0);
  }

  acquire_lock();
  printf("Parent done\n");
  release_lock();

  exit(0);
}
