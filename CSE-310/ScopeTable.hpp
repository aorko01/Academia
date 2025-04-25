#ifndef SCOPE_TABLE_HPP
#define SCOPE_TABLE_HPP

#include <iostream>
#include <string>
#include "SymbolInfo.hpp"
#include "Hash.hpp"

using namespace std;

class ScopeTable
{
    int bucketSize;
    SymbolInfo **table;
    int id;             // Unique identifier for each scope table
    static int next_id; // Static counter to generate unique IDs
    int collisions;     // Counter for hash collisions
    int hashChoice;     // Selected hash function (1, 2, or 3)

    int getIndex(string name)
    {
        // Use the selected hash function
        return Hash::hash((const unsigned char *)name.c_str(), bucketSize, hashChoice);
    }

public:
    ScopeTable *parentScope;
    ScopeTable(int bucketSize, ScopeTable *parentScope = NULL, int hashChoice = 1)
    {
        this->bucketSize = bucketSize;
        this->parentScope = parentScope;
        this->id = next_id++;          // Assign and increment the ID
        this->collisions = 0;          // Initialize collision counter
        this->hashChoice = hashChoice; // Store the selected hash function
        table = new SymbolInfo *[bucketSize];
        for (int i = 0; i < bucketSize; i++)
            table[i] = NULL;
    }
    ~ScopeTable()
    {
        for (int i = 0; i < bucketSize; i++)
        {
            SymbolInfo *current = table[i];
            while (current != NULL)
            {
                SymbolInfo *temp = current;
                current = current->next;
                delete temp; // Delete nodes one by one
            }
        }
        delete[] table;
    }

    int getId() const
    {
        return id;
    }

    // Return pair of <success, position> where position is pair of <bucket, chain position>
    pair<bool, pair<int, int>> Insert(string name, string type)
    {
        // check if name already exists
        SymbolInfo *existingSymbol = Lookup(name).first;
        if (existingSymbol == NULL)
        {
            // Insert new symbol
            int index = getIndex(name);
            SymbolInfo *newSymbol = new SymbolInfo(name, type);
            int position = 1; // Position in chain (1-indexed)

            if (table[index] == NULL)
            {
                table[index] = newSymbol;
            }
            else
            {
                // Increment collision counter when there's already an item in this bucket
                collisions++;

                SymbolInfo *temp = table[index];
                position++;
                while (temp->next != NULL)
                {
                    temp = temp->next;
                    position++;
                }
                temp->next = newSymbol;
            }
            return {true, {index + 1, position}}; // Return 1-indexed positions
        }
        else
        {
            return {false, {0, 0}}; // Symbol already exists
        }
    }

    // Modified to return pair of SymbolInfo* and position (bucket, chain position)
    pair<SymbolInfo *, pair<int, int>> Lookup(string name)
    {
        int index = getIndex(name);
        SymbolInfo *curr = table[index];
        int position = 1;
        while (curr != NULL)
        {
            if (curr->get_name() == name)
            {
                return {curr, {index + 1, position}}; // Return 1-indexed positions
            }
            curr = curr->next;
            position++;
        }
        return {NULL, {0, 0}};
    }

    bool Delete(string name)
    {
        int index = getIndex(name);
        SymbolInfo *curr = table[index];
        SymbolInfo *prev = NULL;
        while (curr != NULL)
        {
            if (curr->get_name() == name)
            {
                if (prev == NULL)
                {
                    table[index] = curr->next;
                }
                else
                {
                    prev->next = curr->next;
                }
                delete curr;
                return true;
            }
            prev = curr;
            curr = curr->next;
        }
        return false;
    }
    ScopeTable *getParent()
    {
        return parentScope;
    }
    void setParent(ScopeTable *parentScope)
    {
        this->parentScope = parentScope;
    }
    void Print(string indent = "\t")
    {
        cout << indent << "ScopeTable# " << id << endl;
        for (int i = 0; i < bucketSize; i++)
        {
            cout << indent << i + 1 << "--> ";
            SymbolInfo *curr = table[i];
            while (curr != NULL)
            {
                cout << "<" << curr->get_name() << "," << curr->get_type() << "> ";
                curr = curr->next;
            }
            cout << endl;
        }
    }

    // Getter for collision count
    int getCollisions() const
    {
        return collisions;
    }
};

// Initialize the static counter
int ScopeTable::next_id = 1;

#endif // SCOPE_TABLE_HPP
