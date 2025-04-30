#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "proc.h"

extern int current_policy;
extern struct proc proc[NPROC];
extern int fork_with_priority(int priority);
extern int get_waiting_time(int);

void
print_padded(const char *s, int width) {
  printf("%s", s);
  int len = strlen(s);
  for (int i = len; i < width; i++) {
    printf(" ");
  }
}

uint64
sys_get_waiting_time(void)
{
  int pid;

  
  argint(0, &pid);

  
  return get_waiting_time(pid);
}


uint64
sys_yield(void)
{
  yield();
  return 0;
}


uint64
sys_fork_with_priority(void)
{
  int priority;
  argint(0, &priority);  
  return fork_with_priority(priority);
}


uint64
sys_top(void)
{
  struct proc *p;
  printf("PID\tSTATE       \tPRIO\ttime\tNAME\n");

  for(p = proc; p < &proc[NPROC]; p++) {
    acquire(&p->lock);

    if(p->state != UNUSED){
      const char *state_str = "???";
      switch (p->state) {
        case UNUSED:    state_str = "unused"; break;
        case USED:      state_str = "used"; break;
        case SLEEPING:  state_str = "sleeping"; break;
        case RUNNABLE:  state_str = "runnable"; break;
        case RUNNING:   state_str = "running"; break;
        case ZOMBIE:    state_str = "zombie"; break;
      }

      printf("%d\t", p->pid);
      print_padded(state_str, 12);
      printf("\t%d\t%d\t%s\n",
             p->priority,
             p->arrival_time,
             p->name[0] ? p->name : "(unnamed)");
    }

    release(&p->lock);
  }

  return 0;
}





uint64
sys_set_priority(void)
{
  int pid, prio;
  argint(0, &pid);
  argint(1, &prio);

  struct proc *p;
  for (p = proc; p < &proc[NPROC]; p++) {
    acquire(&p->lock);
    if (p->pid == pid) {
      p->priority = prio;
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
  }

  return -1;
}

uint64
sys_set_sched(void)
{
  int mode = 0;
  argint(0, &mode);

  if (mode == 0 || mode == 1 || mode == 2 || mode == 3 || mode == 4) {
    current_policy = mode;
    return 0;
  }

  return -1;
}

uint64
sys_exit(void)
{
  int n;
  argint(0, &n);
  exit(n);
  return 0;  // not reached
}

uint64
sys_getpid(void)
{
  return myproc()->pid;
}

uint64
sys_fork(void)
{
  return fork();
}

uint64
sys_wait(void)
{
  uint64 p;
  argaddr(0, &p);
  return wait(p);
}

uint64
sys_sbrk(void)
{
  uint64 addr;
  int n;

  argint(0, &n);
  addr = myproc()->sz;
  if(growproc(n) < 0)
    return -1;
  return addr;
}

uint64
sys_sleep(void)
{
  int n;
  uint ticks0;

  argint(0, &n);
  if(n < 0)
    n = 0;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
  return 0;
}

uint64
sys_kill(void)
{
  int pid;

  argint(0, &pid);
  return kill(pid);
}

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
  uint xticks;

  acquire(&tickslock);
  xticks = ticks;
  release(&tickslock);
  return xticks;
}
