#include "./kernel/types.h"
#include "./kernel/param.h"
// #include "./kernel/pstat.h"
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
    
    // Print header row matching the expected format
    printf("PID\t\t|\tIn Use\t\t|\tinQ\t|\tOriginal Tickets\t|\tCurrent Tickets\t|\tTime Slices\n");
    
    // Print processes that are in use
    for (int i = 0; i < NPROC; i++)
    {
        if (st.inuse[i])
        {
            printf("%d\t\t|\t%d\t\t|\t%d\t|\t%d\t\t\t|\t%d\t\t|\t%d\n",
                st.pid[i],
                st.inuse[i],
                st.inQ[i],
                st.tickets_original[i],
                st.tickets_current[i],
                st.time_slices[i]);
        }
    }
    
    exit(0);
}