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

    static unsigned int djb2(const unsigned char *str, unsigned int num_buckets)
    {
        string cpp_str((const char *)str);
        unsigned int hash = 5381;
        unsigned int len = cpp_str.length();

        for (unsigned int i = 0; i < len; i++)
        {
            hash = ((hash << 5) + hash) + cpp_str[i];
        }

        return hash % num_buckets;
    }

    static unsigned int fnv1a(const unsigned char *str, unsigned int num_buckets)
    {
        string cpp_str((const char *)str);
        unsigned int hash = 0x811c9dc5;
        unsigned int len = cpp_str.length();

        for (unsigned int i = 0; i < len; i++)
        {
            hash ^= cpp_str[i];
            hash *= 0x01000193;
        }

        return hash % num_buckets;
    }

    static unsigned int hash(const unsigned char *str, unsigned int num_buckets, int hashChoice)
    {
        switch (hashChoice)
        {
        case 1:
            return sdbm(str, num_buckets);
        case 2:
            return djb2(str, num_buckets);
        case 3:
            return fnv1a(str, num_buckets);
        default:
            return sdbm(str, num_buckets);
        }
    }
};

#endif