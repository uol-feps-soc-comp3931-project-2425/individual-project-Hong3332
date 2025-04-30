#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"


int printing = 0;

void acquire_lock()
{
  while (__sync_lock_test_and_set(&printing, 1) != 0);
}

void release_lock()
{
  __sync_lock_release(&printing);
}

int main() {
  int pid;
  int start_time;

  start_time = uptime();

  printf("Setting scheduling policy to FCFS (1)...\n");
  set_sched(1);

  int workload[5] = {100000000, 80000000, 60000000, 40000000, 20000000};

  for (int i = 0; i < 5; i++) {
    pid = fork();
    if (pid == 0) {
      int mypid = getpid();
      
      acquire_lock();
      //printf("Child %d START at %d ticks\n", mypid, uptime() - start_time);
      release_lock();

      volatile int x = 0;
      for (volatile int j = 0; j < workload[i]; j++) {
        if (j % 20000000 == 0 && j != 0) {
          acquire_lock();
          //printf("[RUNNING] Child %d at loop %d at %d ticks\n", mypid, j, uptime() - start_time);
          release_lock();
          //top();
        }
        x++;
      }

      acquire_lock();
      //top();
      printf("Child %d DONE at %d ticks\n", mypid, uptime() - start_time);
      release_lock();

      exit(0);
    }
    sleep(3);
  }

  
  for (int i = 0; i < 5; i++) {
    wait(0);
  }

  acquire_lock();
  printf("Parent done\n");
  release_lock();

  exit(0);
}
