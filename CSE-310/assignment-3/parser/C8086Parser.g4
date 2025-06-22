parser grammar C8086Parser;

options {
	tokenVocab = C8086Lexer;
}

@parser::header {
    #include <iostream>
    #include <fstream>
    #include <string>
    #include <cstdlib>
    #include "C8086Lexer.h"
    #include "SymbolTable.hpp"  

    extern std::ofstream parserLogFile;
    extern std::ofstream errorFile;
    extern int syntaxErrorCount;

    extern SymbolTable symbolTable;  
}

@parser::members {
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
}

start:
	{
        // Enter global scope at the beginning of parsing
        symbolTable.EnterScope();
    }
    program {
        writeIntoparserLogFile("Line " + std::to_string($program.start->getLine()) + ": start : program");
        writeIntoparserLogFile("");
        writeIntoparserLogFile("Parsing completed successfully with " + std::to_string(syntaxErrorCount) + " syntax errors.");
        
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

unit returns [std::string code, int line]
    : vd=var_declaration {
        $code = $vd.code;
        $line = $vd.line;
        writeIntoparserLogFile("Line " + std::to_string($line) + ": unit : var_declaration");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    }
    | fd=func_declaration {
        $code = $fd.code;
        $line = $fd.line;
        writeIntoparserLogFile("Line " + std::to_string($line) + ": unit : func_declaration");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    }
    | fdef=func_definition {
        $code = $fdef.code; 
        $line = $fdef.line;
        writeIntoparserLogFile("Line " + std::to_string($line) + ": unit : func_definition");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    }
    ;

func_declaration
	returns[std::string code, int line]:
	t = type_specifier id = ID LPAREN parameter_list RPAREN sm = SEMICOLON {
        $line = $sm->getLine();
        $code = $t.text + " " + $id->getText() + "();";
        
        // Insert function into symbol table
        symbolTable.Insert($id->getText(), $t.text);
        symbolTable.PrintCurrentScopeTable();
        
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
        symbolTable.PrintCurrentScopeTable();
        
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
        symbolTable.PrintCurrentScopeTable();
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
        symbolTable.PrintCurrentScopeTable();
        
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
        symbolTable.PrintCurrentScopeTable();
        
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
        // Only enter new scope if this is not immediately following a function definition
        // (function definitions already create their own scope)
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
        // Only enter new scope if this is not immediately following a function definition
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
            symbolTable.PrintCurrentScopeTable();
            varNames.erase(0, pos + delimiter.length());
        }
        // Handle the last variable
        size_t bracketPos = varNames.find('[');
        if (bracketPos != std::string::npos) {
            varNames = varNames.substr(0, bracketPos);
        }
        symbolTable.Insert(varNames, $t.text);
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
	| id=ID LTHIRD ci=CONST_INT RTHIRD {
        $names = $id->getText() + "[" + $ci->getText() + "]";
        writeIntoparserLogFile("Line " + std::to_string($id->getLine()) + ": declaration_list : ID LTHIRD CONST_INT RTHIRD");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($names);
        writeIntoparserLogFile("");
    }
	| dl=declaration_list COMMA id=ID LTHIRD ci=CONST_INT RTHIRD {
        $names = $dl.names + "," + $id->getText() + "[" + $ci->getText() + "]";
        writeIntoparserLogFile("Line " + std::to_string($id->getLine()) + ": declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($names);
        writeIntoparserLogFile("");
    };

statements
    returns[std::string code]: 
    s=statement {
        $code = $s.code;
        writeIntoparserLogFile("Line " + std::to_string($s.line) + ": statements : statement");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    }
    | ss=statements s=statement {
        $code = $ss.code + "\n" + $s.code;
        writeIntoparserLogFile("Line " + std::to_string($s.line) + ": statements : statements statement");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    };

statement
    returns[std::string code, int line]:
	vd=var_declaration {
        $code = $vd.code;
        $line = $vd.line;
        writeIntoparserLogFile("Line " + std::to_string($line) + ": statement : var_declaration");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    }
	| es=expression_statement {
        $code = $es.code;
        $line = $es.line;
        writeIntoparserLogFile("Line " + std::to_string($line) + ": statement : expression_statement");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    }
	| cs=compound_statement {
        $code = $cs.code;
        $line = $cs.line;
        writeIntoparserLogFile("Line " + std::to_string($line) + ": statement : compound_statement");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    }
	| FOR LPAREN es1=expression_statement es2=expression_statement e=expression RPAREN s=statement {
        $line = $FOR->getLine();
        $code = "for(" + $es1.code + $es2.code + $e.code + ")" + $s.code;
        writeIntoparserLogFile("Line " + std::to_string($line) + ": statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    }
	| IF LPAREN e=expression RPAREN s=statement {
        $line = $IF->getLine();
        $code = "if(" + $e.code + ")" + $s.code;
        writeIntoparserLogFile("Line " + std::to_string($line) + ": statement : IF LPAREN expression RPAREN statement");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    }
	| IF LPAREN e=expression RPAREN s1=statement ELSE s2=statement {
        $line = $IF->getLine();
        $code = "if(" + $e.code + ")" + $s1.code + "else" + $s2.code;
        writeIntoparserLogFile("Line " + std::to_string($line) + ": statement : IF LPAREN expression RPAREN statement ELSE statement");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    }
	| WHILE LPAREN e=expression RPAREN s=statement {
        $line = $WHILE->getLine();
        $code = "while(" + $e.code + ")" + $s.code;
        writeIntoparserLogFile("Line " + std::to_string($line) + ": statement : WHILE LPAREN expression RPAREN statement");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    }
	| PRINTLN LPAREN id=ID RPAREN sm=SEMICOLON {
        $line = $sm->getLine();
        $code = "println(" + $id->getText() + ");";
        writeIntoparserLogFile("Line " + std::to_string($line) + ": statement : PRINTLN LPAREN ID RPAREN SEMICOLON");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    }
	| RETURN e=expression sm=SEMICOLON {
        $line = $sm->getLine();
        $code = "return " + $e.code + ";";
        writeIntoparserLogFile("Line " + std::to_string($line) + ": statement : RETURN expression SEMICOLON");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    };

expression_statement
    returns[std::string code, int line]: 
    sm=SEMICOLON {
        $line = $sm->getLine();
        $code = ";";
        writeIntoparserLogFile("Line " + std::to_string($line) + ": expression_statement : SEMICOLON");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    }
    | e=expression sm=SEMICOLON {
        $line = $sm->getLine();
        $code = $e.code + ";";
        writeIntoparserLogFile("Line " + std::to_string($line) + ": expression_statement : expression SEMICOLON");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    };

variable
    returns[std::string code, int line]: 
    id=ID {
        $line = $id->getLine();
        $code = $id->getText();
        writeIntoparserLogFile("Line " + std::to_string($line) + ": variable : ID");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    }
    | id=ID LTHIRD e=expression RTHIRD {
        $line = $id->getLine();
        $code = $id->getText() + "[" + $e.code + "]";
        writeIntoparserLogFile("Line " + std::to_string($line) + ": variable : ID LTHIRD expression RTHIRD");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    };

expression
    returns[std::string code, int line]:
	le=logic_expression {
        $code = $le.code; 
        $line = $le.line;
        writeIntoparserLogFile("Line " + std::to_string($line) + ": expression : logic_expression");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    }
	| v=variable ASSIGNOP le=logic_expression {
        $line = $v.line;
        $code = $v.code + "=" + $le.code;
        writeIntoparserLogFile("Line " + std::to_string($line) + ": expression : variable ASSIGNOP logic_expression");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    };

logic_expression
    returns[std::string code, int line]:
	re=rel_expression {
        $code = $re.code;
        $line = $re.line;
        writeIntoparserLogFile("Line " + std::to_string($line) + ": logic_expression : rel_expression");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    }
	| re1=rel_expression op=LOGICOP re2=rel_expression {
        $line = $re1.line;
        $code = $re1.code + $op->getText() + $re2.code;
        writeIntoparserLogFile("Line " + std::to_string($line) + ": logic_expression : rel_expression LOGICOP rel_expression");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    };

rel_expression
    returns[std::string code, int line]:
	se=simple_expression {
        $code = $se.code;
        $line = $se.line;
        writeIntoparserLogFile("Line " + std::to_string($line) + ": rel_expression : simple_expression");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    }
	| se1=simple_expression op=RELOP se2=simple_expression {
        $line = $se1.line;
        $code = $se1.code + $op->getText() + $se2.code;
        writeIntoparserLogFile("Line " + std::to_string($line) + ": rel_expression : simple_expression RELOP simple_expression");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    };

simple_expression
    returns[std::string code, int line]: 
    t=term {
        $code = $t.code;
        $line = $t.line;
        writeIntoparserLogFile("Line " + std::to_string($line) + ": simple_expression : term");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    }
    | se=simple_expression op=ADDOP t=term {
        $line = $se.line;
        $code = $se.code + $op->getText() + $t.code;
        writeIntoparserLogFile("Line " + std::to_string($line) + ": simple_expression : simple_expression ADDOP term");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    };

term
    returns[std::string code, int line]: 
    ue=unary_expression {
        $code = $ue.code;
        $line = $ue.line;
        writeIntoparserLogFile("Line " + std::to_string($line) + ": term : unary_expression");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    }
    | t=term op=MULOP ue=unary_expression {
        $line = $t.line;
        $code = $t.code + $op->getText() + $ue.code;
        writeIntoparserLogFile("Line " + std::to_string($line) + ": term : term MULOP unary_expression");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    };

unary_expression
    returns[std::string code, int line]:
	op=ADDOP ue=unary_expression {
        $line = $op->getLine();
        $code = $op->getText() + $ue.code;
        writeIntoparserLogFile("Line " + std::to_string($line) + ": unary_expression : ADDOP unary_expression");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    }
	| NOT ue=unary_expression {
        $line = $NOT->getLine();
        $code = "!" + $ue.code;
        writeIntoparserLogFile("Line " + std::to_string($line) + ": unary_expression : NOT unary_expression");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    }
	| f=factor {
        $code = $f.code;
        $line = $f.line;
        writeIntoparserLogFile("Line " + std::to_string($line) + ": unary_expression : factor");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    };

factor
    returns[std::string code, int line]:
	v=variable {
        $code = $v.code;
        $line = $v.line;
        writeIntoparserLogFile("Line " + std::to_string($line) + ": factor : variable");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    }
	| id=ID LPAREN al=argument_list RPAREN {
        $line = $id->getLine();
        $code = $id->getText() + "(" + $al.code + ")";
        writeIntoparserLogFile("Line " + std::to_string($line) + ": factor : ID LPAREN argument_list RPAREN");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    }
	| LPAREN e=expression RPAREN {
        $line = $LPAREN->getLine();
        $code = "(" + $e.code + ")";
        writeIntoparserLogFile("Line " + std::to_string($line) + ": factor : LPAREN expression RPAREN");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    }
	| ci=CONST_INT {
        $line = $ci->getLine();
        $code = $ci->getText();
        writeIntoparserLogFile("Line " + std::to_string($line) + ": factor : CONST_INT");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    }
	| cf=CONST_FLOAT {
        $line = $cf->getLine();
        $code = $cf->getText();
        writeIntoparserLogFile("Line " + std::to_string($line) + ": factor : CONST_FLOAT");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    }
	| v=variable INCOP {
        $line = $v.line;
        $code = $v.code + "++";
        writeIntoparserLogFile("Line " + std::to_string($line) + ": factor : variable INCOP");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    }
	| v=variable DECOP {
        $line = $v.line;
        $code = $v.code + "--";
        writeIntoparserLogFile("Line " + std::to_string($line) + ": factor : variable DECOP");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    };

argument_list
    returns[std::string code]: 
    a=arguments {
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
    a=arguments COMMA le=logic_expression {
        $line = $a.line;
        $code = $a.code + "," + $le.code;
        writeIntoparserLogFile("Line " + std::to_string($line) + ": arguments : arguments COMMA logic_expression");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    }
    | le=logic_expression {
        $line = $le.line;
        $code = $le.code;
        writeIntoparserLogFile("Line " + std::to_string($line) + ": arguments : logic_expression");
        writeIntoparserLogFile("");
        writeIntoparserLogFile($code);
        writeIntoparserLogFile("");
    };