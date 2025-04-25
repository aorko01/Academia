#ifndef HASH_HPP
#define HASH_HPP

#include <iostream>
#include <string>
using namespace std;

class Hash
{
public:
    static unsigned int sdbm(const unsigned char *str, unsigned int num_buckets)
    {
        string cpp_str((const char *)str);
        unsigned int hash = 0;
        unsigned int len = cpp_str.length();

        for (unsigned int i = 0; i < len; i++)
        {
            hash = ((cpp_str[i]) + (hash << 6) + (hash << 16) - hash) % num_buckets;
        }

        return hash;
    }
};

#endif // HASH_HPP