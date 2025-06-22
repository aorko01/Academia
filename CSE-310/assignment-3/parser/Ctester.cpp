#include <iostream>
#include <fstream>
#include <string>
#include "antlr4-runtime.h"
#include "C8086Lexer.h"
#include "C8086Parser.h"
#include "SymbolTable.hpp" // <-- 🔹 Include your Symbol Table

using namespace antlr4;
using namespace std;

// ---- Global output streams ----
ofstream parserLogFile;
ofstream errorFile;
ofstream lexLogFile;

// ---- Global variables ----
int syntaxErrorCount = 0;

// 🔹 Global SymbolTable instance (default bucket size = 11)
SymbolTable symbolTable(7); // You can change bucket size/hash function if needed

int main(int argc, const char* argv[]) {
    if (argc < 2) {
        cerr << "Usage: " << argv[0] << " <input_file>" << endl;
        return 1;
    }

    ifstream inputFile(argv[1]);
    if (!inputFile.is_open()) {
        cerr << "Error opening input file: " << argv[1] << endl;
        return 1;
    }

    string outputDirectory = "output/";
    string parserLogFileName = outputDirectory + "parserLog.txt";
    string errorFileName = outputDirectory + "errorLog.txt";
    string lexLogFileName = outputDirectory + "lexerLog.txt";

    system(("mkdir -p " + outputDirectory).c_str());

    parserLogFile.open(parserLogFileName);
    errorFile.open(errorFileName);
    lexLogFile.open(lexLogFileName);

    if (!parserLogFile || !errorFile || !lexLogFile) {
        cerr << "Error opening one or more output files." << endl;
        return 1;
    }

    // ---- ANTLR Parsing Flow ----
    ANTLRInputStream input(inputFile);
    C8086Lexer lexer(&input);
    CommonTokenStream tokens(&lexer);
    C8086Parser parser(&tokens);

    parser.removeErrorListeners();

    parser.start();  // Start parsing

    // ---- Cleanup ----
    inputFile.close();
    parserLogFile.close();
    errorFile.close();
    lexLogFile.close();

    cout << "Parsing completed. Check the output files for details." << endl;
    return 0;
}
