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

        ScopeTable *newScope = new ScopeTable(bucketSize, currentScope);
        currentScope = newScope;
    }
    void ExitScope()
    {
        if (currentScope == NULL)
        {
            cout << "No current scope" << endl;
            return;
        }
        ScopeTable *temp = currentScope;
        currentScope = currentScope->getParent();
        delete temp;
    }
    bool Insert(string name, string type)
    {
        //assumed that the insertion would only happen if there is a scope table already defined
        if (currentScope == NULL)
        {
            cout << "Error: No current scope" << endl;
            return false;
        }
        bool result = currentScope->Insert(name, type);
        if(!result )
        {
            cout << "Error: " << name << " already exists in the current scope" << endl;
        }
        return result;
    }
    bool Remove(string name)
    {
        if(currentScope == NULL)
        {
            cout << "Error: No current scope" << endl;
            return false;
        }
        bool result = currentScope->Delete(name);
        if(!result)
        {
            cout << "Error: " << name << " not found in the current scope" << endl;
        }
        return result;
    }
    SymbolInfo *Lookup(string name)
    {
        if (currentScope == NULL)
        {
            cout << "Error: No current scope" << endl;
            return NULL;
        }
        ScopeTable* curr = currentScope;
        while(curr != NULL)
        {
            SymbolInfo* symbol = curr->Lookup(name);
            if(symbol != NULL)
            {
                return symbol;
            }
            curr = curr->getParent();
        }
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
