#include <iostream>
#include <string>
#include "SymbolInfo.hpp"
#include "ScopeTable.hpp"
#include "SymbolTable.hpp"
#include "Hash.hpp"

using namespace std;

#define READ(x) freopen(x, "r", stdin);
#define WRITE(x) freopen(x, "w", stdout);

// Hash function wrapper to match the expected format
unsigned SDBMHash(string s, unsigned int n)
{
    return Hash::sdbm((unsigned char *)s.c_str()) % n;
}

// Split a string into words
int split(const string &s, string words[], int max_words)
{
    int count = 0;
    size_t pos = 0;
    while (pos < s.length() && count < max_words)
    {
        while (pos < s.length() && isspace(s[pos]))
            pos++;
        size_t end = pos;
        while (end < s.length() && !isspace(s[end]))
            end++;
        if (pos < end)
        {
            words[count] = s.substr(pos, end - pos);
            count++;
            pos = end;
        }
    }
    return count;
}

void create_scope_table(string words[], int num_of_words, SymbolTable *st)
{
    if (num_of_words != 1)
    {
        cout << "\tNumber of parameters mismatch for the command S\n";
        return;
    }

    st->EnterScope();
}

void exit_scope_table(string words[], int num_of_words, SymbolTable *st)
{
    if (num_of_words != 1)
    {
        cout << "\tNumber of parameters mismatch for the command E\n";
        return;
    }

    st->ExitScope();
}

void lookup(string words[], int num_of_words, SymbolTable *st)
{
    if (num_of_words != 2)
    {
        cout << "\tNumber of parameters mismatch for the command L\n";
        return;
    }

    string name = words[1];
    SymbolInfo *symbol = st->Lookup(name);
    // The output is already displayed by the Lookup function
}

void delete_symbol(string words[], int num_of_words, SymbolTable *st)
{
    if (num_of_words != 2)
    {
        cout << "\tNumber of parameters mismatch for the command D\n";
        return;
    }

    string name = words[1];
    bool success = st->Remove(name);

    // No need for additional output here since the SymbolTable class already handles it
}

void print(string words[], int num_of_words, SymbolTable *st)
{
    if (num_of_words != 2)
    {
        cout << "\tNumber of parameters mismatch for the command P\n";
        return;
    }

    string type = words[1];
    if (type == "C")
    {
        st->PrintCurrentScopeTable();
    }
    else if (type == "A")
    {
        st->PrintAllScopeTable();
    }
    else
    {
        cout << "\tInvalid parameter for the command P\n";
        return;
    }
}

void insert(string words[], int num_of_words, SymbolTable *st)
{
    if (num_of_words < 3)
    {
        cout << "\tNumber of parameters mismatch for the command I\n";
        return;
    }

    string name = words[1];
    string type = words[2];
    string new_type = "";

    if (type == "FUNCTION")
    {
        if (num_of_words < 4)
        {
            cout << "\tMust Have a return type\n";
            return;
        }
        new_type = words[2] + "," + words[3] + "<==";
        new_type += "(";
        for (int i = 4; i < num_of_words; i++)
        {
            new_type += words[i];
            if (i != num_of_words - 1)
                new_type += ",";
        }
        new_type += ")";
    }
    else if (type == "UNION" || type == "STRUCT")
    {
        int len = num_of_words - 3;
        if (len % 2)
        {
            cout << "\tNumber of parameters mismatch for the command I\n";
            return;
        }
        new_type = words[2] + ",";
        string result = "{";
        for (int i = 3; i < num_of_words; i += 2)
        {
            result += "(" + words[i] + "," + words[i + 1] + ")";
            if (i + 2 < num_of_words)
                result += ",";
        }
        result += "}";
        new_type += result;
    }
    else
    {
        new_type = words[2];
    }

    st->Insert(name, new_type);
}

int main()
{
    int bucket_size;

    // Taking input from terminal instead of files
    cin >> bucket_size;

    // Create a symbol table with the given bucket size
    SymbolTable *st = new SymbolTable(bucket_size);

    // Enter the first scope
    st->EnterScope();

    string str;
    int cmd = 1;

    // cout << "Available commands:\n";
    // cout << "I <name> <type> [additional parameters] - Insert a symbol\n";
    // cout << "L <name> - Lookup a symbol\n";
    // cout << "D <name> - Delete a symbol\n";
    // cout << "P <A/C> - Print All scopes (A) or Current scope (C)\n";
    // cout << "S - Enter a new scope\n";
    // cout << "E - Exit current scope\n";
    // cout << "Q - Quit the program\n\n";

    while (true)
    {
        getline(cin >> ws, str);
        if (str.empty())
            continue;

        int MAX_WORDS = str.length();
        string words[MAX_WORDS];
        int num_words = split(str, words, MAX_WORDS);

        cout << "Cmd " << cmd << ": ";
        for (int i = 0; i < num_words; i++)
        {
            if (i == num_words - 1)
                cout << words[i];
            else
                cout << words[i] << " ";
        }
        cout << endl;

        // Check for quit command
        if (str == "Q")
            break;

        if (num_words == 0)
            continue;

        // Process commands
        if (words[0] == "I")
        {
            insert(words, num_words, st);
        }
        else if (words[0] == "D")
        {
            delete_symbol(words, num_words, st);
        }
        else if (words[0] == "L")
        {
            lookup(words, num_words, st);
        }
        else if (words[0] == "P")
        {
            print(words, num_words, st);
        }
        else if (words[0] == "S")
        {
            create_scope_table(words, num_words, st);
        }
        else if (words[0] == "E")
        {
            exit_scope_table(words, num_words, st);
        }
        else
        {
            cout << "\tInvalid command\n";
            continue;
        }

        cmd++;
    }

    cout << "Program terminated.\n";
    delete st;
    return 0;
}