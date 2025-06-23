#include "SymbolTable.hpp"
#include <iostream>
#include <string>

int ScopeTable::next_id = 1;
// Constructor definition
SymbolTable::SymbolTable(int bucketSize, int hashChoice)
{
    this->bucketSize = bucketSize;
    this->hashChoice = hashChoice;
    currentScope = NULL;
    totalCollisions = 0;
    totalScopesCreated = 0;
}

// Destructor definition
SymbolTable::~SymbolTable()
{
    while (currentScope != NULL)
    {
        ScopeTable *temp = currentScope;
        currentScope = currentScope->getParent();
        delete temp;
    }
}

// Method definitions
void SymbolTable::EnterScope()
{
    ScopeTable *newScope = new ScopeTable(bucketSize, currentScope, hashChoice);
    std::cout << "\tScopeTable# " << newScope->getId() << " created" << std::endl;
    currentScope = newScope;
    totalScopesCreated++;
}

void SymbolTable::ExitScope()
{
    if (currentScope == NULL)
    {
        std::cout << "No current scope" << std::endl;
        return;
    }
    int exitingId = currentScope->getId();
    ScopeTable *temp = currentScope;

    totalCollisions += temp->getCollisions();

    currentScope = currentScope->getParent();
    delete temp;
    std::cout << "\tScopeTable# " << exitingId << " removed" << std::endl;
}

bool SymbolTable::Insert(std::string name, std::string type)
{
    if (currentScope == NULL)
    {
        std::cout << "Error: No current scope" << std::endl;
        return false;
    }
    auto [result, position] = currentScope->Insert(name, type);
    if (!result)
    {
        std::cout << "\t'" << name << "' already exists in the current ScopeTable" << std::endl;
    }
    else
    {
        std::cout << "\tInserted in ScopeTable# " << currentScope->getId()
                  << " at position " << position.first << ", " << position.second << std::endl;
    }
    return result;
}

bool SymbolTable::Remove(std::string name)
{
    if (currentScope == NULL)
    {
        std::cout << "Error: No current scope" << std::endl;
        return false;
    }

    auto [symbol, position] = currentScope->Lookup(name);
    if (symbol == NULL)
    {
        std::cout << "\tNot found in the current ScopeTable" << std::endl;
        return false;
    }

    int bucketPos = position.first;
    int chainPos = position.second;
    int scopeId = currentScope->getId();

    bool result = currentScope->Delete(name);
    if (result)
    {
        std::cout << "\tDeleted '" << name << "' from ScopeTable# " << scopeId
                  << " at position " << bucketPos << ", " << chainPos << std::endl;
    }

    return result;
}

SymbolInfo *SymbolTable::Lookup(std::string name)
{
    if (currentScope == NULL)
    {
        std::cout << "Error: No current scope" << std::endl;
        return NULL;
    }
    ScopeTable *curr = currentScope;
    while (curr != NULL)
    {
        auto [symbol, position] = curr->Lookup(name);
        if (symbol != NULL)
        {
            std::cout << "\t'" << name << "' found in ScopeTable# " << curr->getId()
                      << " at position " << position.first << ", " << position.second << std::endl;
            return symbol;
        }
        curr = curr->getParent();
    }
    std::cout << "\t'" << name << "' not found in any of the ScopeTables" << std::endl;
    return NULL;
}

void SymbolTable::PrintCurrentScopeTable()
{
    if (currentScope == NULL)
    {
        std::cout << "No current scope" << std::endl;
        return;
    }
    currentScope->Print();
}

void SymbolTable::PrintAllScopeTable()
{
    if (currentScope == NULL)
    {
        std::cout << "No current scope" << std::endl;
        return;
    }

    // The logic to count scopes is present in the provided snippet
    // but isn't strictly used for the printing loop's functionality directly.
    // Kept as-is to preserve the exact logic.
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
        std::string indentation = "\t";
        for (int i = 0; i < currentLevel; i++)
        {
            indentation += "\t";
        }

        temp->Print(indentation);
        temp = temp->getParent();
        currentLevel++;
    }
}

int SymbolTable::getCurrentScopeId()
{
    if (currentScope == NULL)
    {
        return 0;
    }
    return currentScope->getId();
}

int SymbolTable::getTotalCollisions() const
{
    return totalCollisions;
}

int SymbolTable::getTotalScopesCreated() const
{
    return totalScopesCreated;
}

int SymbolTable::getHashChoice() const
{
    return hashChoice;
}

std::string SymbolTable::getHashFunctionName() const
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

std::string SymbolTable::GetType(const std::string &name)
{
    SymbolInfo *info = Lookup(name);
    if (info != NULL)
    {
        return info->get_type();
    }
    return "";
}