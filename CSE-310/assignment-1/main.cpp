#include <iostream>
#include <string>
#include "SymbolInfo.hpp"
#include "ScopeTable.hpp"
#include "SymbolTable.hpp"
#include "Hash.hpp"

using namespace std;

#define READ(x) freopen(x, "r", stdin);
#define WRITE(x) freopen(x, "w", stdout);

unsigned SDBMHash(string s, unsigned int n)
{
    return Hash::sdbm((unsigned char *)s.c_str(), n);
}

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
    int hash_choice;

    freopen("sample_input.txt", "r", stdin);
    cin >> bucket_size;

    freopen("/dev/tty", "r", stdin);
    cout << "Select hash function:" << endl;
    cout << "  1. SDBM (default)" << endl;
    cout << "  2. DJB2" << endl;
    cout << "  3. FNV-1a" << endl;
    cout << "Enter your choice (1-3): ";
    cin >> hash_choice;

    if (hash_choice < 1 || hash_choice > 3)
    {
        cout << "Invalid choice. Using default (SDBM)." << endl;
        hash_choice = 1;
    }

    cout << "Using hash function: ";
    switch (hash_choice)
    {
    case 1:
        cout << "SDBM";
        break;
    case 2:
        cout << "DJB2";
        break;
    case 3:
        cout << "FNV-1a";
        break;
    }
    cout << endl
         << endl;

    freopen("sample_input.txt", "r", stdin);
    freopen("output.txt", "w", stdout);

    string dummy;
    getline(cin, dummy);

    SymbolTable *st = new SymbolTable(bucket_size, hash_choice);

    string str;
    int cmd = 1;

    st->EnterScope();

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

        if (str == "Q")
        {
            break;
        }

        if (num_words == 0)
            continue;

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
            if (st->getCurrentScopeId() == 1)
            {
                cout << "\tCannot delete the root scope (ID 1)" << endl;
            }
            else
            {
                exit_scope_table(words, num_words, st);
            }
        }
        else
        {
            cout << "\tInvalid command\n";
            continue;
        }

        cmd++;
    }

    while (st->getCurrentScopeId() > 0)
    {
        st->ExitScope();
    }

    int totalCollisions = st->getTotalCollisions();
    int totalScopesCreated = st->getTotalScopesCreated();
    double collisionRate = 0;
    if (st->getTotalScopesCreated() > 0)
    {
        collisionRate = static_cast<double>(totalCollisions) /
                        (bucket_size * totalScopesCreated);
    }

    freopen("report.txt", "w", stdout);
    cout << "\tHash function used: " << st->getHashFunctionName() << endl;
    cout << "\tTotal collisions: " << totalCollisions << endl;
    cout << "\tTotal scope tables created: " << totalScopesCreated << endl;
    cout << "\tCollision rate: " << collisionRate << endl;

    delete st;
    return 0;
}