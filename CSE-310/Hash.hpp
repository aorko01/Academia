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

    // Simple djb2 hash function
    static unsigned int djb2(const unsigned char *str, unsigned int num_buckets)
    {
        string cpp_str((const char *)str);
        unsigned int hash = 5381; // Initial value
        unsigned int len = cpp_str.length();

        for (unsigned int i = 0; i < len; i++)
        {
            hash = ((hash << 5) + hash) + cpp_str[i]; // hash * 33 + c
        }

        return hash % num_buckets;
    }

    // Simple FNV-1a hash function
    static unsigned int fnv1a(const unsigned char *str, unsigned int num_buckets)
    {
        string cpp_str((const char *)str);
        unsigned int hash = 0x811c9dc5; // FNV offset basis
        unsigned int len = cpp_str.length();

        for (unsigned int i = 0; i < len; i++)
        {
            hash ^= cpp_str[i]; // XOR with current character
            hash *= 0x01000193; // Multiply by FNV prime
        }

        return hash % num_buckets;
    }

    // Function to select which hash function to use based on user input
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
            return sdbm(str, num_buckets); // Default to sdbm
        }
    }
};

#endif // HASH_HPP