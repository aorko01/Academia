#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "proc.h"
#include "pstat.h"
extern struct proc proc[];

uint64
sys_exit(void)
{
  int n;
  argint(0, &n);
  exit(n);
  return 0; // not reached
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
  if (growproc(n) < 0)
    return -1;
  return addr;
}

uint64
sys_sleep(void)
{
  int n;
  uint ticks0;

  argint(0, &n);
  if (n < 0)
    n = 0;
  acquire(&tickslock);
  ticks0 = ticks;
  while (ticks - ticks0 < n)
  {
    if (killed(myproc()))
    {
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

uint64 sys_history()
{
  int syscall_num;
  uint64 stat_addr;
  argint(0, &syscall_num);
  argaddr(1, &stat_addr);
  struct proc *p = myproc();
  if (syscall_num < 1 || syscall_num > NSYSCALL)
    return -1;
  struct syscall_stat stat = p->syscall_stats[syscall_num];
  if (copyout(p->pagetable, stat_addr, (char *)&stat, sizeof(struct syscall_stat)) < 0)
    return -1;
  return 0;
}

uint64 sys_settickets()
{
  int n;
  argint(0, &n);
  struct proc *p = myproc();

  if (n < 1)
  {
    acquire(&p->lock);
    p->Original_tickets = DEFAULT_TICKET_COUNT;
    p->Current_tickets = DEFAULT_TICKET_COUNT;
    release(&p->lock);
    return -1;
  }

  acquire(&p->lock);
  p->Original_tickets = n;
  p->Current_tickets = n;
  release(&p->lock);
  return 0;
}


uint64 sys_getpinfo(void)
{
  uint64 addr;
  struct proc *p;
  struct pstat st;
  
  // Get the user space address
  argaddr(0, &addr);
    
  // Check for NULL pointer
  if (addr == 0)
    return -1;

  // Initialize the pstat structure
  memset(&st, 0, sizeof(st));

  // Fill the pstat structure with process information
  for (int i = 0; i < NPROC; i++) {
    p = &proc[i];
    acquire(&p->lock);
    
    st.pid[i] = p->pid;
    st.inuse[i] = (p->state != UNUSED);
    st.inQ[i] = p->inq;
    st.tickets_original[i] = p->Original_tickets;
    st.tickets_current[i] = p->Current_tickets;
    st.time_slices[i] = p->time_slices;
    
    release(&p->lock);
  }

  // Copy the structure to user space
  if (copyout(myproc()->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    return -1;
    
  return 0;
}