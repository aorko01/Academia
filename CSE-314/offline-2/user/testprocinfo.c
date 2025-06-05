#include "./kernel/types.h"
#include "user.h"


int main(void)
{
    struct pstat st;
    int ret = getpinfo(&st);
    if (ret != 0)
    {
        printf("[testprocinfo] getpinfo failed\n");
        exit(1);
    }
    printf("%-5s %-5s %-7s %-7s %-7s %-7s %-3s\n", "PID", "INUSE", "TICKETS_O", "TICKETS_C", "SLICES", "QUEUE", "Q");
    for (int i = 0; i < NSYSCALL; i++)
    {
        if (st.inuse[i])
        {
            printf("%-5d %-5d %-7d %-7d %-7d %-7d %-3d\n",
                st.pid[i],
                st.inuse[i],
                st.tickets_original[i],
                st.tickets_current[i],
                st.time_slices[i],
                st.inQ[i],
                st.inQ[i]);
        }
    }
    exit(0);
}
