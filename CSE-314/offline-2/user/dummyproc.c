#include "./kernel/types.h"
#include "user.h"



int main(int argc, char *argv[])
{
    int tickets = -1;
    if (argc > 1) {
        tickets = atoi(argv[1]);
    }
    printf("[dummyproc] Setting tickets to %d\n", tickets);
    int ret = settickets(tickets);
    if (ret == 0) {
        printf("[dummyproc] settickets succeeded\n");
    } else {
        printf("[dummyproc] settickets failed, using default tickets\n");
    }

    int pid = fork();
    if (pid < 0) {
        printf("[dummyproc] fork failed\n");
        exit(1);
    } else if (pid == 0) {
        // Child process
        printf("[dummyproc] Child process running (pid=%d)\n", getpid());
        for (int i = 0; i < 10; i++) {
            printf("[dummyproc] Child loop %d\n", i);
            sleep(10);
        }
        exit(0);
    } else {
        // Parent process
        printf("[dummyproc] Parent process running (pid=%d)\n", getpid());
        for (int i = 0; i < 10; i++) {
            printf("[dummyproc] Parent loop %d\n", i);
            sleep(10);
        }
        wait(0);
    }
    exit(0);
}
