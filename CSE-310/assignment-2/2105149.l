%option noyywrap

%{
#include <iostream>
#include <string>
#include <algorithm>
#include <fstream>
#include "Headers/SymbolTable.hpp"
using namespace std;


ofstream outputLogFile;
ofstream outputTokenFile;  
SymbolTable* symbolTable = nullptr;


string toUpperCase(string s) {
    string result = s;
    transform(result.begin(), result.end(), result.begin(), ::toupper);
    return result;
}


string processStringLiteral(string s) {
    string result = "";
    for (int i = 0; i < s.length(); i++) {
        if (s[i] == '\\' && i+1 < s.length()) {
            char nextChar = s[i+1];
            if (nextChar == 'n') result += '\n';
            else if (nextChar == 't') result += '\t';
            else if (nextChar == '\\') result += '\\';
            else if (nextChar == '\"') result += '\"';
            else if (nextChar == 'a') result += '\a';
            else if (nextChar == 'f') result += '\f';
            else if (nextChar == 'r') result += '\r';
            else if (nextChar == 'b') result += '\b';
            else if (nextChar == 'v') result += '\v';
            else if (nextChar == '0') result += '\0';
            else result += nextChar; 
            i++;  
        } else {
            result += s[i];
        }
    }
    return result;
}

char processEscapeSequence(string s) {
    if (s == "\\n") return '\n';
    if (s == "\\t") return '\t';
    if (s == "\\\\") return '\\';
    if (s == "\\'") return '\'';
    if (s == "\\\"") return '\"';
    if (s == "\\a") return '\a';
    if (s == "\\f") return '\f';
    if (s == "\\r") return '\r';
    if (s == "\\b") return '\b';
    if (s == "\\v") return '\v';
    if (s == "\\0") return '\0';
    return s[1]; 
}
%}
KEYWORD	"if"|"else"|"goto"|"for"|"while"|"long"|"do"|"break"|"short"|"int"|"char"|"static"|"float"|"double"|"unsigned"|"void"|"return"|"switch"|"case"|"default"|"continue"
ADDOP   [+\-]
MULOP   [*/\%]
INCOP   "++"|"--"
RELOP   "<"|"<="|">"|">="|"=="|"!="
ASSIGNOP "="
LOGICOP "&&"|"||"
NOT     "!"
LPAREN  "("
RPAREN  ")"
LCURL   "{"
RCURL   "}"
LTHIRD  "["
RTHIRD  "]"
COMMA   ","
SEMICOLON ";"
DIGIT [0-9]
LETTER [a-zA-Z]
ALPHANUMERIC [a-zA-Z0-9_]
IDENTIFIER (_|{LETTER})({ALPHANUMERIC})*
CONST_INT {DIGIT}+
CONST_FLOAT {DIGIT}*\.{DIGIT}+([Ee][+-]?{DIGIT}+)?|{DIGIT}+\.([Ee][+-]?{DIGIT}+)?|{DIGIT}+[Ee][+-]?{DIGIT}+

%x STRING
%x Single_line_comment
%x Multi_line_comment
%x CHAR_CONST


%{
    string string_buffer;
    string current_string_text; 
    int line_count = 1;         
    int current_string_line_count = 0;
    string comment_text;        
    string star_comment_text;   
    int initial_comment_line;   
    int error_count = 0;       
    string char_buffer;         
%}

%%

{KEYWORD} {
    string token = yytext;
    string upperCaseToken = toUpperCase(token);
    
    outputLogFile << "Line no " << line_count << ": Token <" << upperCaseToken << "> Lexeme " << yytext << " found" << endl << endl;
    outputTokenFile << "<" << upperCaseToken << "> ";
}

{CONST_INT} {
    outputLogFile << "Line no " << line_count << ": Token <CONST_INT> Lexeme " << yytext << " found" << endl << endl;
    outputTokenFile << "<CONST_INT, " << yytext << "> ";
    
    bool inserted = symbolTable->Insert(yytext, "CONST_INT");
    if(inserted) {
        symbolTable->PrintAllScopeTable();
        outputLogFile << endl;
    }
}

{CONST_FLOAT} {
    outputLogFile << "Line no " << line_count << ": Token <CONST_FLOAT> Lexeme " << yytext << " found" << endl << endl;
    outputTokenFile << "<CONST_FLOAT, " << yytext << "> ";
    
    bool inserted = symbolTable->Insert(yytext, "CONST_FLOAT");
    if(inserted) {
        symbolTable->PrintAllScopeTable();
        outputLogFile << endl;
    }
}

{DIGIT}+(\.{DIGIT}+)?E[+-]?{DIGIT}+(\.){DIGIT}*((\.){DIGIT}*)* {
    error_count++;
    outputLogFile << "Error at line no " << line_count << ": Ill formed number " << yytext << endl << endl;
}

{DIGIT}+(\.){DIGIT}*(\.).* {
    error_count++;
    outputLogFile << "Error at line no " << line_count << ": Too many decimal points " << yytext << endl << endl;
}

"\'" {
    BEGIN(CHAR_CONST);
    char_buffer = "\'"; 
}

<CHAR_CONST>"\'" {

    char_buffer += "\'";
    
    if (char_buffer == "\'\'") {
        error_count++;
        outputLogFile << "Error at line no " << line_count << ": Empty character constant error " << char_buffer << endl << endl;
    }

    else if (char_buffer == "\'\\\'" || char_buffer == "\'\\\'") {
        error_count++;
        outputLogFile << "Error at line no " << line_count << ": Unterminated character " << char_buffer << endl << endl;
    }

    else if (char_buffer.length() > 3 && char_buffer[1] == '\\') {
        string content = char_buffer.substr(1, char_buffer.length()-2);

        if (content.length() >= 2) {
            char ch = processEscapeSequence(content);
            outputLogFile << "Line no " << line_count << ": Token <CONST_CHAR> Lexeme " << char_buffer 
                  << " found --> <CONST_CHAR, " << ch << ">" << endl << endl;
            outputTokenFile << "<CONST_CHAR, " << ch << "> ";
            
            string charValue(1, ch);
            bool inserted = symbolTable->Insert(charValue, "CONST_CHAR");
            if(inserted) {
                symbolTable->PrintAllScopeTable();
                outputLogFile << endl;
            }
        } else {
            error_count++;
            outputLogFile << "Error at line no " << line_count << ": Unterminated character " << char_buffer << endl << endl;
        }
    }

    else if (char_buffer.length() > 3) {
        error_count++;
        outputLogFile << "Error at line no " << line_count << ": Multi character constant error " << char_buffer << endl << endl;
    }

    else if (char_buffer.length() == 3) {
        char ch = char_buffer[1];
        outputLogFile << "Line no " << line_count << ": Token <CONST_CHAR> Lexeme " << char_buffer 
              << " found --> <CONST_CHAR, " << ch << ">" << endl << endl;
        outputTokenFile << "<CONST_CHAR, " << ch << "> ";
        
        string charValue(1, ch);
        bool inserted = symbolTable->Insert(charValue, "CONST_CHAR");
        if(inserted) {
            symbolTable->PrintAllScopeTable();
            outputLogFile << endl;
        }
    }
    
    BEGIN(INITIAL);
}

<CHAR_CONST>\n {
    error_count++;
    outputLogFile << "Error at line no " << line_count << ": Unterminated character " << char_buffer << endl << endl;
    line_count++;
    BEGIN(INITIAL);
}

<CHAR_CONST>. {
    char_buffer += yytext;
}

<CHAR_CONST><<EOF>> {
    error_count++;
    outputLogFile << "Error at line no " << line_count << ": Unterminated character " << char_buffer << endl << endl;
    BEGIN(INITIAL);
}

{ADDOP} {
    outputLogFile << "Line no " << line_count << ": Token <ADDOP> Lexeme " << yytext << " found" << endl << endl;
    outputTokenFile << "<ADDOP, " << yytext << "> ";
}

{MULOP} {
    outputLogFile << "Line no " << line_count << ": Token <MULOP> Lexeme " << yytext << " found" << endl << endl;
    outputTokenFile << "<MULOP, " << yytext << "> ";
}

{INCOP} {
    outputLogFile << "Line no " << line_count << ": Token <INCOP> Lexeme " << yytext << " found" << endl << endl;
    outputTokenFile << "<INCOP, " << yytext << "> ";
}

{RELOP} {
    outputLogFile << "Line no " << line_count << ": Token <RELOP> Lexeme " << yytext << " found" << endl << endl;
    outputTokenFile << "<RELOP, " << yytext << "> ";
}

{ASSIGNOP} {
    outputLogFile << "Line no " << line_count << ": Token <ASSIGNOP> Lexeme " << yytext << " found" << endl << endl;
    outputTokenFile << "<ASSIGNOP, " << yytext << "> ";
}

{LOGICOP} {
    outputLogFile << "Line no " << line_count << ": Token <LOGICOP> Lexeme " << yytext << " found" << endl << endl;
    outputTokenFile << "<LOGICOP, " << yytext << "> ";
}

{NOT} {
    outputLogFile << "Line no " << line_count << ": Token <NOT> Lexeme " << yytext << " found" << endl << endl;
    outputTokenFile << "<NOT, " << yytext << "> ";
}

{LPAREN} {
    outputLogFile << "Line no " << line_count << ": Token <LPAREN> Lexeme " << yytext << " found" << endl << endl;
    outputTokenFile << "<LPAREN, " << yytext << "> ";
}

{RPAREN} {
    outputLogFile << "Line no " << line_count << ": Token <RPAREN> Lexeme " << yytext << " found" << endl << endl;
    outputTokenFile << "<RPAREN, " << yytext << "> ";
}

{LCURL} {
    outputLogFile << "Line no " << line_count << ": Token <LCURL> Lexeme " << yytext << " found" << endl << endl;
    outputTokenFile << "<LCURL, " << yytext << "> ";
    
    symbolTable->EnterScope();
}

{RCURL} {
    outputLogFile << "Line no " << line_count << ": Token <RCURL> Lexeme " << yytext << " found" << endl << endl;
    outputTokenFile << "<RCURL, " << yytext << "> ";
    
    symbolTable->ExitScope();
}

{LTHIRD} {
    outputLogFile << "Line no " << line_count << ": Token <LTHIRD> Lexeme " << yytext << " found" << endl << endl;
    outputTokenFile << "<LTHIRD, " << yytext << "> ";
}

{RTHIRD} {
    outputLogFile << "Line no " << line_count << ": Token <RTHIRD> Lexeme " << yytext << " found" << endl << endl;
    outputTokenFile << "<RTHIRD, " << yytext << "> ";
}

{COMMA} {
    outputLogFile << "Line no " << line_count << ": Token <COMMA> Lexeme " << yytext << " found" << endl << endl;
    outputTokenFile << "<COMMA, " << yytext << "> ";
}

{SEMICOLON} {
    outputLogFile << "Line no " << line_count << ": Token <SEMICOLON> Lexeme " << yytext << " found" << endl << endl;
    outputTokenFile << "<SEMICOLON, " << yytext << "> ";
}

{DIGIT}+{ALPHANUMERIC}+ {
    error_count++;
    outputLogFile << "Error at line no " << line_count << ": Invalid prefix on ID or invalid suffix on Number " << yytext << endl << endl;
}

{IDENTIFIER} {
    outputLogFile << "Line no " << line_count << ": Token <ID> Lexeme " << yytext << " found" << endl << endl;
    outputTokenFile << "<ID, " << yytext << "> ";

    bool inserted = symbolTable->Insert(yytext, "ID");
    if(inserted) {
        symbolTable->PrintAllScopeTable();
        outputLogFile << endl;
    }
}

[ \t\f\r\v]+ {
}

\n {
    line_count++;
}

\"      { 

    BEGIN(STRING);
    string_buffer = "";
    current_string_text = "\"";  
    current_string_line_count = 0;
}

<STRING>\"      { 
    current_string_text += "\"";  
    outputLogFile << "Line no " << line_count << ": Token <STRING> Lexeme " << current_string_text 
              << " found --> <STRING, " << string_buffer << ">" << endl << endl;
    outputTokenFile << "<STRING, " << string_buffer << "> ";
    
    symbolTable->Insert(string_buffer, "STRING");
    symbolTable->PrintAllScopeTable();
    outputLogFile << endl;
    
    BEGIN(INITIAL);  
}

<STRING>\\\n    { 

    current_string_text += yytext;
    line_count++;
    current_string_line_count++;
}

<STRING>\\n     { 

    current_string_text += yytext;
    string_buffer += '\n';
}

<STRING>\\t     { 

    current_string_text += yytext;
    string_buffer += '\t';
}

<STRING>\\\\    { 

    current_string_text += yytext;
    string_buffer += '\\';
}

<STRING>\\\"    { 

    current_string_text += yytext;
    string_buffer += '\"';
}

<STRING>\\a     { 

    current_string_text += yytext;
    string_buffer += '\a';
}

<STRING>\\b     { 

    current_string_text += yytext;
    string_buffer += '\b';
}

<STRING>\\f     { 

    current_string_text += yytext;
    string_buffer += '\f';
}

<STRING>\\r     { 

    current_string_text += yytext;
    string_buffer += '\r';
}

<STRING>\\v     { 

    current_string_text += yytext;
    string_buffer += '\v';
}

<STRING>\\0     { 

    current_string_text += yytext;
    string_buffer += '\0';
}

<STRING>\\[^ntrabfv0\\\"\n]  { 

    current_string_text += yytext;
    string_buffer += yytext[1];
}

<STRING>[^\\\"\n]+  { 

    current_string_text += yytext;
    string_buffer += yytext;
}

<STRING>\n      {

    error_count++;
    outputLogFile << "Error at line no " << line_count << ": Unterminated string " << current_string_text << endl << endl;
    line_count++;
    BEGIN(INITIAL);
}

<STRING><<EOF>> {

    error_count++;
    outputLogFile << "Error at line no " << line_count << ": Unterminated string " << current_string_text << endl << endl;
    BEGIN(INITIAL);
}

"//" {

    BEGIN(Single_line_comment);
    comment_text = "//"; 
}

<Single_line_comment>\\\n {
    line_count++;
    comment_text += yytext;
}

<Single_line_comment>\n {

    outputLogFile << "Line no " << line_count << ": Token <COMMENT> Lexeme " << comment_text << " found" << endl << endl;
    line_count++;
    BEGIN(INITIAL);
}

<Single_line_comment>. {
    comment_text += yytext;
}

"/*" {

    BEGIN(Multi_line_comment);
    initial_comment_line = line_count;
    star_comment_text = "/*";  
}

<Multi_line_comment>"*/" {
    star_comment_text += "*/";
    outputLogFile << "Line no " << initial_comment_line << ": Token <COMMENT> Lexeme " << star_comment_text << " found" << endl << endl;

    BEGIN(INITIAL);
}

<Multi_line_comment>\n {
    star_comment_text += yytext;
    line_count++;
}

<Multi_line_comment>. {
    star_comment_text += yytext;
}

<Multi_line_comment><<EOF>> {
    error_count++;
    outputLogFile << "Error at line no " << initial_comment_line << ": Unterminated comment " << star_comment_text << endl << endl;
    BEGIN(INITIAL);
}

. {
    error_count++;
    outputLogFile << "Error at line no " << line_count << ": Unrecognized character " << yytext << endl << endl;
}

%%

int main(int argc, char* argv[]) {

    string inputFileName = "input1.txt";
    
    if (argc > 1) {
        inputFileName = argv[1];
    }
    
    FILE *inputFile = fopen(inputFileName.c_str(), "r");
    if (!inputFile) {
        cout << "Error: Cannot open " << inputFileName << " file" << endl;
        return 1;
    }
    

    outputLogFile.open("output_log.txt");
    if (!outputLogFile.is_open()) {
        cout << "Error: Cannot open output_log.txt file" << endl;
        fclose(inputFile);
        return 1;
    }
    

    outputTokenFile.open("output_token.txt", ios::out | ios::trunc);
    if (!outputTokenFile.is_open()) {
        cout << "Error: Cannot open output_token.txt file" << endl;
        fclose(inputFile);
        outputLogFile.close();
        return 1;
    }
    
    symbolTable = new SymbolTable(7, 1, &outputLogFile);
    
    symbolTable->EnterScope();
    yyin = inputFile;
    

    yylex();
    
    symbolTable->PrintAllScopeTable();
    outputLogFile << endl;
    

    

    outputLogFile << "Total lines: " << line_count << endl;
    outputLogFile << "Total errors: " << error_count << endl;
    
    fclose(inputFile);
    outputLogFile.close();
    outputTokenFile.close();
    delete symbolTable;
    
    return 0;
}