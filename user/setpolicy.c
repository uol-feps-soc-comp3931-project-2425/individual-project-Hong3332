#include "kernel/types.h"
#include "user/user.h"

int main(int argc, char *argv[]) {
  if (argc < 2) {
    printf("Usage: setpolicy [0=RR | 1=FCFS | 2=Priority | 3=HRRN| 4=MLFQ]\n");
    exit(1);
  }

  int mode = atoi(argv[1]);
  if (set_sched(mode) < 0) {
    printf("Failed to set scheduler policy: %d\n", mode);
  } else {
    switch (mode) {
      case 0:
        printf("Scheduler policy set to Round-Robin (RR)\n");
        break;
      case 1:
        printf("Scheduler policy set to First-Come First-Served (FCFS)\n");
        break;
      case 2:
        printf("Scheduler policy set to Priority Scheduling\n");
        break;
      case 3:
        printf("Scheduler policy set to HRRN\n");
        break;
      case 4:
        printf("Scheduler policy set to MLFQ\n");
        break;
      default:
        printf("Scheduler policy set to Unknown mode: %d\n", mode);
    }
  }

  exit(0);
}
