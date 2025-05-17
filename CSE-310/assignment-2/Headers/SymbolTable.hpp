#ifndef SYMBOL_TABLE_HPP
#define SYMBOL_TABLE_HPP

#include <iostream>
#include <string>
#include <fstream>

#include "ScopeTable.hpp"

using namespace std;

class SymbolTable
{
    ScopeTable *currentScope;
    int bucketSize;
    int totalCollisions;
    int totalScopesCreated;
    int hashChoice;
    ofstream *outputFile; // Output file stream

public:
    SymbolTable(int bucketSize, int hashChoice = 1, ofstream *outFile = nullptr)
    {
        this->bucketSize = bucketSize;
        this->hashChoice = hashChoice;
        this->outputFile = outFile;
        currentScope = NULL;
        totalCollisions = 0;
        totalScopesCreated = 0;
    }
    ~SymbolTable()
    {
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
        // if (outputFile)
        //     *outputFile << "\tScopeTable# " << newScope->getId() << " created" << endl;
        // else
        //     cout << "\tScopeTable# " << newScope->getId() << " created" << endl;
        currentScope = newScope;
        totalScopesCreated++;
    }
    void ExitScope()
    {
        if (currentScope == NULL)
        {
            if (outputFile)
                *outputFile << "No current scope" << endl;
            else
                cout << "No current scope" << endl;
            return;
        }
        int exitingId = currentScope->getId();
        ScopeTable *temp = currentScope;

        totalCollisions += temp->getCollisions();

        currentScope = currentScope->getParent();
        delete temp;
        // if (outputFile)
        //     *outputFile << "\tScopeTable# " << exitingId << " removed" << endl;
        // else
        //     cout << "\tScopeTable# " << exitingId << " removed" << endl;
    }
    bool Insert(string name, string type)
    {
        if (currentScope == NULL)
        {
            // if (outputFile)
            //     *outputFile << "Error: No current scope" << endl;
            // else
            //     cout << "Error: No current scope" << endl;
            return false;
        }
        pair<bool, pair<int, int> > resultPair = currentScope->Insert(name, type);
        bool result = resultPair.first;
        pair<int, int> position = resultPair.second;
        if (!result)
        {
            if (outputFile)
                *outputFile << "< " << name << " : " << type << " > already exists in ScopeTable#" << currentScope->getId() << " at position " << position.first << ", " << position.second << endl;
            else
                cout << "< " << name << " : " << type << " > already exists in ScopeTable#" << currentScope->getId() << " at position " << position.first << ", " << position.second << endl;
        }
        // else
        // {
        //     if (outputFile)
        //         *outputFile << "\tInserted in ScopeTable# " << currentScope->getId()
        //                     << " at position " << position.first << ", " << position.second << endl;
        //     else
        //         cout << "\tInserted in ScopeTable# " << currentScope->getId()
        //              << " at position " << position.first << ", " << position.second << endl;
        // }
        return result;
    }
    bool Remove(string name)
    {
        if (currentScope == NULL)
        {
            if (outputFile)
                *outputFile << "Error: No current scope" << endl;
            else
                cout << "Error: No current scope" << endl;
            return false;
        }

        pair<SymbolInfo *, pair<int, int> > lookupResult = currentScope->Lookup(name);
        SymbolInfo *symbol = lookupResult.first;
        pair<int, int> position = lookupResult.second;
        if (symbol == NULL)
        {
            if (outputFile)
                *outputFile << "\tNot found in the current ScopeTable" << endl;
            else
                cout << "\tNot found in the current ScopeTable" << endl;
            return false;
        }

        int bucketPos = position.first;
        int chainPos = position.second;
        int scopeId = currentScope->getId();

        bool result = currentScope->Delete(name);
        if (result)
        {
            if (outputFile)
                *outputFile << "\tDeleted '" << name << "' from ScopeTable# " << scopeId
                            << " at position " << bucketPos << ", " << chainPos << endl;
            else
                cout << "\tDeleted '" << name << "' from ScopeTable# " << scopeId
                     << " at position " << bucketPos << ", " << chainPos << endl;
        }

        return result;
    }
    SymbolInfo *Lookup(string name)
    {
        if (currentScope == NULL)
        {
            if (outputFile)
                *outputFile << "Error: No current scope" << endl;
            else
                cout << "Error: No current scope" << endl;
            return NULL;
        }
        ScopeTable *curr = currentScope;
        while (curr != NULL)
        {
            pair<SymbolInfo *, pair<int, int> > lookupResult = curr->Lookup(name);
            SymbolInfo *symbol = lookupResult.first;
            pair<int, int> position = lookupResult.second;
            if (symbol != NULL)
            {
                if (outputFile)
                    *outputFile << "\t'" << name << "' found in ScopeTable# " << curr->getId()
                                << " at position " << position.first << ", " << position.second << endl;
                else
                    cout << "\t'" << name << "' found in ScopeTable# " << curr->getId()
                         << " at position " << position.first << ", " << position.second << endl;
                return symbol;
            }
            curr = curr->getParent();
        }
        if (outputFile)
            *outputFile << "\t'" << name << "' not found in any of the ScopeTables" << endl;
        else
            cout << "\t'" << name << "' not found in any of the ScopeTables" << endl;
        return NULL;
    }
    void PrintCurrentScopeTable()
    {
        if (currentScope == NULL)
        {
            if (outputFile)
                *outputFile << "No current scope" << endl;
            else
                cout << "No current scope" << endl;
            return;
        }
        currentScope->Print(outputFile);
    }
    void PrintAllScopeTable()
    {
        if (currentScope == NULL)
        {
            if (outputFile)
                *outputFile << "No current scope" << endl;
            else
                cout << "No current scope" << endl;
            return;
        }

        int scopeCount = 0;
        ScopeTable *temp = currentScope;
        while (temp != NULL)
        {
            scopeCount++;
            temp = temp->getParent();
        }

        temp = currentScope;
        int currentLevel = 0;
        while (temp != NULL)
        {
            // string indentation = "\t";
            for (int i = 0; i < currentLevel; i++)
            {
                // indentation += "\t";
            }

            temp->Print(outputFile, "");
            temp = temp->getParent();
            currentLevel++;
        }
    }

    int getCurrentScopeId()
    {
        if (currentScope == NULL)
        {
            return 0;
        }
        return currentScope->getId();
    }

    int getTotalCollisions() const
    {
        return totalCollisions;
    }

    int getTotalScopesCreated() const
    {
        return totalScopesCreated;
    }

    int getHashChoice() const
    {
        return hashChoice;
    }

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

#endif
