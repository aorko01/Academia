#include "./kernel/types.h"
#include "user.h"

#define USR_NSYSCALL 22

int main(int argc, char *argv[])
{
    int pid1 = fork();
    if(pid1 == 0) exit(0); // child exits

    int pid2 = fork();
    if(pid2 == 0) exit(0);

    int pid3 = fork();
    if(pid3 == 0) exit(0);

    // Perform some system calls to test syscall_stats
    getpid();
    uptime();
    sleep(1);
    int fd = open("history.c", 0);
    if(fd >= 0) {
        close(fd);
    }
    // Only parent reaches here
    struct syscall_stat stats[USR_NSYSCALL+1];
    history(0, stats);
    // for(int i = 1; i <= USR_NSYSCALL; i++) {
    //     if(stats[i].syscall_name[0] != '\0')
    //         printf("%s %d %d\n", stats[i].syscall_name, stats[i].count, stats[i].accum_time);
    // }
    return 0;
}