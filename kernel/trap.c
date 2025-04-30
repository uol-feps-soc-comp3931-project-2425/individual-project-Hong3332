#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "spinlock.h"
#include "proc.h"
#include "defs.h"

extern int current_policy;

struct spinlock tickslock;
uint ticks;

extern char trampoline[], uservec[], userret[];

// in kernelvec.S, calls kerneltrap().
void kernelvec();

extern int devintr();

void
trapinit(void)
{
  initlock(&tickslock, "time");
}

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
  w_stvec((uint64)kernelvec);
}

// handle an interrupt, exception, or system call from user space.
void
usertrap(void)
{
  int which_dev = 0;

  if((r_sstatus() & SSTATUS_SPP) != 0)
    panic("usertrap: not from user mode");

  w_stvec((uint64)kernelvec);

  struct proc *p = myproc();

  // save user program counter.
  p->trapframe->epc = r_sepc();

  if(r_scause() == 8){
    // system call
    if(killed(p))
      exit(-1);

    p->trapframe->epc += 4;
    intr_on();
    syscall();

  } else if((which_dev = devintr()) != 0){
    // device interrupt
  } else {
    //printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    //printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    setkilled(p);
  }

  if(killed(p))
    exit(-1);

  if (which_dev == 2) {
    if (p && p->state == RUNNING) {
      p->total_ticks++;
    }

    if (current_policy == 0 && p && p->state == RUNNING) {
      
      yield();
    } else if (current_policy == 4 && p && p->state == RUNNING) {
      
      p->time_slice++;
      int max_ticks[] = {5, 10, 20};

      if (p->time_slice >= max_ticks[p->queue_level]) {
        if (p->queue_level < QUEUE_LEVELS - 1) {
          printf("PID=%d exceeded time slice at tick=%d, demoting from level %d to %d\n",
                 p->pid, ticks, p->queue_level, p->queue_level + 1);
          p->queue_level++;
        } else {
          printf("PID=%d reached time slice limit at tick=%d (already at lowest level %d)\n",
                 p->pid, ticks, p->queue_level);
        }
        p->time_slice = 0;
        yield();
      }

    }
    
  }

  usertrapret();
}

// return to user space
void
usertrapret(void)
{
  struct proc *p = myproc();

  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
  w_stvec(trampoline_uservec);

  p->trapframe->kernel_satp = r_satp();
  p->trapframe->kernel_sp = p->kstack + PGSIZE;
  p->trapframe->kernel_trap = (uint64)usertrap;
  p->trapframe->kernel_hartid = r_tp();

  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
  x |= SSTATUS_SPIE; // enable interrupts in user mode
  w_sstatus(x);

  w_sepc(p->trapframe->epc);

  uint64 satp = MAKE_SATP(p->pagetable);

  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
  ((void (*)(uint64))trampoline_userret)(satp);
}

// interrupts and exceptions from kernel code go here via kernelvec
void
kerneltrap(void)
{
  int which_dev = 0;
  uint64 sepc = r_sepc();
  uint64 sstatus = r_sstatus();
  uint64 scause = r_scause();
  
  if((sstatus & SSTATUS_SPP) == 0)
    panic("kerneltrap: not from supervisor mode");
  if(intr_get() != 0)
    panic("kerneltrap: interrupts enabled");

  if((which_dev = devintr()) == 0){
    printf("kerneltrap: unexpected scause 0x%lx sepc=0x%lx stval=0x%lx\n", scause, sepc, r_stval());
    panic("kerneltrap");
  }

  if (which_dev == 2 && myproc() != 0) {
    if (current_policy == 0 || current_policy == 4) {
      // 只在RR和MLFQ下yield
      yield();
    }
  }

  w_sepc(sepc);
  w_sstatus(sstatus);
}

// clock interrupt handler
void
clockintr(void)
{
  if(cpuid() == 0){
    acquire(&tickslock);
    ticks++;
    wakeup(&ticks);
    release(&tickslock);
  }

  // ask for the next timer interrupt (tick interval)
  w_stimecmp(r_time() + 1000000);
}

// device interrupt
int
devintr(void)
{
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    int irq = plic_claim();
    if(irq == UART0_IRQ){
      uartintr();
    } else if(irq == VIRTIO0_IRQ){
      virtio_disk_intr();
    } else if(irq){
      printf("unexpected interrupt irq=%d\n", irq);
    }
    if(irq)
      plic_complete(irq);
    return 1;
  } else if(scause == 0x8000000000000005L){
    clockintr();
    return 2;
  } else {
    return 0;
  }
}
