var_declaration
	returns[std::string code, int line]:
	t = type_specifier dl = declaration_list sm = SEMICOLON {
        $line = $sm->getLine();
        $code = $t.text + " " + $dl.names + ";";
        
        // Insert variables into symbol table
        std::string varNames = $dl.names;
        std::string delimiter = ",";
        size_t pos = 0;
        std::string token;
        
        // Parse comma-separated variable names
        while ((pos = varNames.find(delimiter)) != std::string::npos) {
            token = varNames.substr(0, pos);
            // Remove array brackets for symbol table insertion
            size_t bracketPos = token.find('[');
            if (bracketPos != std::string::npos) {
                token = token.substr(0, bracketPos);
            }
            symbolTable.Insert(token, $t.text);
            varNames.erase(0, pos + delimiter.length());
        }
        // Handle the last variable
        size_t bracketPos = varNames.find('[');
        if (bracketPos != std::string::npos) {
            varNames = varNames.substr(0, bracketPos);
        }
        symbolTable.Insert(varNames, $t.text);
        
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

func_declaration
	returns[std::string code, int line]:
	t = type_specifier id = ID LPAREN parameter_list RPAREN sm = SEMICOLON {
        $line = $sm->getLine();
        $code = $t.text + " " + $id->getText() + "();";
        
        // Insert function into symbol table
        symbolTable.Insert($id->getText(), $t.text);
        
        writeIntoparserLogFile("Line " + std::to_string($line) + ": func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    }
	| t=type_specifier id=ID LPAREN RPAREN sm=SEMICOLON {
        $line = $sm->getLine();
        $code = $t.text + " " + $id->getText() + "();";
        
        // Insert function into symbol table
        symbolTable.Insert($id->getText(), $t.text);
        
        writeIntoparserLogFile("Line " + std::to_string($line) + ": func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    };

func_definition
    returns[std::string code, int line]:
	t=type_specifier id=ID LPAREN pl=parameter_list RPAREN {
        // Insert function into symbol table
        symbolTable.Insert($id->getText(), $t.text);
        // Enter new scope for function body
        symbolTable.EnterScope();
    } cs=compound_statement {
        $line = $cs.line;
        $code = $t.text + " " + $id->getText() + "(" + $pl.code + ")" + $cs.code;
        
        // Exit function scope
        symbolTable.ExitScope();
        
        writeIntoparserLogFile("Line " + std::to_string($line) + ": func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    }
	| t=type_specifier id=ID LPAREN RPAREN {
        // Insert function into symbol table
        symbolTable.Insert($id->getText(), $t.text);
        // Enter new scope for function body
        symbolTable.EnterScope();
    } cs=compound_statement {
        $line = $cs.line;
        $code = $t.text + " " + $id->getText() + "()" + $cs.code;
        
        // Exit function scope
        symbolTable.ExitScope();
        
        writeIntoparserLogFile("Line " + std::to_string($line) + ": func_definition : type_specifier ID LPAREN RPAREN compound_statement");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    };

parameter_list
    returns[std::string code]:
	pl=parameter_list COMMA t=type_specifier id=ID {
        $code = $pl.code + "," + $t.text + " " + $id->getText();
        
        // Insert parameter into symbol table
        symbolTable.Insert($id->getText(), $t.text);
        
        writeIntoparserLogFile("Line " + std::to_string($id->getLine()) + ": parameter_list : parameter_list COMMA type_specifier ID");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    }
	| pl=parameter_list COMMA t=type_specifier {
        $code = $pl.code + "," + $t.text;
        writeIntoparserLogFile("Line " + std::to_string($t.line) + ": parameter_list : parameter_list COMMA type_specifier");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    }
	| t=type_specifier id=ID {
        $code = $t.text + " " + $id->getText();
        
        // Insert parameter into symbol table
        symbolTable.Insert($id->getText(), $t.text);
        
        writeIntoparserLogFile("Line " + std::to_string($id->getLine()) + ": parameter_list : type_specifier ID");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    }
	| t=type_specifier {
        $code = $t.text;
        writeIntoparserLogFile("Line " + std::to_string($t.line) + ": parameter_list : type_specifier");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    };

compound_statement 
    returns[std::string code, int line]: 
    LCURL {
        // Enter new scope for compound statement (only if not already in function scope)
        symbolTable.EnterScope();
    } ss=statements rc=RCURL {
        $line = $rc->getLine();
        $code = "{\n" + $ss.code + "\n}";
        
        // Exit compound statement scope
        symbolTable.ExitScope();
        
        writeIntoparserLogFile("Line " + std::to_string($line) + ": compound_statement : LCURL statements RCURL");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    }
    | LCURL {
        // Enter new scope for compound statement (only if not already in function scope)
        symbolTable.EnterScope();
    } rc=RCURL {
        $line = $rc->getLine();
        $code = "{\n}";
        
        // Exit compound statement scope
        symbolTable.ExitScope();
        
        writeIntoparserLogFile("Line " + std::to_string($line) + ": compound_statement : LCURL RCURL");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    };