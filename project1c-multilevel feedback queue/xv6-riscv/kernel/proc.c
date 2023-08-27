#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "spinlock.h"
#include "proc.h"
#include "defs.h"
#include "log.h"

struct cpu cpus[NCPU];

struct proc proc[NPROC];

struct proc *initproc;

int nextpid = 1;
struct spinlock pid_lock;

extern void forkret(void);
static void freeproc(struct proc *p);

extern char trampoline[]; // trampoline.S

// helps ensure that wakeups of wait()ing
// parents are not lost. helps obey the
// memory model when using p->parent.
// must be acquired before any p->lock.
struct spinlock wait_lock;

struct logentry schedlog[LOG_SIZE];
int time = 0;
int is_logging = 0;
int num_logged = 0;
int isQueueSetup = 0;

//Provided code for MLFQ
#define MAX_UINT64 (-1)
#define EMPTY MAX_UINT64
#define NUM_QUEUES 3
//Constants for ease of use
#define HEAD_Q0 64
#define TAIL_Q0 65
#define HEAD_Q1 66
#define TAIL_Q1 67
#define HEAD_Q2 68
#define TAIL_Q2 69
//Variable to check for priority boost
int timeSincePriorityBoost = 0;

//A node of the linked list
struct qentry {
  uint64 queue; //Used to store the queue level
  uint64 prev;  //Index of previous qentry in list
  uint64 next;  //Index of next qentry in list
};

//A fixed size table where the index of a process in proc[] is the same in qtable[]
struct qentry qtable[NPROC + 2*NUM_QUEUES];

void setupQueue(){
  printf("SETTING UP THE QUEUE!\n");
  for(int i = 0; i < NPROC; i++){
    qtable[i].queue = EMPTY;
  }
  //Head-Tail
  //INDEX 64+65=0, 66+67=1, 68+69=2
  //Setup heads and tails of all 3 queues(I know this is bad ok)
  //Head's next should point to tail and tail's previous should point to head by default
  qtable[HEAD_Q0].queue = 0;
  qtable[HEAD_Q0].next = 65;
  qtable[TAIL_Q0].queue = 0;
  qtable[TAIL_Q0].prev = 64;
  
  qtable[HEAD_Q1].queue = 1;
  qtable[HEAD_Q1].next = 67;
  qtable[TAIL_Q1].queue = 1;
  qtable[TAIL_Q1].prev = 66;

  qtable[HEAD_Q2].queue = 2;
  qtable[HEAD_Q2].next = 69;
  qtable[TAIL_Q2].queue = 2;
  qtable[TAIL_Q2].prev = 68;
}

void enqueue(struct proc *p){
  uint64 pindex = p-proc;
  int queueToInsertTo;
  //Check which queue we want to insert to based on the nice value.
  if(p->nice>10){
    queueToInsertTo = 0;
    //If the process is moving up a queue then we reset time quanta
    if(p->queue > 0)p->quanta = 0;
  }else if(p->nice <= 10 && p->nice > -10){
    queueToInsertTo = 1;
    //If the process is moving up a queue then we reset time quanta
    if(p->queue > 1)p->quanta = 0;
  }else{
    queueToInsertTo = 2;
  }
  //Time to check time quanta, if it exceeds then move down a queue, queue 2 being the lowest
  if(p->quanta > 15 && queueToInsertTo == 0){
    queueToInsertTo++;
    //If we're moving priority down a queue then we reset the time quanta
    p->quanta = 0;
  }else if(p->quanta > 10 && queueToInsertTo == 1){
    queueToInsertTo++;
    //If we're moving priority down a queue then we reset the time quanta
    p->quanta = 0;
  }else if(p->quanta > 1 && queueToInsertTo == 2){
    //We can't move down a queue so we just reset quanta
    p->quanta = 0;
  }
  //Failsafe ig
  if(queueToInsertTo > 2)queueToInsertTo = 2;

  if(queueToInsertTo == 0){
    p->queue = 0;
    //give process to queue 0
    qtable[pindex].queue = 0;
    int oldTail = qtable[TAIL_Q0].prev;
    qtable[pindex].prev = oldTail;
    qtable[pindex].next = TAIL_Q0;
    qtable[oldTail].next = pindex;
    qtable[TAIL_Q0].prev = pindex;
    
  }
  else if(queueToInsertTo == 1){
    p->queue = 1;
    //give process to queue 1
    qtable[pindex].queue = 1;
    int oldTail = qtable[TAIL_Q1].prev;
    qtable[pindex].prev = oldTail;
    qtable[pindex].next = TAIL_Q1;
    qtable[oldTail].next = pindex;
    qtable[TAIL_Q1].prev = pindex;
  }else{
    //else it goes to the last queue, 2.
    p->queue = 2;
    //give process to queue 2
    qtable[pindex].queue = 2;
    int oldTail = qtable[TAIL_Q2].prev;
    qtable[pindex].prev = oldTail;
    qtable[pindex].next = TAIL_Q2;
    qtable[oldTail].next = pindex;
    qtable[TAIL_Q2].prev = pindex;
  }
}

void removeFromQueue(struct proc *p){
  //Assume p is a pointer to a process in proc[]
  uint64 pindex = p-proc;
  //Set queue of process we're de-queueing to empty
  qtable[pindex].queue = EMPTY;
  //Placehold the old prev and next even though they'll still be there for ease of use
  int oldPrev = qtable[pindex].prev;
  int oldNext = qtable[pindex].next;
  qtable[oldPrev].next = oldNext;
  qtable[oldNext].prev = oldPrev;
}

void dequeue(){
  //Find first process
  struct proc *p;
  //If the head pointer is tail then we go to the next queue down the list because priority
  if(qtable[HEAD_Q0].next != TAIL_Q0){
    //Find first process, set it to local variable and then dequeue it, at the end return it to scheduler.
    //Set p to head of queue 0
    p = &proc[qtable[HEAD_Q0].next];
    //uint64 pindex = p-proc;
    //printf("Q0 Running -- Pindex is: %d, Process name: %s, Process Quanta: %d\n", pindex, p->name, p->quanta);
    //printf("1Qtable Head: %d\n", qtable[HEAD_Q0].next);
  }else if(qtable[HEAD_Q1].next != TAIL_Q1){
    //Set p to head of queue 1
    p = &proc[qtable[HEAD_Q1].next];
    //uint64 pindex = p-proc;
    //printf("Q1 Running -- Pindex is: %d, Process name: %s, Process Quanta: %d\n", pindex, p->name, p->quanta);
    //printf("2Qtable Head: %d\n", qtable[HEAD_Q0].next);
  }else if(qtable[HEAD_Q2].next != TAIL_Q2){
    //(qtable[HEAD_Q2].next != TAIL_Q2)
    //Set p to head of queue 2
    p = &proc[qtable[HEAD_Q2].next];
    //uint64 pindex = p-proc;
    //printf("Q2 Running -- Pindex is: %d, Process name: %s, Process Quanta: %d\n", pindex, p->name, p->quanta);
    //printf("3Qtable Head: %d\n", qtable[HEAD_Q0].next);
  }else{
    return;
  }
  
  //Remove p from the queue since we're gonna run it?
  removeFromQueue(p);
  struct cpu *c = mycpu();
  c->proc = 0;
  intr_on();
  acquire(&p->lock);
  p->state = RUNNING;
  c->proc = p;
    
    //printf("About to touch context switch--\n");
  swtch(&c->context, &p->context);
    //printf("After context switch--\n");
  if (is_logging && (num_logged == 0 || schedlog[num_logged-1].pid != p->pid) && num_logged < LOG_SIZE) {
    schedlog[num_logged].pid = p->pid;
    schedlog[num_logged].time = time;
    num_logged++;
  }
  // Process is done running for now.
  // It should have changed its p->state before coming back.
  c->proc = 0;
  release(&p->lock);
}

uint64
sys_startlog(void)
{
  if (is_logging) {
    return -1; 
  }
  is_logging = 1; 
  return 0;
}

uint64
sys_getlog(void) {
    uint64 userlog; // hold the virtual (user) address of
                    // user’s copy of the log
    // set userlog to the argument passed by the user
    argaddr(0, &userlog);

    // copy the log from kernel memory to user memory
    struct proc *p = myproc();
    if (copyout(p->pagetable, userlog, (char *)schedlog,
            sizeof(struct logentry)*LOG_SIZE) < 0)
        return -1;

    return num_logged;
}

int
sys_nice(void) {
  int inc; // the increment
  // set inc to the argument passed by the user
  argint(0, &inc);

  // get the current user process
  struct proc *p = myproc();

  p->nice += inc;
  if (p->nice > 19) {
	  p->nice = 19;
  }
  if (p->nice < -20) {
	  p->nice = -20;
  }
  //We updated the nice value of a process, so we change what queue it's in
  //this code below before the return should cover rule 6?
  int tempQueue = -1;
  if(p->nice > 10){
    tempQueue = 0;
  }else if(p->nice < -10 && p->nice <= 10){
    tempQueue = 1;
  }else if(p->nice <= -10){
    tempQueue = 2;
  }

  //If the queue we want to shove it into isn't the processes current queue then remove it from
  //Its current queue and re-enqueue it into the correct one(we need not update p->queue as enqueue does this)
  if(tempQueue != p->queue){
    removeFromQueue(p);
    enqueue(p);
  }
  
  return p->nice;
}

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
  }
}

// initialize the proc table.
void
procinit(void)
{
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
  initlock(&wait_lock, "wait_lock");
  for(p = proc; p < &proc[NPROC]; p++) {
      initlock(&p->lock, "proc");
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
  }
}

// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
  int id = r_tp();
  return id;
}

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
  int id = cpuid();
  struct cpu *c = &cpus[id];
  return c;
}

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
  push_off();
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
  pop_off();
  return p;
}

int
allocpid()
{
  int pid;
  
  acquire(&pid_lock);
  pid = nextpid;
  nextpid = nextpid + 1;
  release(&pid_lock);

  return pid;
}

// Look in the process table for an UNUSED proc.
// If found, initialize state required to run in the kernel,
// and return with p->lock held.
// If there are no free procs, or a memory allocation fails, return 0.
static struct proc*
allocproc(void)
{
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    acquire(&p->lock);
    if(p->state == UNUSED) {
      goto found;
    } else {
      release(&p->lock);
    }
  }
  return 0;

found:
  p->pid = allocpid();
  p->state = USED;

  // Allocate a trapframe page.
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    freeproc(p);
    release(&p->lock);
    return 0;
  }

  // An empty user page table.
  p->pagetable = proc_pagetable(p);
  if(p->pagetable == 0){
    freeproc(p);
    release(&p->lock);
    return 0;
  }

  // Set up new context to start executing at forkret,
  // which returns to user space.
  memset(&p->context, 0, sizeof(p->context));
  p->context.ra = (uint64)forkret;
  p->context.sp = p->kstack + PGSIZE;

  return p;
}

// free a proc structure and the data hanging from it,
// including user pages.
// p->lock must be held.
static void
freeproc(struct proc *p)
{
  if(p->trapframe)
    kfree((void*)p->trapframe);
  p->trapframe = 0;
  if(p->pagetable)
    proc_freepagetable(p->pagetable, p->sz);
  p->pagetable = 0;
  p->sz = 0;
  p->pid = 0;
  p->parent = 0;
  p->name[0] = 0;
  p->chan = 0;
  p->killed = 0;
  p->xstate = 0;
  p->state = UNUSED;
  p->nice = 0;
}

// Create a user page table for a given process, with no user memory,
// but with trampoline and trapframe pages.
pagetable_t
proc_pagetable(struct proc *p)
{
  pagetable_t pagetable;

  // An empty page table.
  pagetable = uvmcreate();
  if(pagetable == 0)
    return 0;

  // map the trampoline code (for system call return)
  // at the highest user virtual address.
  // only the supervisor uses it, on the way
  // to/from user space, so not PTE_U.
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
              (uint64)trampoline, PTE_R | PTE_X) < 0){
    uvmfree(pagetable, 0);
    return 0;
  }

  // map the trapframe page just below the trampoline page, for
  // trampoline.S.
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
              (uint64)(p->trapframe), PTE_R | PTE_W) < 0){
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    uvmfree(pagetable, 0);
    return 0;
  }

  return pagetable;
}

void
proc_freepagetable(pagetable_t pagetable, uint64 sz)
{
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
  uvmfree(pagetable, sz);
}

// a user program that calls exec("/init")
// assembled from ../user/initcode.S
// od -t xC ../user/initcode
uchar initcode[] = {
  0x17, 0x05, 0x00, 0x00, 0x13, 0x05, 0x45, 0x02,
  0x97, 0x05, 0x00, 0x00, 0x93, 0x85, 0x35, 0x02,
  0x93, 0x08, 0x70, 0x00, 0x73, 0x00, 0x00, 0x00,
  0x93, 0x08, 0x20, 0x00, 0x73, 0x00, 0x00, 0x00,
  0xef, 0xf0, 0x9f, 0xff, 0x2f, 0x69, 0x6e, 0x69,
  0x74, 0x00, 0x00, 0x24, 0x00, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00
};

// Set up first user process.
void
userinit(void)
{
  struct proc *p;

  p = allocproc();
  initproc = p;
  
  // allocate one user page and copy initcode's instructions
  // and data into it.
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
  p->sz = PGSIZE;

  // prepare for the very first "return" from kernel to user.
  p->trapframe->epc = 0;      // user program counter
  p->trapframe->sp = PGSIZE;  // user stack pointer

  safestrcpy(p->name, "initcode", sizeof(p->name));
  p->cwd = namei("/");

  p->state = RUNNABLE;
  //uint64 pindex = p-proc;
  if(isQueueSetup == 0){
    setupQueue();
    isQueueSetup = 1;
  }
  //printf("1Enqueueing process name: %s, pindex: %d\n", p->name, pindex);
  enqueue(p);
  release(&p->lock);
}

// Grow or shrink user memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
  uint64 sz;
  struct proc *p = myproc();

  sz = p->sz;
  if(n > 0){
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
      return -1;
    }
  } else if(n < 0){
    sz = uvmdealloc(p->pagetable, sz, sz + n);
  }
  p->sz = sz;
  return 0;
}

// Create a new process, copying the parent.
// Sets up child kernel stack to return as if from fork() system call.
int
fork(void)
{
  int i, pid;
  struct proc *np;
  struct proc *p = myproc();

  // Allocate process.
  if((np = allocproc()) == 0){
    return -1;
  }

  // Copy user memory from parent to child.
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    freeproc(np);
    release(&np->lock);
    return -1;
  }
  np->sz = p->sz;

  // copy saved user registers.
  *(np->trapframe) = *(p->trapframe);

  // Cause fork to return 0 in the child.
  np->trapframe->a0 = 0;

  // increment reference counts on open file descriptors.
  for(i = 0; i < NOFILE; i++)
    if(p->ofile[i])
      np->ofile[i] = filedup(p->ofile[i]);
  np->cwd = idup(p->cwd);

  safestrcpy(np->name, p->name, sizeof(p->name));

  pid = np->pid;

  release(&np->lock);

  acquire(&wait_lock);
  np->parent = p;
  release(&wait_lock);

  acquire(&np->lock);
  np->state = RUNNABLE;
  //uint64 pindex = p-proc;
    if(isQueueSetup == 0){
    setupQueue();
    isQueueSetup = 1;
  }
  //printf("5Enqueueing process name: %s, pindex: %d\n", p->name, pindex);
  enqueue(np);
  release(&np->lock);

  return pid;
}

// Pass p's abandoned children to init.
// Caller must hold wait_lock.
void
reparent(struct proc *p)
{
  struct proc *pp;

  for(pp = proc; pp < &proc[NPROC]; pp++){
    if(pp->parent == p){
      pp->parent = initproc;
      wakeup(initproc);
    }
  }
}

// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait().
void
exit(int status)
{
  struct proc *p = myproc();

  if(p == initproc)
    panic("init exiting");

  // Close all open files.
  for(int fd = 0; fd < NOFILE; fd++){
    if(p->ofile[fd]){
      struct file *f = p->ofile[fd];
      fileclose(f);
      p->ofile[fd] = 0;
    }
  }

  begin_op();
  iput(p->cwd);
  end_op();
  p->cwd = 0;

  acquire(&wait_lock);

  // Give any children to init.
  reparent(p);

  // Parent might be sleeping in wait().
  wakeup(p->parent);
  
  acquire(&p->lock);

  p->xstate = status;
  p->state = ZOMBIE;

  release(&wait_lock);

  // Jump into the scheduler, never to return.
  sched();
  panic("zombie exit");
}

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(uint64 addr)
{
  struct proc *pp;
  int havekids, pid;
  struct proc *p = myproc();

  acquire(&wait_lock);

  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
    for(pp = proc; pp < &proc[NPROC]; pp++){
      if(pp->parent == p){
        // make sure the child isn't still in exit() or swtch().
        acquire(&pp->lock);

        havekids = 1;
        if(pp->state == ZOMBIE){
          // Found one.
          pid = pp->pid;
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
                                  sizeof(pp->xstate)) < 0) {
            release(&pp->lock);
            release(&wait_lock);
            return -1;
          }
          freeproc(pp);
          release(&pp->lock);
          release(&wait_lock);
          return pid;
        }
        release(&pp->lock);
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || killed(p)){
      release(&wait_lock);
      return -1;
    }
    
    // Wait for a child to exit.
    sleep(p, &wait_lock);  //DOC: wait-sleep
  }
}

// Per-CPU process scheduler.
// Each CPU calls scheduler() after setting itself up.
// Scheduler never returns.  It loops, doing:
//  - choose a process to run.
//  - swtch to start running that process.
//  - eventually that process transfers control
//    via swtch back to the scheduler.
void
scheduler(void)
{
  for(;;){
    //If we need to preform a prio boost, then do so.
    if(timeSincePriorityBoost > 60){
      printf("Priority Boost!\n");
      //This will drop everything from the queue(essentially) by just resetting the pointers
      setupQueue();
      //We now will re-enqueue everything that is set to runnable IG
      struct proc *p;
      for(p = proc; p < &proc[NPROC]; p++){
        if(p->state == RUNNABLE){
          enqueue(p);
        }
      }
      //Just set it back to 0 incase it goes over integer max or something idunno man sue me or something
      timeSincePriorityBoost = 0;
    }
    //Dequeue a process to run
    dequeue();
  }
}

// Switch to scheduler.  Must hold only p->lock
// and have changed proc->state. Saves and restores
// intena because intena is a property of this
// kernel thread, not this CPU. It should
// be proc->intena and proc->noff, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
  int intena;
  struct proc *p = myproc();

  if(!holding(&p->lock))
    panic("sched p->lock");
  if(mycpu()->noff != 1)
    panic("sched locks");
  if(p->state == RUNNING)
    panic("sched running");
  if(intr_get())
    panic("sched interruptible");

  intena = mycpu()->intena;
  swtch(&p->context, &mycpu()->context);
  mycpu()->intena = intena;
}

// Give up the CPU for one scheduling round.
void
yield(void)
{
  struct proc *p = myproc();
  acquire(&p->lock);
  p->state = RUNNABLE;
  //uint64 pindex = p-proc;
    if(isQueueSetup == 0){
    setupQueue();
    isQueueSetup = 1;
  }
  p->quanta++;
  timeSincePriorityBoost++;
  enqueue(p);
  sched();
  release(&p->lock);
}

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);

  if (first) {
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
}

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
  struct proc *p = myproc();
  
  // Must acquire p->lock in order to
  // change p->state and then call sched.
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
  release(lk);

  // Go to sleep.
  p->chan = chan;
  p->state = SLEEPING;

  sched();

  // Tidy up.
  p->chan = 0;

  // Reacquire original lock.
  release(&p->lock);
  acquire(lk);
}

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
        p->state = RUNNABLE;
        //uint64 pindex = p-proc;
          if(isQueueSetup == 0){
            setupQueue();
            isQueueSetup = 1;
          }
        //printf("4Enqueueing process name: %s, pindex: %d\n", p->name, pindex);
        enqueue(p);
      }
      release(&p->lock);
    }
  }
}

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    acquire(&p->lock);
    if(p->pid == pid){
      p->killed = 1;
      if(p->state == SLEEPING){
        // Wake process from sleep().
        p->state = RUNNABLE;
        //uint64 pindex = p-proc;
          if(isQueueSetup == 0){
            setupQueue();
            isQueueSetup = 1;
          }
        //printf("2Enqueueing process name: %s, pindex: %d\n", p->name, pindex);
        enqueue(p);
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
  }
  return -1;
}

void
setkilled(struct proc *p)
{
  acquire(&p->lock);
  p->killed = 1;
  release(&p->lock);
}

int
killed(struct proc *p)
{
  int k;
  
  acquire(&p->lock);
  k = p->killed;
  release(&p->lock);
  return k;
}

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
  struct proc *p = myproc();
  if(user_dst){
    return copyout(p->pagetable, dst, src, len);
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
  struct proc *p = myproc();
  if(user_src){
    return copyin(p->pagetable, dst, src, len);
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
  static char *states[] = {
  [UNUSED]    "unused",
  [USED]      "used",
  [SLEEPING]  "sleep ",
  [RUNNABLE]  "runble",
  [RUNNING]   "run   ",
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
  for(p = proc; p < &proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
      state = states[p->state];
    else
      state = "???";
    printf("%d %s %s", p->pid, state, p->name);
    printf("\n");
  }
}
