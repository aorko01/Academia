#define NPROC 64 
#define NSYSCALL 24
struct stat;

struct syscall_stat
{
    char syscall_name[16];
    int count;
    int accum_time;
};

struct pstat
{
    int pid[NPROC];              // the process ID of each process
    int inuse[NPROC];            // whether this slot of the process table is being used (1 or 0)
    int inQ[NPROC];              // which queue the process is currently in
    int tickets_original[NPROC]; // the number of tickets each process ori gi na ll y had
    int tickets_current[NPROC];  // the number of tickets each process currently has
    int time_slices[NPROC];      // the number of time slices each process has been scheduled
};
// system calls
int fork(void);
int exit(int) __attribute__((noreturn));
int wait(int *);
int pipe(int *);
int write(int, const void *, int);
int read(int, void *, int);
int close(int);
int kill(int);
int exec(const char *, char **);
int open(const char *, int);
int mknod(const char *, short, short);
int unlink(const char *);
int fstat(int fd, struct stat *);
int link(const char *, const char *);
int mkdir(const char *);
int chdir(const char *);
int dup(int);
int getpid(void);
char *sbrk(int);
int sleep(int);
int uptime(void);
int history(int, struct syscall_stat *);
int settickets(int number);
int getpinfo(struct pstat *);

// ulib.c
int stat(const char *, struct stat *);
char *strcpy(char *, const char *);
void *memmove(void *, const void *, int);
char *strchr(const char *, char c);
int strcmp(const char *, const char *);
void fprintf(int, const char *, ...) __attribute__((format(printf, 2, 3)));
void printf(const char *, ...) __attribute__((format(printf, 1, 2)));
char *gets(char *, int max);
uint strlen(const char *);
void *memset(void *, int, uint);
int atoi(const char *);
int memcmp(const void *, const void *, uint);
void *memcpy(void *, const void *, uint);

// umalloc.c
void *malloc(uint);
void free(void *);
