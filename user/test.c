#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

#define NPROCS 1500

extern void yield(void);  

int printing = 0;

void acquire_lock() {
  while (__sync_lock_test_and_set(&printing, 1) != 0);
}

void release_lock() {
  __sync_lock_release(&printing);
}

void simulate_workload(int loops) {
  volatile int x = 0;
  for (volatile int i = 0; i < loops; i++) {
    x++;
  }
}

struct proc_info {
  int pid;
  int start_tick;
  int finish_tick;
  int runtime_ticks;
  int waiting_time;
};

struct proc_info infos[NPROCS];

int main() {
  printf("Starting massive scheduling test with %d processes\n", NPROCS);

  set_sched(4);

  int start_time = uptime();

  for (int i = 0; i < NPROCS; i++) {
    int pid = fork();
    if (pid == 0) {
      int mypid = getpid();
      //int start = uptime();

      
      if (i % 4 == 0) {
        simulate_workload(50000000); // long task
      } else if (i % 4 == 1) {
        simulate_workload(5000000); // short task
      } else if (i % 4 == 2) {
        simulate_workload(2000000);
        yield();
        simulate_workload(3000000);
      } else {
        simulate_workload(10000000); // medium task
      }

      //int end = uptime();
      int waiting = get_waiting_time(mypid);



      exit(waiting);
    } else if (pid > 0) {
      infos[i].pid = pid;
      infos[i].start_tick = uptime();
    } else {
      printf("Fork failed at i=%d!\n", i);
    }
  }

  int total_turnaround = 0;
  int total_waiting = 0;

  for (int i = 0; i < NPROCS; i++) {
    int status;
    int pid = wait(&status);  
    int finish = uptime();

    for (int j = 0; j < NPROCS; j++) {
      if (infos[j].pid == pid) {
        infos[j].finish_tick = finish;
        infos[j].runtime_ticks = finish - infos[j].start_tick;
        infos[j].waiting_time = status;
        break;
      }
    }
  }

  for (int i = 0; i < NPROCS; i++) {
    int turnaround = infos[i].finish_tick - infos[i].start_tick;
    total_turnaround += turnaround;
    total_waiting += infos[i].waiting_time;
  }

  int end_time = uptime();

  printf("\n======== Test Summary ========\n");
  printf("Total Processes: %d\n", NPROCS);
  printf("Total Time: %d ticks\n", end_time - start_time);
  printf("Average Turnaround Time: %d ticks\n", total_turnaround / NPROCS);
  printf("Average Waiting Time: %d ticks\n", total_waiting / NPROCS);

  float seconds = (end_time - start_time) * 0.01;  // 1 tick = 10ms
  float throughput = NPROCS / seconds;
  printf("Throughput: %.2f processes per second\n", throughput);
  printf("===============================\n");

  exit(0);
}
