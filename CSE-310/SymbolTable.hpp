#include <iostream>
#include <string>

#include "ScopeTable.hpp"

using namespace std;

class SymbolTable
{
    ScopeTable *currentScope;
    int bucketSize;

public:
    SymbolTable(int bucketSize)
    {
        this->bucketSize = bucketSize;
        currentScope = NULL;
    }
    ~SymbolTable()
    {
        delete currentScope;
    }
    void EnterScope()
    {
    }
    void ExitScope()
    {
    }
    void Insert(string name, string type)
    {
    }
    bool Remove(string name)
    {
        if (currentScope == NULL)
        {
            return false;
        }
        return currentScope->Delete(name);
    }
    SymbolInfo *Lookup(string name)
    {
        if (currentScope == NULL)
        {
            return NULL;
        }
        return currentScope->Lookup(name);
    }
    void PrintCurrentScopeTable()
    {
        if (currentScope == NULL)
        {
            cout << "No current scope" << endl;
            return;
        }
        currentScope->Print();
    }
    void PrintAllScopeTable()
    {
        if (currentScope == NULL)
        {
            cout << "No current scope" << endl;
            return;
        }
        ScopeTable *temp = currentScope;
        while (temp != NULL)
        {
            temp->Print();
            temp = temp->getParent();
        }
    }
};
