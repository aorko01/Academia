#ifndef SYMBOL_TABLE_HPP
#define SYMBOL_TABLE_HPP

#include <iostream>
#include <string>
#include "ScopeTable.hpp"

using namespace std;

class SymbolTable
{
private:
    ScopeTable *currentScope;
    int bucketSize;
    int totalCollisions;
    int totalScopesCreated;
    int hashChoice;

public:
    // Constructor declaration
    SymbolTable(int bucketSize, int hashChoice = 1);

    // Destructor declaration
    ~SymbolTable();

    // Method declarations only
    void EnterScope();
    void ExitScope();
    bool Insert(string name, string type);
    bool Remove(string name);
    SymbolInfo *Lookup(string name);
    void PrintCurrentScopeTable();
    void PrintAllScopeTable();
    int getCurrentScopeId();
    int getTotalCollisions() const;
    int getTotalScopesCreated() const;
    int getHashChoice() const;
    string getHashFunctionName() const;
    // Returns the type of a symbol by name, or empty string if not found
    std::string GetType(const std::string &name);
};

#endif