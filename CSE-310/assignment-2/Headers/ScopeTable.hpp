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
    int id;
    static int next_id;
    int collisions;
    int hashChoice;

    int getIndex(string name)
    {
        return Hash::hash((const unsigned char *)name.c_str(), bucketSize, hashChoice);
    }

public:
    ScopeTable *parentScope;
    ScopeTable(int bucketSize, ScopeTable *parentScope = NULL, int hashChoice = 1)
    {
        this->bucketSize = bucketSize;
        this->parentScope = parentScope;
        this->id = next_id++;
        this->collisions = 0;
        this->hashChoice = hashChoice;
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
                delete temp;
            }
        }
        delete[] table;
    }

    int getId() const
    {
        return id;
    }

    pair<bool, pair<int, int> > Insert(string name, string type)
    {
        SymbolInfo *existingSymbol = Lookup(name).first;
        if (existingSymbol == NULL)
        {
            int index = getIndex(name);
            SymbolInfo *newSymbol = new SymbolInfo(name, type);
            int position = 1;

            if (table[index] == NULL)
            {
                table[index] = newSymbol;
            }
            else
            {
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
            pair<int, int> pos(index + 1, position);
            return pair<bool, pair<int, int> >(true, pos);
        }
        else
        {
            pair<int, int> pos(0, 0);
            return pair<bool, pair<int, int> >(false, pos);
        }
    }

    pair<SymbolInfo *, pair<int, int> > Lookup(string name)
    {
        int index = getIndex(name);
        SymbolInfo *curr = table[index];
        int position = 1;
        while (curr != NULL)
        {
            if (curr->get_name() == name)
            {
                pair<int, int> pos(index + 1, position);
                return pair<SymbolInfo *, pair<int, int> >(curr, pos);
            }
            curr = curr->next;
            position++;
        }
        pair<int, int> pos(0, 0);
        return pair<SymbolInfo *, pair<int, int> >(NULL, pos);
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
    void Print(ofstream *outFile = nullptr, string indent = "\t")
    {
        if (outFile)
        {
            *outFile << "ScopeTable # " << id << endl;
            for (int i = 0; i < bucketSize; i++)
            {
                SymbolInfo *curr = table[i];
                if (curr != NULL)
                { // Only print if there are elements in this index
                    *outFile << i + 1 << " --> ";
                    while (curr != NULL)
                    {
                        *outFile << "< " << curr->get_name() << " : " << curr->get_type() << " >";
                        curr = curr->next;
                    }
                    *outFile << endl;
                }
            }
        }
        else
        {
            cout << "ScopeTable # " << id << endl;
            for (int i = 0; i < bucketSize; i++)
            {
                SymbolInfo *curr = table[i];
                if (curr != NULL)
                { // Only print if there are elements in this index
                    cout << indent << i + 1 << " --> ";
                    while (curr != NULL)
                    {
                        cout << "< " << curr->get_name() << " : " << curr->get_type() << " > ";
                        curr = curr->next;
                    }
                    cout << endl;
                }
            }
        }
    }

    int getCollisions() const
    {
        return collisions;
    }
};

int ScopeTable::next_id = 1;

#endif
