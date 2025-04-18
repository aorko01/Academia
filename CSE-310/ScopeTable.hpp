#include<iostream>
#include<string>
#include "SymbolInfo.hpp"
#include "Hash.hpp"

using namespace std;

class ScopeTable
{
    int bucketSize;
    SymbolInfo** table;
    int getIndex(string name)
    {
        return Hash::sdbm((unsigned char*)name.c_str()) % bucketSize;
    }

    public:
        ScopeTable* parentScope;
        ScopeTable(int bucketSize, ScopeTable* parentScope = NULL)
        {
            this->bucketSize = bucketSize;
            this->parentScope = parentScope;
            table = new SymbolInfo*[bucketSize];
            for(int i = 0; i < bucketSize; i++)
                table[i] = NULL;
        }
        ~ScopeTable()
        {
            for(int i = 0; i < bucketSize; i++)
            {
                if(table[i] != NULL)
                {
                    delete table[i];
                }
            }
            delete[] table;
        }

        bool Insert(string name, string type)
        {
            //check if name already exists
            SymbolInfo* existingSymbol = Lookup(name);
            if(existingSymbol == NULL)
            {
                // Insert new symbol
                int index = getIndex(name);
                SymbolInfo* newSymbol = new SymbolInfo(name, type);
                if(table[index] == NULL)
                {
                    table[index] = newSymbol;
                }
                else
                {
                    SymbolInfo* temp = table[index];
                    while(temp->next != NULL)
                    {
                        temp = temp->next;
                    }
                    temp->next = newSymbol;
                }
                return true;
            }
            else
            {
                return false; // Symbol already exists
            }
            
        }
        
        SymbolInfo* Lookup(string name)
        {
            int index = getIndex(name);
            SymbolInfo* curr= table[index];
            while(curr != NULL)
            {
                if(curr->get_name() == name)
                {
                    return curr;
                }
                curr = curr->next;
            }
            return NULL;
        }
        bool Delete(string name)
        {
            int index = getIndex(name);
            SymbolInfo* curr = table[index];
            SymbolInfo* prev = NULL;
            while(curr != NULL)
            {
                if(curr->get_name() == name)
                {
                    if(prev == NULL)
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
        ScopeTable* getParent()
        {
            return parentScope;
        }
        void setParent(ScopeTable* parentScope)
        {
            this->parentScope = parentScope;
        }
        void Print()
        {
            cout << "\t";
            cout << "ScopeTable# " << this << endl;
            for(int i=0; i<bucketSize; i++)
            {
                cout << "\t";
                cout << i+1;
                SymbolInfo* curr = table[i];
                while(curr != NULL)
                {
                    cout << " --> " << "(" << curr->get_name() << "," << curr->get_type() << ")";
                    curr = curr->next;
                }
                cout << endl;
            }
        }
};
