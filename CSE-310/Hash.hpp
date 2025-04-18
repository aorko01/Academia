#include<iostream>
#include<string>
using namespace std;

class Hash
{
public:
    static unsigned long sdbm(unsigned char *str)
    {
        unsigned long hash = 0;
        int c;

        while ((c = *str++))
            hash = c + (hash << 6) + (hash << 16) - hash;

        return hash;
    }
};