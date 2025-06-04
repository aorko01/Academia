#include "./kernel/types.h"
#include "user.h"

#define USR_NSYSCALL 22

int main(int argc, char *argv[])
{
    int pid1 = fork();
    if (pid1 == 0)
        exit(0); // child exits

    int pid2 = fork();
    if (pid2 == 0)
        exit(0);

    int pid3 = fork();
    if (pid3 == 0)
        exit(0);

    // Call read 21 times before calling history
    char buf[1];
    for (int i = 0; i < 21; i++) {
        read(-1, buf, 1); // invalid fd, just to increment syscall count
    }

    // Perform some system calls to test syscall_stats
    getpid();
    uptime();
    sleep(1);
    int fd = open("history.c", 0);
    if (fd >= 0)
    {
        close(fd);
    }
    // Only parent reaches here
    if (argc > 1) {
        int syscall_num = atoi(argv[1]);
        if (syscall_num < 1 || syscall_num > USR_NSYSCALL) {
            printf("Invalid syscall number.\n");
            return 1;
        }
        struct syscall_stat stat;
        history(syscall_num, &stat);
        if (stat.syscall_name[0] != '\0')
            printf("%d: syscall: %s, #: %d, time: %d\n", syscall_num, stat.syscall_name, stat.count, stat.accum_time);
    } else {
        for (int i = 1; i <= USR_NSYSCALL; i++) {
            struct syscall_stat stat;
            history(i, &stat);
            if (stat.syscall_name[0] != '\0')
                printf("%d: syscall: %s, #: %d, time: %d\n", i, stat.syscall_name, stat.count, stat.accum_time);
        }
    }
    return 0;
}