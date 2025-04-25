#ifndef SYMBOL_TABLE_HPP
#define SYMBOL_TABLE_HPP

#include <iostream>
#include <string>

#include "ScopeTable.hpp"

using namespace std;

class SymbolTable
{
    ScopeTable *currentScope;
    int bucketSize;
    int totalCollisions;    // Track total collisions across all scopes
    int totalScopesCreated; // Track total number of scope tables created
    int hashChoice;         // Selected hash function (1, 2, or 3)

public:
    SymbolTable(int bucketSize, int hashChoice = 1)
    {
        this->bucketSize = bucketSize;
        this->hashChoice = hashChoice;
        currentScope = NULL;
        totalCollisions = 0;    // Initialize total collisions to 0
        totalScopesCreated = 0; // Initialize total scopes created to 0
    }
    ~SymbolTable()
    {
        // Explicitly exit all remaining scopes before deleting
        while (currentScope != NULL)
        {
            ScopeTable *temp = currentScope;
            currentScope = currentScope->getParent();
            delete temp;
        }
    }
    void EnterScope()
    {
        ScopeTable *newScope = new ScopeTable(bucketSize, currentScope, hashChoice);
        cout << "\tScopeTable# " << newScope->getId() << " created" << endl;
        currentScope = newScope;
        totalScopesCreated++; // Increment the counter when a new scope is created
    }
    void ExitScope()
    {
        if (currentScope == NULL)
        {
            cout << "No current scope" << endl;
            return;
        }
        int exitingId = currentScope->getId();
        ScopeTable *temp = currentScope;

        // Update total collisions before deleting the scope
        totalCollisions += temp->getCollisions();

        currentScope = currentScope->getParent();
        delete temp;
        cout << "\tScopeTable# " << exitingId << " removed" << endl;
    }
    bool Insert(string name, string type)
    {
        // assumed that the insertion would only happen if there is a scope table already defined
        if (currentScope == NULL)
        {
            cout << "Error: No current scope" << endl;
            return false;
        }
        auto [result, position] = currentScope->Insert(name, type);
        if (!result)
        {
            cout << "\t'" << name << "' already exists in the current ScopeTable" << endl;
        }
        else
        {
            cout << "\tInserted in ScopeTable# " << currentScope->getId()
                 << " at position " << position.first << ", " << position.second << endl;
        }
        return result;
    }
    bool Remove(string name)
    {
        if (currentScope == NULL)
        {
            cout << "Error: No current scope" << endl;
            return false;
        }

        auto [symbol, position] = currentScope->Lookup(name);
        if (symbol == NULL)
        {
            cout << "\tNot found in the current ScopeTable" << endl;
            return false;
        }

        // Store position information before deletion
        int bucketPos = position.first;
        int chainPos = position.second;
        int scopeId = currentScope->getId();

        bool result = currentScope->Delete(name);
        if (result)
        {
            cout << "\tDeleted '" << name << "' from ScopeTable# " << scopeId
                 << " at position " << bucketPos << ", " << chainPos << endl;
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
        ScopeTable *curr = currentScope;
        while (curr != NULL)
        {
            auto [symbol, position] = curr->Lookup(name);
            if (symbol != NULL)
            {
                cout << "\t'" << name << "' found in ScopeTable# " << curr->getId()
                     << " at position " << position.first << ", " << position.second << endl;
                return symbol;
            }
            curr = curr->getParent();
        }
        cout << "\t'" << name << "' not found in any of the ScopeTables" << endl;
        return NULL;
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

        // Get all scopes in order and count them
        int scopeCount = 0;
        ScopeTable *temp = currentScope;
        while (temp != NULL)
        {
            scopeCount++;
            temp = temp->getParent();
        }

        // Print scopes with proper indentation
        temp = currentScope;
        int currentLevel = 0;
        while (temp != NULL)
        {
            string indentation = "\t";
            // Apply proper indentation based on level
            for (int i = 0; i < currentLevel; i++)
            {
                indentation += "\t";
            }

            temp->Print(indentation);
            temp = temp->getParent();
            currentLevel++;
        }
    }

    // Get the ID of the current scope table (or 0 if there is none)
    int getCurrentScopeId()
    {
        if (currentScope == NULL)
        {
            return 0;
        }
        return currentScope->getId();
    }

    // Getter for total collisions
    int getTotalCollisions() const
    {
        return totalCollisions;
    }

    // Getter for total scopes created
    int getTotalScopesCreated() const
    {
        return totalScopesCreated;
    }

    // Getter for hash function choice
    int getHashChoice() const
    {
        return hashChoice;
    }

    // String representation of the hash function name
    string getHashFunctionName() const
    {
        switch (hashChoice)
        {
        case 1:
            return "SDBM";
        case 2:
            return "DJB2";
        case 3:
            return "FNV-1a";
        default:
            return "Unknown";
        }
    }
};

#endif // SYMBOL_TABLE_HPP
