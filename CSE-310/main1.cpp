#include<iostream>
#include<string>
#include"hashs.cpp"
#include"scopetable.cpp"
#include"symbolinfo.cpp"
#include"symboltable.cpp"
using namespace std;

#define READ(x) freopen(x, "r", stdin);
#define WRITE(x) freopen(x, "w", stdout);

using HashFunc = unsigned (*)(string, unsigned int);

int split(const string& s, string words[], int max_words) {
    int count = 0;
    size_t pos = 0;
    while (pos < s.length() && count < max_words) {
        while (pos < s.length() && isspace(s[pos])) pos++;
        size_t end = pos;
        while (end < s.length() && !isspace(s[end])) end++;
        if (pos < end) {
            words[count] = s.substr(pos, end - pos);
            count++;
            pos = end;
        }
    }
    return count;
}

void create_scope_table(string words[],int num_of_words, SymbolTable*st) {
    if(num_of_words!=1){
            cout << "\tNumber of parameters mismatch for the command S\n";
            return;
    }

   st->enterScope();
}

void Exit_scope_table(string words[],int num_of_words, SymbolTable*st) {

    if(num_of_words!=1){
            cout << "\tNumber of parameters mismatch for the command E\n";
            return;
    }
    st->exitScope();
}

void lookup(string words[],int num_of_words, SymbolTable*st) {
    if(num_of_words!=2){
            cout << "\tNumber of parameters mismatch for the command L\n";
            return;
    }
    string key = words[1];
    st->look_up(key);
}

void delete_symbol(string words[],int num_of_words, SymbolTable*st) {
    if(num_of_words!=2){
            cout << "\tNumber of parameters mismatch for the command D\n";
            return;
    }
    string key = words[1];
    st->erase(key);
}

void print(string words[],int num_of_words, SymbolTable*st) {
    if(num_of_words!=2){
            cout << "\tNumber of parameters mismatch for the command P\n";
            return;
    }
    string type = words[1];
    if(type == "C"){
        st->print_current_scop();
    }
    else if(type == "A"){
        st->print_all_scop();
    }
    else{
        cout << "\tInvalid parameter for the command P\n";
        return;
    }
}

void insert(string words[],int num_of_words, SymbolTable*st) {
    if(num_of_words<3){
            cout << "\tNumber of parameters mismatch for the command I\n";
            return;
    }
    string type = words[2];
    string name = words[1];
    string new_type="";



    if (type =="FUNCTION"){
        if(num_of_words < 4) {
            cout << "\tMust Have a return type\n";
            return;
        }
        new_type = words[2]+","+words[3]+"<==";
        new_type += "(";
        for(int i = 4; i < num_of_words; i++) {
            new_type += words[i];
            if(i != num_of_words-1) new_type += ",";
        }
        new_type += ")";
    }

    else if(type =="UNION" or type == "STRUCT"){
        int len = num_of_words-3;
        if(len%2){
            cout << "\tNumber of parameters mismatch for the command I\n";
            return;
        }
        new_type = words[2]+",";
        string result = "{";
        for (int i = 3; i < num_of_words; i += 2) {
            result += "(" + words[i] + "," + words[i + 1] + ")";
            if (i + 2 < num_of_words) result += ",";
        }
        result += "}";
        new_type += result;
    }
    else{
        new_type = words[2];
    }

    SymbolInfo si(name,new_type);
    st->insert(si);

}





int main(int argc, char* argv[]) {
    int bucket_size ;
    auto hashfunc = SDBMHash;
    
    if (argc != 3) {
        cerr << "Usage: " << argv[0] << " <input_file> <output_file>" << endl;
        return 1;
    }
    string intput = argv[1]+string(".txt");
    string output = argv[2]+string(".txt");
    READ(intput.c_str());
    WRITE(output.c_str());

    cin>> bucket_size;

    SymbolTable* st = new SymbolTable(bucket_size,hashfunc);
    string str;
    int cmd = 1;

    while(true){
        getline(cin>>ws,str);
        int MAX_WORDS = str.length();
        string words[MAX_WORDS];
        int num_words = split(str, words, MAX_WORDS);

        cout<<"Cmd "<<cmd<< ": ";
        for(int i = 0; i < num_words; i++){
            if(i == num_words-1) cout << words[i];
            else cout << words[i] << " ";
        }
        cout << endl;

        if(str.empty()) continue;
        if(str=="Q") break;


        if(num_words == 0) continue;

        if(words[0] == "I") {
            insert(words,num_words,st);

        }
        else if(words[0] == "D") {
            delete_symbol(words,num_words,st);
        }
        else if(words[0] == "L") {
            lookup(words,num_words,st);
        }
        else if(words[0] == "P") {
            print(words,num_words,st);
        }
        else if(words[0] == "S") {
            create_scope_table(words,num_words,st);
        }
        else if(words[0] == "E") {
            Exit_scope_table(words,num_words,st);
        }
        else{
            cout << "\tInvalid command\n";
            continue;
        }
        cmd++;
       
    }

    st->calculateCollisionratio();

    

 
    delete st;
    return 0;
}
