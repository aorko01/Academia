parser grammar C8086Parser;

options {
	tokenVocab = C8086Lexer;
}

@parser::header {
    #include <iostream>
    #include <fstream>
    #include <string>
    #include <cstdlib>
    #include <map>
    #include "C8086Lexer.h"
    #include "SymbolTable.hpp"  

    extern std::ofstream parserLogFile;
    extern std::ofstream errorFile;
    extern int syntaxErrorCount;

    extern SymbolTable symbolTable;  
    extern std::map<std::string, std::string> functionSignatures;
}

@parser::members {
    std::map<std::string, std::string> functionSignatures;
    std::map<std::string, bool> functionDefined;
    std::string currentFunctionName = "";
    std::string currentFunctionReturnType = "";
    // Helper to check if a name is a variable in the global scope
    bool isGlobalVariable(const std::string& name) {
        SymbolInfo* info = symbolTable.Lookup(name);
        if (info) {
            std::string t = info->get_type();
            return t == "int" || t == "float" || t == "void" || t == "int_ARRAY" || t == "float_ARRAY";
        }
        return false;
    }
    void writeIntoparserLogFile(const std::string message) {
        if (!parserLogFile) {
            std::cout << "Error opening parserLogFile.txt" << std::endl;
            return;
        }
        parserLogFile << message << std::endl;
        parserLogFile.flush();
    }

    void writeIntoErrorFile(const std::string message) {
        if (!errorFile) {
            std::cout << "Error opening errorFile.txt" << std::endl;
            return;
        }
        errorFile << message << std::endl;
        errorFile.flush();
    }

    void logError(const int line, const std::string& message) {
        std::string errorMsg = "Error at line " + std::to_string(line) + ": " + message;
        writeIntoErrorFile(errorMsg + "\n");
        writeIntoparserLogFile(errorMsg + "\n");
        syntaxErrorCount++;
    }

    bool isIntegerExpression(const std::string& expr) {
        // Check if expression contains decimal point
        return expr.find('.') == std::string::npos;
    }

    std::string getVariableType(const std::string& varName) {
        SymbolInfo* info = symbolTable.Lookup(varName);
        if (info) {
            std::string type = info->get_type();
            // Remove _ARRAY suffix if present
            if (type.length() > 6 && type.substr(type.length()-6) == "_ARRAY") {
                return type.substr(0, type.length()-6);
            }
            return type;
        }
        return "";
    }

    bool isArrayVariable(const std::string& varName) {
        SymbolInfo* info = symbolTable.Lookup(varName);
        if (info) {
            std::string type = info->get_type();
            return type.length() > 6 && type.substr(type.length()-6) == "_ARRAY";
        }
        return false;
    }

    // --- New member functions ---
    std::string extractFunctionName(const std::string& code) {
        size_t parenPos = code.find('(');
        if (parenPos == std::string::npos) return "";
        size_t spacePos = code.rfind(' ', parenPos);
        if (spacePos == std::string::npos) return "";
        return code.substr(spacePos + 1, parenPos - spacePos - 1);
    }
    bool isVoidFunction(const std::string& funcName) {
        SymbolInfo* info = symbolTable.Lookup(funcName);
        if (info) {
            return info->get_type() == "void";
        }
        return false;
    }
    bool containsVoidFunctionCall(const std::string& expr) {
        size_t pos = 0;
        while ((pos = expr.find('(', pos)) != std::string::npos) {
            size_t start = pos;
            while (start > 0 && (std::isalnum(expr[start-1]) || expr[start-1] == '_')) {
                start--;
            }
            std::string funcName = expr.substr(start, pos - start);
            if (!funcName.empty() && isVoidFunction(funcName)) {
                return true;
            }
            pos++;
        }
        return false;
    }
    bool isZeroDivision(const std::string& expr) {
        return expr == "0";
    }

    // Helper to split parameter list string into vector of types
    std::vector<std::string> splitParameterTypes(const std::string& paramList) {
        std::vector<std::string> types;
        size_t start = 0, end = 0;
        while ((end = paramList.find(',', start)) != std::string::npos) {
            std::string param = paramList.substr(start, end - start);
            size_t space = param.find(' ');
            if (space != std::string::npos)
                types.push_back(param.substr(0, space));
            else if (!param.empty())
                types.push_back(param);
            start = end + 1;
        }
        std::string last = paramList.substr(start);
        size_t space = last.find(' ');
        if (space != std::string::npos)
            types.push_back(last.substr(0, space));
        else if (!last.empty())
            types.push_back(last);
        return types;
    }
    // Helper to split argument list string into vector of argument names/values
    std::vector<std::string> splitArgumentList(const std::string& argList) {
        std::vector<std::string> args;
        size_t start = 0, end = 0;
        int paren = 0, bracket = 0;
        for (size_t i = 0; i <= argList.size(); ++i) {
            if (i == argList.size() || (argList[i] == ',' && paren == 0 && bracket == 0)) {
                std::string arg = argList.substr(start, i - start);
                if (!arg.empty()) args.push_back(arg);
                start = i + 1;
            } else if (argList[i] == '(') paren++;
            else if (argList[i] == ')') paren--;
            else if (argList[i] == '[') bracket++;
            else if (argList[i] == ']') bracket--;
        }
        return args;
    }
    // Helper to get argument type (int, float, int_ARRAY, etc.)
    std::string getArgumentType(const std::string& arg) {
        SymbolInfo* info = symbolTable.Lookup(arg);
        if (info) return info->get_type();
        // If not a variable, try to infer from literal
        if (arg.find('.') != std::string::npos) return "float";
        if (arg.find('[') != std::string::npos) {
            size_t nameEnd = arg.find('[');
            std::string arrName = arg.substr(0, nameEnd);
            SymbolInfo* arrInfo = symbolTable.Lookup(arrName);
            if (arrInfo && isArrayVariable(arrName)) return arrInfo->get_type();
            return "int_ARRAY";
        }
        return "int";
    }
}

start:
	{
        // Enter global scope at the beginning of parsing
        symbolTable.EnterScope();
    } program {
        writeIntoparserLogFile("Line " + std::to_string($program.start->getLine()) + ": start : program");
        writeIntoparserLogFile("");
        
        // Print all scope tables at the end
        std::streambuf* originalCoutBuffer = std::cout.rdbuf();
        std::cout.rdbuf(parserLogFile.rdbuf());
        symbolTable.PrintAllScopeTable();
        std::cout.rdbuf(originalCoutBuffer);
        
        writeIntoparserLogFile("Total number of lines: " + std::to_string($program.start->getLine()));
        writeIntoparserLogFile("Total number of errors: " + std::to_string(syntaxErrorCount));
        
        // Exit global scope at the end of parsing
        symbolTable.ExitScope();
	};

program
	returns[std::string code]:
	p = program u = unit {
        $code = $p.code + "\n" + $u.code;
        writeIntoparserLogFile("Line " + std::to_string($u.start->getLine()) + ": program : program unit");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    }
	| u = unit {
        $code = $u.code;
        writeIntoparserLogFile("Line " + std::to_string($u.start->getLine()) + ": program : unit");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    };

unit
	returns[std::string code, int line]:
	vd = var_declaration {
        $code = $vd.code;
        $line = $vd.line;
        writeIntoparserLogFile("Line " + std::to_string($line) + ": unit : var_declaration");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    }
	| fd = func_declaration {
        $code = $fd.code;
        $line = $fd.line;
        writeIntoparserLogFile("Line " + std::to_string($line) + ": unit : func_declaration");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    }
	| fdef = func_definition {
        $code = $fdef.code; 
        $line = $fdef.line;
        writeIntoparserLogFile("Line " + std::to_string($line) + ": unit : func_definition");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    };

func_declaration
	returns[std::string code, int line]:
	t = type_specifier id = ID LPAREN { symbolTable.EnterScope(); } pl = parameter_list { symbolTable.ExitScope(); 
		} RPAREN sm = SEMICOLON {
        $line = $sm->getLine();
        $code = $t.text + " " + $id->getText() + "(" + $pl.text + ");";
        // Check for multiple declaration as variable in global scope
        if (isGlobalVariable($id->getText())) {
            logError($line, "Multiple declaration of " + $id->getText());
        }
        // Store function signature for later comparison
        std::string signature = $t.text + ":" + $pl.text;
        if (functionSignatures.count($id->getText()) == 0) {
            functionSignatures[$id->getText()] = signature;
            functionDefined[$id->getText()] = false;
        } else {
            // If already declared, check signature
            if (functionSignatures[$id->getText()] != signature) {
                logError($line, "Function signature mismatch of " + $id->getText());
            }
        }
        if (!symbolTable.Insert($id->getText(), $t.text)) {
            std::string existingType = symbolTable.GetType($id->getText());
            if (existingType != $t.text) {
                logError($line, "Return type mismatch of " + $id->getText());
            }
        }
        writeIntoparserLogFile("Line " + std::to_string($line) + ": func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    }
	| t = type_specifier id = ID LPAREN { symbolTable.EnterScope(); } RPAREN { symbolTable.ExitScope(); 
		} sm = SEMICOLON {
        $line = $sm->getLine();
        $code = $t.text + " " + $id->getText() + "();";
        if (isGlobalVariable($id->getText())) {
            logError($line, "Multiple declaration of " + $id->getText());
        }
        std::string signature = $t.text + ":";
        if (functionSignatures.count($id->getText()) == 0) {
            functionSignatures[$id->getText()] = signature;
            functionDefined[$id->getText()] = false;
        } else {
            if (functionSignatures[$id->getText()] != signature) {
                logError($line, "Function signature mismatch of " + $id->getText());
            }
        }
        if (!symbolTable.Insert($id->getText(), $t.text)) {
            std::string existingType = symbolTable.GetType($id->getText());
            if (existingType != $t.text) {
                logError($line, "Return type mismatch of " + $id->getText());
            }
        }
        writeIntoparserLogFile("Line " + std::to_string($line) + ": func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    };

func_definition
	returns[std::string code, int line]:
	t = type_specifier id = ID {
        // Check for multiple declaration as variable in global scope
        if (isGlobalVariable($id->getText())) {
            logError($id->getLine(), "Multiple declaration of " + $id->getText());
        }
        currentFunctionName = $id->getText();
        currentFunctionReturnType = $t.text;
        // Prepare signature for later check
    } LPAREN { symbolTable.EnterScope(); } pl = parameter_list RPAREN cs = compound_statement {
        $line = $cs.line;
        $code = $t.text + " " + $id->getText() + "(" + $pl.code + ")" + $cs.code;
        std::string defSignature = $t.text + ":" + $pl.code;
        if (functionDefined[$id->getText()]) {
            logError($id->getLine(), "Multiple definition of " + $id->getText());
        } else if (functionSignatures.count($id->getText()) && functionSignatures[$id->getText()] != defSignature) {
            logError($id->getLine(), "Function signature mismatch of " + $id->getText());
        } else {
            functionSignatures[$id->getText()] = defSignature;
            functionDefined[$id->getText()] = true;
        }
        if (!symbolTable.Insert($id->getText(), $t.text)) {
            std::string existingType = symbolTable.GetType($id->getText());
            if (existingType != $t.text) {
                logError($id->getLine(), "Return type mismatch of " + $id->getText());
            }
        }
        currentFunctionName = "";
        currentFunctionReturnType = "";
        writeIntoparserLogFile("Line " + std::to_string($line) + ": func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    }
	| t = type_specifier id = ID {
        if (isGlobalVariable($id->getText())) {
            logError($id->getLine(), "Multiple declaration of " + $id->getText());
        }
        currentFunctionName = $id->getText();
        currentFunctionReturnType = $t.text;
    } LPAREN { symbolTable.EnterScope(); } RPAREN cs = compound_statement {
        $line = $cs.line;
        $code = $t.text + " " + $id->getText() + "()" + $cs.code;
        std::string defSignature = $t.text + ":";
        if (functionDefined[$id->getText()]) {
            logError($id->getLine(), "Multiple definition of " + $id->getText());
        } else if (functionSignatures.count($id->getText()) && functionSignatures[$id->getText()] != defSignature) {
            logError($id->getLine(), "Function signature mismatch of " + $id->getText());
        } else {
            functionSignatures[$id->getText()] = defSignature;
            functionDefined[$id->getText()] = true;
        }
        if (!symbolTable.Insert($id->getText(), $t.text)) {
            std::string existingType = symbolTable.GetType($id->getText());
            if (existingType != $t.text) {
                logError($id->getLine(), "Return type mismatch of " + $id->getText());
            }
        }
        currentFunctionName = "";
        currentFunctionReturnType = "";
        writeIntoparserLogFile("Line " + std::to_string($line) + ": func_definition : type_specifier ID LPAREN RPAREN compound_statement");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    };

parameter_list
	returns[std::string code]:
	pl = parameter_list COMMA t = type_specifier id = ID {
        $code = $pl.code + "," + $t.text + " " + $id->getText();
        // Insert parameter into symbol table - Insert returns false if already exists
        if (!symbolTable.Insert($id->getText(), $t.text)) {
            logError($id->getLine(), "Multiple declaration of " + $id->getText());
        }
        writeIntoparserLogFile("Line " + std::to_string($id->getLine()) + ": parameter_list : parameter_list COMMA type_specifier ID");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    }
	| pl = parameter_list COMMA t = type_specifier {
        $code = $pl.code + "," + $t.text;
        writeIntoparserLogFile("Line " + std::to_string($t.line) + ": parameter_list : parameter_list COMMA type_specifier");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    }
	| t = type_specifier id = ID {
        $code = $t.text + " " + $id->getText();
        // Insert parameter into symbol table - Insert returns false if already exists
        if (!symbolTable.Insert($id->getText(), $t.text)) {
            logError($id->getLine(), "Multiple declaration of " + $id->getText());
        }
        writeIntoparserLogFile("Line " + std::to_string($id->getLine()) + ": parameter_list : type_specifier ID");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    }
	| t = type_specifier {
        $code = $t.text;
        writeIntoparserLogFile("Line " + std::to_string($t.line) + ": parameter_list : type_specifier");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    };

compound_statement
	returns[std::string code, int line]:
	LCURL {
        // Enter new scope for compound statement (not for function definitions)
        symbolTable.EnterScope();
    } ss = statements rc = RCURL {
        $line = $rc->getLine();
        $code = "{\n" + $ss.code + "\n}";
        writeIntoparserLogFile("Line " + std::to_string($line) + ": compound_statement : LCURL statements RCURL");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
        std::streambuf* originalCoutBuffer = std::cout.rdbuf();
        std::cout.rdbuf(parserLogFile.rdbuf());
        symbolTable.PrintAllScopeTable();  
        std::cout.rdbuf(originalCoutBuffer);
        symbolTable.ExitScope();
    }
	| LCURL {
        // Enter new scope for compound statement
        symbolTable.EnterScope();
    } rc = RCURL {
        $line = $rc->getLine();
        $code = "{}";
        writeIntoparserLogFile("Line " + std::to_string($line) + ": compound_statement : LCURL RCURL");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
        // Exit compound statement scope
        std::streambuf* originalCoutBuffer = std::cout.rdbuf();
        std::cout.rdbuf(parserLogFile.rdbuf());
        symbolTable.PrintAllScopeTable();  
        std::cout.rdbuf(originalCoutBuffer);
        symbolTable.ExitScope();
    };

var_declaration
	returns[std::string code, int line]:
	t = type_specifier dl = declaration_list sm = SEMICOLON {
        $line = $sm->getLine();
        $code = $t.text + " " + $dl.names + ";";
        // Check for void variable type
        if ($t.text == "void") {
            logError($line, "Variable type cannot be void");
        }
        // Insert variables into symbol table with duplicate checking
        std::string varNames = $dl.names;
        std::string delimiter = ",";
        size_t pos = 0;
        std::string token;
        while ((pos = varNames.find(delimiter)) != std::string::npos) {
            token = varNames.substr(0, pos);
            size_t bracketPos = token.find('[');
            bool isArray = (bracketPos != std::string::npos);
            if (isArray) {
                token = token.substr(0, bracketPos);
            }
            std::string typeInfo = $t.text;
            if (isArray) typeInfo += "_ARRAY";
            if (!symbolTable.Insert(token, typeInfo)) {
                logError($line, "Multiple declaration of " + token);
            }
            varNames.erase(0, pos + delimiter.length());
        }
        // Handle the last variable
        size_t bracketPos = varNames.find('[');
        bool isArray = (bracketPos != std::string::npos);
        if (isArray) {
            varNames = varNames.substr(0, bracketPos);
        }
        std::string typeInfo = $t.text;
        if (isArray) typeInfo += "_ARRAY";
        if (!symbolTable.Insert(varNames, typeInfo)) {
            logError($line, "Multiple declaration of " + varNames);
        }
        writeIntoparserLogFile("Line " + std::to_string($line) + ": var_declaration : type_specifier declaration_list SEMICOLON");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    }
	| t = type_specifier de = declaration_list_err sm = SEMICOLON {
        writeIntoErrorFile(
            std::string("Line# ") + std::to_string($sm->getLine()) +
            " with error name: " + $de.error_name +
            " - Syntax error at declaration list of variable declaration"
        );
        syntaxErrorCount++;
    };

declaration_list_err
	returns[std::string error_name]:
	{
        $error_name = "Error in declaration list";
    };

type_specifier
	returns[std::string name_line, std::string typeKeyword, std::string text, int line]:
	INT {
        $line = $INT->getLine();
        $name_line = "type: INT at line" + std::to_string($line);
        $typeKeyword = $INT->getText();
        $text = $INT->getText();
        writeIntoparserLogFile("Line " + std::to_string($line) + ": type_specifier : INT");
        writeIntoparserLogFile(""); 
        writeIntoparserLogFile($text);
        writeIntoparserLogFile(""); 
    }
	| FLOAT {
        $line = $FLOAT->getLine();
        $name_line = "type: FLOAT at line" + std::to_string($line);
        $typeKeyword = $FLOAT->getText();
        $text = $FLOAT->getText();
        writeIntoparserLogFile("Line " + std::to_string($line) + ": type_specifier : FLOAT");
        writeIntoparserLogFile(""); 
        writeIntoparserLogFile($text);
        writeIntoparserLogFile(""); 
    }
	| VOID {
        $line = $VOID->getLine();
        $name_line = "type: VOID at line" + std::to_string($line);
        $typeKeyword = $VOID->getText();
        $text = $VOID->getText();
        writeIntoparserLogFile("Line " + std::to_string($line) + ": type_specifier : VOID");
        writeIntoparserLogFile(""); 
        writeIntoparserLogFile($text);
        writeIntoparserLogFile(""); 
    };

declaration_list
	returns[std::string names]:
	id1 = ID {
        $names = $id1->getText();
        writeIntoparserLogFile("Line " + std::to_string($id1->getLine()) + ": declaration_list : ID");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($names);
        writeIntoparserLogFile(""); 
    }
	| d = declaration_list COMMA id2 = ID {
        $names = $d.names + "," + $id2->getText();
        writeIntoparserLogFile("Line " + std::to_string($id2->getLine()) + ": declaration_list : declaration_list COMMA ID");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($names);
        writeIntoparserLogFile(""); 
    }
	| id = ID LTHIRD ci = CONST_INT RTHIRD {
        $names = $id->getText() + "[" + $ci->getText() + "]";
        writeIntoparserLogFile("Line " + std::to_string($id->getLine()) + ": declaration_list : ID LTHIRD CONST_INT RTHIRD");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($names);
        writeIntoparserLogFile("");
    }
	| dl = declaration_list COMMA id = ID LTHIRD ci = CONST_INT RTHIRD {
        $names = $dl.names + "," + $id->getText() + "[" + $ci->getText() + "]";
        writeIntoparserLogFile("Line " + std::to_string($id->getLine()) + ": declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($names);
        writeIntoparserLogFile("");
    };

statements
	returns[std::string code]:
	s = statement {
        $code = $s.code;
        writeIntoparserLogFile("Line " + std::to_string($s.line) + ": statements : statement");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    }
	| ss = statements s = statement {
        $code = $ss.code + "\n" + $s.code;
        writeIntoparserLogFile("Line " + std::to_string($s.line) + ": statements : statements statement");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    };

statement
	returns[std::string code, int line]:
	vd = var_declaration {
        $code = $vd.code;
        $line = $vd.line;
        writeIntoparserLogFile("Line " + std::to_string($line) + ": statement : var_declaration");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    }
	| es = expression_statement {
        $code = $es.code;
        $line = $es.line;
        writeIntoparserLogFile("Line " + std::to_string($line) + ": statement : expression_statement");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    }
	| cs = compound_statement {
        $code = $cs.code;
        $line = $cs.line;
        writeIntoparserLogFile("Line " + std::to_string($line) + ": statement : compound_statement");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    }
	| FOR LPAREN es1 = expression_statement es2 = expression_statement e = expression RPAREN s =
		statement {
        $line = $FOR->getLine();
        $code = "for(" + $es1.code + $es2.code + $e.code + ")" + $s.code;
        writeIntoparserLogFile("Line " + std::to_string($line) + ": statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    }
	| IF LPAREN e = expression RPAREN s = statement {
        $line = $IF->getLine();
        $code = "if(" + $e.code + ")" + $s.code;
        writeIntoparserLogFile("Line " + std::to_string($line) + ": statement : IF LPAREN expression RPAREN statement");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    }
	| IF LPAREN e = expression RPAREN s1 = statement ELSE s2 = statement {
        $line = $IF->getLine();
        $code = "if(" + $e.code + ")" + $s1.code + "else" + $s2.code;
        writeIntoparserLogFile("Line " + std::to_string($line) + ": statement : IF LPAREN expression RPAREN statement ELSE statement");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    }
	| WHILE LPAREN e = expression RPAREN s = statement {
        $line = $WHILE->getLine();
        $code = "while(" + $e.code + ")" + $s.code;
        writeIntoparserLogFile("Line " + std::to_string($line) + ": statement : WHILE LPAREN expression RPAREN statement");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    }
	| PRINTLN LPAREN id = ID RPAREN sm = SEMICOLON {
        $line = $sm->getLine();
        $code = "println(" + $id->getText() + ");";
        writeIntoparserLogFile("Line " + std::to_string($line) + ": statement : PRINTLN LPAREN ID RPAREN SEMICOLON");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    }
	| RETURN e = expression sm = SEMICOLON {
        $line = $sm->getLine();
        $code = "return " + $e.code + ";";
        // Check for void function used in expression
        if (containsVoidFunctionCall($e.code)) {
            logError($line, "Void function used in expression");
        }
        // Check for return value in void function
        if (currentFunctionReturnType == "void") {
            logError($line, "Cannot return value from function " + currentFunctionName + " with void return type");
        }
        writeIntoparserLogFile("Line " + std::to_string($line) + ": statement : RETURN expression SEMICOLON");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    };

expression_statement
	returns[std::string code, int line]:
	sm = SEMICOLON {
        $line = $sm->getLine();
        $code = ";";
        writeIntoparserLogFile("Line " + std::to_string($line) + ": expression_statement : SEMICOLON");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    }
	| e = expression sm = SEMICOLON {
        $line = $sm->getLine();
        $code = $e.code + ";";
        writeIntoparserLogFile("Line " + std::to_string($line) + ": expression_statement : expression SEMICOLON");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    };

variable
	returns[std::string code, int line]:
	id = ID {
        $line = $id->getLine();
        $code = $id->getText();
        if (symbolTable.Lookup($id->getText()) == NULL) {
            logError($line, "Undeclared variable " + $id->getText());
        }
        writeIntoparserLogFile("Line " + std::to_string($line) + ": variable : ID");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    }
	| id = ID LTHIRD e = expression RTHIRD {
        $line = $id->getLine();
        $code = $id->getText() + "[" + $e.code + "]";
        if (symbolTable.Lookup($id->getText()) == NULL) {
            logError($line, "Undeclared variable " + $id->getText());
        } else {
            // Check if variable is actually an array
            if (!isArrayVariable($id->getText())) {
                logError($line, $id->getText() + " not an array");
            }
            // Check if array index is integer
            if (!isIntegerExpression($e.code)) {
                logError($line, "Expression inside third brackets not an integer");
            }
        }
        writeIntoparserLogFile("Line " + std::to_string($line) + ": variable : ID LTHIRD expression RTHIRD");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    };

expression
	returns[std::string code, int line]:
	le = logic_expression {
        $code = $le.code; 
        $line = $le.line;
        // Check for void function used in expression
        if (containsVoidFunctionCall($le.code)) {
            logError($line, "Void function used in expression");
        }
        writeIntoparserLogFile("Line " + std::to_string($line) + ": expression : logic_expression");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    }
	| v = variable ASSIGNOP le = logic_expression {
        $line = $v.line;
        $code = $v.code + "=" + $le.code;
        // Check for void function used in expression
        if (containsVoidFunctionCall($le.code)) {
            logError($line, "Void function used in expression");
        }
        std::string varName = $v.code;
        size_t bracketPos = varName.find('[');
        if (bracketPos != std::string::npos) {
            varName = varName.substr(0, bracketPos);
        }
        SymbolInfo* varInfo = symbolTable.Lookup(varName);
        if (varInfo != NULL) {
            std::string varType = getVariableType(varName);
            bool isArray = isArrayVariable(varName);
            if (isArray && bracketPos == std::string::npos) {
                logError($line, "Type mismatch, " + varName + " is an array");
            }
            else if (varType == "int" && $le.code.find('.') != std::string::npos) {
                logError($line, "Type Mismatch");
            }
        }
        writeIntoparserLogFile("Line " + std::to_string($line) + ": expression : variable ASSIGNOP logic_expression");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    };

logic_expression
	returns[std::string code, int line]:
	re = rel_expression {
        $code = $re.code;
        $line = $re.line;
        writeIntoparserLogFile("Line " + std::to_string($line) + ": logic_expression : rel_expression");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    }
	| re1 = rel_expression op = LOGICOP re2 = rel_expression {
        $line = $re1.line;
        $code = $re1.code + $op->getText() + $re2.code;
        writeIntoparserLogFile("Line " + std::to_string($line) + ": logic_expression : rel_expression LOGICOP rel_expression");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    };

rel_expression
	returns[std::string code, int line]:
	se = simple_expression {
        $code = $se.code;
        $line = $se.line;
        writeIntoparserLogFile("Line " + std::to_string($line) + ": rel_expression : simple_expression");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    }
	| se1 = simple_expression op = RELOP se2 = simple_expression {
        $line = $se1.line;
        $code = $se1.code + $op->getText() + $se2.code;
        writeIntoparserLogFile("Line " + std::to_string($line) + ": rel_expression : simple_expression RELOP simple_expression");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    };

simple_expression
	returns[std::string code, int line]:
	t = term {
        $code = $t.code;
        $line = $t.line;
        writeIntoparserLogFile("Line " + std::to_string($line) + ": simple_expression : term");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    }
	| se = simple_expression op = ADDOP t = term {
        $line = $se.line;
        $code = $se.code + $op->getText() + $t.code;
        writeIntoparserLogFile("Line " + std::to_string($line) + ": simple_expression : simple_expression ADDOP term");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    };

term
	returns[std::string code, int line]:
	ue = unary_expression {
        $code = $ue.code;
        $line = $ue.line;
        writeIntoparserLogFile("Line " + std::to_string($line) + ": term : unary_expression");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    }
	| t = term op = MULOP ue = unary_expression {
        $line = $t.line;
        $code = $t.code + $op->getText() + $ue.code;
        if ($op->getText() == "%") {
            // Check for modulus by zero
            if (isZeroDivision($ue.code)) {
                logError($line, "Modulus by Zero");
            }
            // Check for non-integer operands
            else if (!isIntegerExpression($t.code) || !isIntegerExpression($ue.code)) {
                logError($line, "Non-Integer operand on modulus operator");
            }
        }
        writeIntoparserLogFile("Line " + std::to_string($line) + ": term : term MULOP unary_expression");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    };

unary_expression
	returns[std::string code, int line]:
	op = ADDOP ue = unary_expression {
        $line = $op->getLine();
        $code = $op->getText() + $ue.code;
        writeIntoparserLogFile("Line " + std::to_string($line) + ": unary_expression : ADDOP unary_expression");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    }
	| NOT ue = unary_expression {
        $line = $NOT->getLine();
        $code = "!" + $ue.code;
        writeIntoparserLogFile("Line " + std::to_string($line) + ": unary_expression : NOT unary_expression");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    }
	| f = factor {
        $code = $f.code;
        $line = $f.line;
        writeIntoparserLogFile("Line " + std::to_string($line) + ": unary_expression : factor");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    };

factor
	returns[std::string code, int line]:
	v = variable {
        $code = $v.code;
        $line = $v.line;
        writeIntoparserLogFile("Line " + std::to_string($line) + ": factor : variable");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    }
	| id = ID LPAREN al = argument_list RPAREN {
        $line = $id->getLine();
        $code = $id->getText() + "(" + $al.code + ")";
        // Check if function is declared
        if (symbolTable.Lookup($id->getText()) == NULL) {
            logError($line, "Undefined function " + $id->getText());
        }
        // Argument checking
        std::string funcName = $id->getText();
        std::string signature = functionSignatures.count(funcName) ? functionSignatures[funcName] : "";
        std::string paramList = "";
        size_t colon = signature.find(':');
        if (colon != std::string::npos) paramList = signature.substr(colon+1);
        std::vector<std::string> paramTypes = splitParameterTypes(paramList);
        std::vector<std::string> argList = splitArgumentList($al.code);
        if (paramTypes.size() != argList.size()) {
            logError($line, "Total number of arguments mismatch with declaration in function " + funcName);
        } else {
            for (size_t i = 0; i < paramTypes.size(); ++i) {
                std::string argType = getArgumentType(argList[i]);
                std::string paramType = paramTypes[i];
                // If argument is an array but parameter is not
                if (isArrayVariable(argList[i]) && paramType != "int_ARRAY" && paramType != "float_ARRAY") {
                    logError($line, "Type mismatch, " + argList[i] + " is an array");
                }
                // If type does not match
                else if (paramType == "int" && argType != "int") {
                    logError($line, std::to_string(i+1) + "th argument mismatch in function " + funcName);
                } else if (paramType == "float" && argType != "float") {
                    logError($line, std::to_string(i+1) + "th argument mismatch in function " + funcName);
                } else if ((paramType == "int_ARRAY" || paramType == "float_ARRAY") && argType != paramType) {
                    logError($line, std::to_string(i+1) + "th argument mismatch in function " + funcName);
                }
            }
        }
        writeIntoparserLogFile("Line " + std::to_string($line) + ": factor : ID LPAREN argument_list RPAREN");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    }
	| LPAREN e = expression RPAREN {
        $line = $LPAREN->getLine();
        $code = "(" + $e.code + ")";
        writeIntoparserLogFile("Line " + std::to_string($line) + ": factor : LPAREN expression RPAREN");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    }
	| ci = CONST_INT {
        $line = $ci->getLine();
        $code = $ci->getText();
        writeIntoparserLogFile("Line " + std::to_string($line) + ": factor : CONST_INT");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    }
	| cf = CONST_FLOAT {
        $line = $cf->getLine();
        $code = $cf->getText();
        writeIntoparserLogFile("Line " + std::to_string($line) + ": factor : CONST_FLOAT");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    }
	| v = variable INCOP {
        $line = $v.line;
        $code = $v.code + "++";
        writeIntoparserLogFile("Line " + std::to_string($line) + ": factor : variable INCOP");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    }
	| v = variable DECOP {
        $line = $v.line;
        $code = $v.code + "--";
        writeIntoparserLogFile("Line " + std::to_string($line) + ": factor : variable DECOP");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    };

argument_list
	returns[std::string code]:
	a = arguments {
        $code = $a.code;
        writeIntoparserLogFile("Line " + std::to_string($a.line) + ": argument_list : arguments");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    }
	| {
        $code = "";
        // No logging for empty argument list
    };

arguments
	returns[std::string code, int line]:
	a = arguments COMMA le = logic_expression {
        $line = $a.line;
        $code = $a.code + "," + $le.code;
        writeIntoparserLogFile("Line " + std::to_string($line) + ": arguments : arguments COMMA logic_expression");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    }
	| le = logic_expression {
        $line = $le.line;
        $code = $le.code;
        writeIntoparserLogFile("Line " + std::to_string($line) + ": arguments : logic_expression");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    };