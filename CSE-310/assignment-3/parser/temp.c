// 1. ADD THIS HELPER FUNCTION in @parser::members section (after writeIntoErrorFile function):

    void logError(const int line, const std::string& message) {
        std::string errorMsg = "Error at line " + std::to_string(line) + ": " + message;
        writeIntoErrorFile(errorMsg);
        writeIntoparserLogFile(errorMsg);
        syntaxErrorCount++;
    }

    bool isIntegerExpression(const std::string& expr) {
        // Check if expression contains decimal point
        return expr.find('.') == std::string::npos;
    }

    std::string getVariableType(const std::string& varName) {
        SymbolInfo* info = symbolTable.Lookup(varName);
        if (info) {
            std::string type = info->getType();
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
            std::string type = info->getType();
            return type.length() > 6 && type.substr(type.length()-6) == "_ARRAY";
        }
        return false;
    }

// 2. MODIFY var_declaration rule - REPLACE the duplicate checking section with:

var_declaration
    returns[std::string code, int line]:
    t = type_specifier dl = declaration_list sm = SEMICOLON {
        $line = $sm->getLine();
        $code = $t.text + " " + $dl.names + ";";
        
        // Insert variables into symbol table with duplicate checking
        std::string varNames = $dl.names;
        std::string delimiter = ",";
        size_t pos = 0;
        std::string token;
        
        // Parse comma-separated variable names
        while ((pos = varNames.find(delimiter)) != std::string::npos) {
            token = varNames.substr(0, pos);
            // Remove array brackets for symbol table insertion
            size_t bracketPos = token.find('[');
            bool isArray = (bracketPos != std::string::npos);
            if (isArray) {
                token = token.substr(0, bracketPos);
            }
            
            // Check for duplicate declaration in current scope
            if (symbolTable.Lookup(token)) {
                logError($line, "Multiple declaration of " + token);
            } else {
                // For now, store array info in the type string
                string typeInfo = $t.text;
                if (isArray) typeInfo += "_ARRAY";
                symbolTable.Insert(token, typeInfo);
            }
            symbolTable.PrintCurrentScopeTable();
            varNames.erase(0, pos + delimiter.length());
        }
        // Handle the last variable
        size_t bracketPos = varNames.find('[');
        bool isArray = (bracketPos != std::string::npos);
        if (isArray) {
            varNames = varNames.substr(0, bracketPos);
        }
        
        // Check for duplicate declaration in current scope
        if (symbolTable.Lookup(varNames)) {
            logError($line, "Multiple declaration of " + varNames);
        } else {
            // For now, store array info in the type string
            string typeInfo = $t.text;
            if (isArray) typeInfo += "_ARRAY";
            symbolTable.Insert(varNames, typeInfo);
        }
        symbolTable.PrintCurrentScopeTable();
        
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

// 3. MODIFY variable rule - ADD semantic checking:

variable
    returns[std::string code, int line]:
    id = ID {
        $line = $id->getLine();
        $code = $id->getText();
        
        // Check if variable is declared
        if (!symbolTable.Lookup($id->getText())) {
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
        
        // Check if variable is declared
        if (!symbolTable.Lookup($id->getText())) {
            logError($line, "Undeclared variable " + $id->getText());
        } else {
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

// 4. MODIFY expression rule - ADD assignment checking:

expression
    returns[std::string code, int line]:
    le = logic_expression {
        $code = $le.code; 
        $line = $le.line;
        writeIntoparserLogFile("Line " + std::to_string($line) + ": expression : logic_expression");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    }
    | v = variable ASSIGNOP le = logic_expression {
        $line = $v.line;
        $code = $v.code + "=" + $le.code;
        
        // Extract variable name from variable code
        std::string varName = $v.code;
        size_t bracketPos = varName.find('[');
        if (bracketPos != std::string::npos) {
            varName = varName.substr(0, bracketPos);
        }
        
        // Check type compatibility
        if (symbolTable.Lookup(varName)) {
            std::string varType = getVariableType(varName);
            bool isArray = isArrayVariable(varName);
            
            // Check if trying to assign to whole array
            if (isArray && bracketPos == std::string::npos) {
                logError($line, "Type mismatch, " + varName + " is an array");
            }
            // Check type compatibility for assignment
            else if (varType == "int" && $le.code.find('.') != std::string::npos) {
                logError($line, "Type Mismatch");
            }
        }
        
        writeIntoparserLogFile("Line " + std::to_string($line) + ": expression : variable ASSIGNOP logic_expression");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    };

// 5. MODIFY term rule - ADD modulus operator checking:

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
        
        // Check for modulus operator with non-integer operands
        if ($op->getText() == "%") {
            if (!isIntegerExpression($t.code) || !isIntegerExpression($ue.code)) {
                logError($line, "Non-Integer operand on modulus operator");
            }
        }
        
        writeIntoparserLogFile("Line " + std::to_string($line) + ": term : term MULOP unary_expression");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    };

// 6. MODIFY factor rule - ADD function call checking:

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
        
        // Check function call with array argument
        std::string args = $al.code;
        if (!args.empty()) {
            // Simple check - if argument is just a variable name, check if it's an array
            if (args.find('(') == std::string::npos && args.find('[') == std::string::npos) {
                if (symbolTable.Lookup(args) && isArrayVariable(args)) {
                    logError($line, "Type mismatch, " + args + " is an array");
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

// 7. NO NEED TO MODIFY SymbolTable.hpp - we use existing methods
// We store array information by appending "_ARRAY" to the type string
// This way we can use existing Insert(name, type) and Lookup(name) methods