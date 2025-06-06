#include "./kernel/types.h"
#include "./kernel/param.h"
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
    // Print header row
    printf("PID   INUSE TICKETS_O TICKETS_C SLICES   QUEUE Q\n");
    for (int i = 0; i < NPROC; i++)
    {
        if (st.inuse[i])
        {
            printf("%-5d %-5d %-9d %-9d %-8d %-6d %-3d\n",
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