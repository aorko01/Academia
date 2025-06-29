// Generated from /Users/shahirbinzulfikeraorko/workspace/Academia/CSE-310/assignment-3/parser/C8086Parser.g4 by ANTLR 4.13.1

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

import org.antlr.v4.runtime.atn.*;
import org.antlr.v4.runtime.dfa.DFA;
import org.antlr.v4.runtime.*;
import org.antlr.v4.runtime.misc.*;
import org.antlr.v4.runtime.tree.*;
import java.util.List;
import java.util.Iterator;
import java.util.ArrayList;

@SuppressWarnings({"all", "warnings", "unchecked", "unused", "cast", "CheckReturnValue"})
public class C8086Parser extends Parser {
	static { RuntimeMetaData.checkVersion("4.13.1", RuntimeMetaData.VERSION); }

	protected static final DFA[] _decisionToDFA;
	protected static final PredictionContextCache _sharedContextCache =
		new PredictionContextCache();
	public static final int
		LINE_COMMENT=1, BLOCK_COMMENT=2, STRING=3, WS=4, IF=5, ELSE=6, FOR=7, 
		WHILE=8, PRINTLN=9, RETURN=10, INT=11, FLOAT=12, VOID=13, LPAREN=14, RPAREN=15, 
		LCURL=16, RCURL=17, LTHIRD=18, RTHIRD=19, SEMICOLON=20, COMMA=21, ADDOP=22, 
		SUBOP=23, MULOP=24, INCOP=25, DECOP=26, NOT=27, RELOP=28, LOGICOP=29, 
		ASSIGNOP=30, ID=31, CONST_INT=32, CONST_FLOAT=33;
	public static final int
		RULE_start = 0, RULE_program = 1, RULE_unit = 2, RULE_func_declaration = 3, 
		RULE_func_definition = 4, RULE_parameter_list = 5, RULE_compound_statement = 6, 
		RULE_var_declaration = 7, RULE_declaration_list_err = 8, RULE_type_specifier = 9, 
		RULE_declaration_list = 10, RULE_statements = 11, RULE_statement = 12, 
		RULE_expression_statement = 13, RULE_variable = 14, RULE_expression = 15, 
		RULE_logic_expression = 16, RULE_rel_expression = 17, RULE_simple_expression = 18, 
		RULE_term = 19, RULE_unary_expression = 20, RULE_factor = 21, RULE_argument_list = 22, 
		RULE_arguments = 23;
	private static String[] makeRuleNames() {
		return new String[] {
			"start", "program", "unit", "func_declaration", "func_definition", "parameter_list", 
			"compound_statement", "var_declaration", "declaration_list_err", "type_specifier", 
			"declaration_list", "statements", "statement", "expression_statement", 
			"variable", "expression", "logic_expression", "rel_expression", "simple_expression", 
			"term", "unary_expression", "factor", "argument_list", "arguments"
		};
	}
	public static final String[] ruleNames = makeRuleNames();

	private static String[] makeLiteralNames() {
		return new String[] {
			null, null, null, null, null, "'if'", "'else'", "'for'", "'while'", "'println'", 
			"'return'", "'int'", "'float'", "'void'", "'('", "')'", "'{'", "'}'", 
			"'['", "']'", "';'", "','", null, null, null, "'++'", "'--'", "'!'", 
			null, null, "'='"
		};
	}
	private static final String[] _LITERAL_NAMES = makeLiteralNames();
	private static String[] makeSymbolicNames() {
		return new String[] {
			null, "LINE_COMMENT", "BLOCK_COMMENT", "STRING", "WS", "IF", "ELSE", 
			"FOR", "WHILE", "PRINTLN", "RETURN", "INT", "FLOAT", "VOID", "LPAREN", 
			"RPAREN", "LCURL", "RCURL", "LTHIRD", "RTHIRD", "SEMICOLON", "COMMA", 
			"ADDOP", "SUBOP", "MULOP", "INCOP", "DECOP", "NOT", "RELOP", "LOGICOP", 
			"ASSIGNOP", "ID", "CONST_INT", "CONST_FLOAT"
		};
	}
	private static final String[] _SYMBOLIC_NAMES = makeSymbolicNames();
	public static final Vocabulary VOCABULARY = new VocabularyImpl(_LITERAL_NAMES, _SYMBOLIC_NAMES);

	/**
	 * @deprecated Use {@link #VOCABULARY} instead.
	 */
	@Deprecated
	public static final String[] tokenNames;
	static {
		tokenNames = new String[_SYMBOLIC_NAMES.length];
		for (int i = 0; i < tokenNames.length; i++) {
			tokenNames[i] = VOCABULARY.getLiteralName(i);
			if (tokenNames[i] == null) {
				tokenNames[i] = VOCABULARY.getSymbolicName(i);
			}

			if (tokenNames[i] == null) {
				tokenNames[i] = "<INVALID>";
			}
		}
	}

	@Override
	@Deprecated
	public String[] getTokenNames() {
		return tokenNames;
	}

	@Override

	public Vocabulary getVocabulary() {
		return VOCABULARY;
	}

	@Override
	public String getGrammarFileName() { return "C8086Parser.g4"; }

	@Override
	public String[] getRuleNames() { return ruleNames; }

	@Override
	public String getSerializedATN() { return _serializedATN; }

	@Override
	public ATN getATN() { return _ATN; }


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

	public C8086Parser(TokenStream input) {
		super(input);
		_interp = new ParserATNSimulator(this,_ATN,_decisionToDFA,_sharedContextCache);
	}

	@SuppressWarnings("CheckReturnValue")
	public static class StartContext extends ParserRuleContext {
		public ProgramContext program;
		public ProgramContext program() {
			return getRuleContext(ProgramContext.class,0);
		}
		public StartContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_start; }
	}

	public final StartContext start() throws RecognitionException {
		StartContext _localctx = new StartContext(_ctx, getState());
		enterRule(_localctx, 0, RULE_start);
		try {
			enterOuterAlt(_localctx, 1);
			{

			        // Enter global scope at the beginning of parsing
			        symbolTable.EnterScope();
			    
			setState(49);
			((StartContext)_localctx).program = program(0);

			        writeIntoparserLogFile("Line " + std::to_string((((StartContext)_localctx).program!=null?(((StartContext)_localctx).program.start):null)->getLine()) + ": start : program");
			        writeIntoparserLogFile("");
			        
			        // Print all scope tables at the end
			        std::streambuf* originalCoutBuffer = std::cout.rdbuf();
			        std::cout.rdbuf(parserLogFile.rdbuf());
			        symbolTable.PrintAllScopeTable();
			        std::cout.rdbuf(originalCoutBuffer);
			        
			        writeIntoparserLogFile("Total number of lines: " + std::to_string((((StartContext)_localctx).program!=null?(((StartContext)_localctx).program.start):null)->getLine()));
			        writeIntoparserLogFile("Total number of errors: " + std::to_string(syntaxErrorCount));
			        
			        // Exit global scope at the end of parsing
			        symbolTable.ExitScope();
				
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class ProgramContext extends ParserRuleContext {
		public std::string code;
		public ProgramContext p;
		public UnitContext u;
		public UnitContext unit() {
			return getRuleContext(UnitContext.class,0);
		}
		public ProgramContext program() {
			return getRuleContext(ProgramContext.class,0);
		}
		public ProgramContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_program; }
	}

	public final ProgramContext program() throws RecognitionException {
		return program(0);
	}

	private ProgramContext program(int _p) throws RecognitionException {
		ParserRuleContext _parentctx = _ctx;
		int _parentState = getState();
		ProgramContext _localctx = new ProgramContext(_ctx, _parentState);
		ProgramContext _prevctx = _localctx;
		int _startState = 2;
		enterRecursionRule(_localctx, 2, RULE_program, _p);
		try {
			int _alt;
			enterOuterAlt(_localctx, 1);
			{
			{
			setState(53);
			((ProgramContext)_localctx).u = unit();

			        ((ProgramContext)_localctx).code =  ((ProgramContext)_localctx).u.code;
			        writeIntoparserLogFile("Line " + std::to_string((((ProgramContext)_localctx).u!=null?(((ProgramContext)_localctx).u.start):null)->getLine()) + ": program : unit");
			        writeIntoparserLogFile("");
			        writeIntoparserLogFile(_localctx.code);
			        writeIntoparserLogFile("");
			    
			}
			_ctx.stop = _input.LT(-1);
			setState(62);
			_errHandler.sync(this);
			_alt = getInterpreter().adaptivePredict(_input,0,_ctx);
			while ( _alt!=2 && _alt!=org.antlr.v4.runtime.atn.ATN.INVALID_ALT_NUMBER ) {
				if ( _alt==1 ) {
					if ( _parseListeners!=null ) triggerExitRuleEvent();
					_prevctx = _localctx;
					{
					{
					_localctx = new ProgramContext(_parentctx, _parentState);
					_localctx.p = _prevctx;
					pushNewRecursionContext(_localctx, _startState, RULE_program);
					setState(56);
					if (!(precpred(_ctx, 2))) throw new FailedPredicateException(this, "precpred(_ctx, 2)");
					setState(57);
					((ProgramContext)_localctx).u = unit();

					                  ((ProgramContext)_localctx).code =  ((ProgramContext)_localctx).p.code + "\n" + ((ProgramContext)_localctx).u.code;
					                  writeIntoparserLogFile("Line " + std::to_string((((ProgramContext)_localctx).u!=null?(((ProgramContext)_localctx).u.start):null)->getLine()) + ": program : program unit");
					                  writeIntoparserLogFile("");
					                  writeIntoparserLogFile(_localctx.code);
					                  writeIntoparserLogFile("");
					              
					}
					} 
				}
				setState(64);
				_errHandler.sync(this);
				_alt = getInterpreter().adaptivePredict(_input,0,_ctx);
			}
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			unrollRecursionContexts(_parentctx);
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class UnitContext extends ParserRuleContext {
		public std::string code;
		public int line;
		public Var_declarationContext vd;
		public Func_declarationContext fd;
		public Func_definitionContext fdef;
		public Var_declarationContext var_declaration() {
			return getRuleContext(Var_declarationContext.class,0);
		}
		public Func_declarationContext func_declaration() {
			return getRuleContext(Func_declarationContext.class,0);
		}
		public Func_definitionContext func_definition() {
			return getRuleContext(Func_definitionContext.class,0);
		}
		public UnitContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_unit; }
	}

	public final UnitContext unit() throws RecognitionException {
		UnitContext _localctx = new UnitContext(_ctx, getState());
		enterRule(_localctx, 4, RULE_unit);
		try {
			setState(74);
			_errHandler.sync(this);
			switch ( getInterpreter().adaptivePredict(_input,1,_ctx) ) {
			case 1:
				enterOuterAlt(_localctx, 1);
				{
				setState(65);
				((UnitContext)_localctx).vd = var_declaration();

				        ((UnitContext)_localctx).code =  ((UnitContext)_localctx).vd.code;
				        ((UnitContext)_localctx).line =  ((UnitContext)_localctx).vd.line;
				        writeIntoparserLogFile("Line " + std::to_string(_localctx.line) + ": unit : var_declaration");
				        writeIntoparserLogFile("");
				        writeIntoparserLogFile(_localctx.code);
				        writeIntoparserLogFile("");
				    
				}
				break;
			case 2:
				enterOuterAlt(_localctx, 2);
				{
				setState(68);
				((UnitContext)_localctx).fd = func_declaration();

				        ((UnitContext)_localctx).code =  ((UnitContext)_localctx).fd.code;
				        ((UnitContext)_localctx).line =  ((UnitContext)_localctx).fd.line;
				        writeIntoparserLogFile("Line " + std::to_string(_localctx.line) + ": unit : func_declaration");
				        writeIntoparserLogFile("");
				        writeIntoparserLogFile(_localctx.code);
				        writeIntoparserLogFile("");
				    
				}
				break;
			case 3:
				enterOuterAlt(_localctx, 3);
				{
				setState(71);
				((UnitContext)_localctx).fdef = func_definition();

				        ((UnitContext)_localctx).code =  ((UnitContext)_localctx).fdef.code; 
				        ((UnitContext)_localctx).line =  ((UnitContext)_localctx).fdef.line;
				        writeIntoparserLogFile("Line " + std::to_string(_localctx.line) + ": unit : func_definition");
				        writeIntoparserLogFile("");
				        writeIntoparserLogFile(_localctx.code);
				        writeIntoparserLogFile("");
				    
				}
				break;
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class Func_declarationContext extends ParserRuleContext {
		public std::string code;
		public int line;
		public Type_specifierContext t;
		public Token id;
		public Parameter_listContext pl;
		public Token sm;
		public TerminalNode LPAREN() { return getToken(C8086Parser.LPAREN, 0); }
		public TerminalNode RPAREN() { return getToken(C8086Parser.RPAREN, 0); }
		public Type_specifierContext type_specifier() {
			return getRuleContext(Type_specifierContext.class,0);
		}
		public TerminalNode ID() { return getToken(C8086Parser.ID, 0); }
		public Parameter_listContext parameter_list() {
			return getRuleContext(Parameter_listContext.class,0);
		}
		public TerminalNode SEMICOLON() { return getToken(C8086Parser.SEMICOLON, 0); }
		public Func_declarationContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_func_declaration; }
	}

	public final Func_declarationContext func_declaration() throws RecognitionException {
		Func_declarationContext _localctx = new Func_declarationContext(_ctx, getState());
		enterRule(_localctx, 6, RULE_func_declaration);
		try {
			setState(95);
			_errHandler.sync(this);
			switch ( getInterpreter().adaptivePredict(_input,2,_ctx) ) {
			case 1:
				enterOuterAlt(_localctx, 1);
				{
				setState(76);
				((Func_declarationContext)_localctx).t = type_specifier();
				setState(77);
				((Func_declarationContext)_localctx).id = match(ID);
				setState(78);
				match(LPAREN);
				 symbolTable.EnterScope(); 
				setState(80);
				((Func_declarationContext)_localctx).pl = parameter_list(0);
				 symbolTable.ExitScope(); 
						
				setState(82);
				match(RPAREN);
				setState(83);
				((Func_declarationContext)_localctx).sm = match(SEMICOLON);

				        ((Func_declarationContext)_localctx).line =  ((Func_declarationContext)_localctx).sm->getLine();
				        ((Func_declarationContext)_localctx).code =  ((Func_declarationContext)_localctx).t.text + " " + ((Func_declarationContext)_localctx).id->getText() + "(" + (((Func_declarationContext)_localctx).pl!=null?_input.getText(((Func_declarationContext)_localctx).pl.start,((Func_declarationContext)_localctx).pl.stop):null) + ");";
				        // Check for multiple declaration as variable in global scope
				        if (isGlobalVariable(((Func_declarationContext)_localctx).id->getText())) {
				            logError(_localctx.line, "Multiple declaration of " + ((Func_declarationContext)_localctx).id->getText());
				        }
				        // Store function signature for later comparison
				        std::string signature = ((Func_declarationContext)_localctx).t.text + ":" + (((Func_declarationContext)_localctx).pl!=null?_input.getText(((Func_declarationContext)_localctx).pl.start,((Func_declarationContext)_localctx).pl.stop):null);
				        if (functionSignatures.count(((Func_declarationContext)_localctx).id->getText()) == 0) {
				            functionSignatures[((Func_declarationContext)_localctx).id->getText()] = signature;
				            functionDefined[((Func_declarationContext)_localctx).id->getText()] = false;
				        } else {
				            // If already declared, check signature
				            if (functionSignatures[((Func_declarationContext)_localctx).id->getText()] != signature) {
				                logError(_localctx.line, "Function signature mismatch of " + ((Func_declarationContext)_localctx).id->getText());
				            }
				        }
				        if (!symbolTable.Insert(((Func_declarationContext)_localctx).id->getText(), ((Func_declarationContext)_localctx).t.text)) {
				            std::string existingType = symbolTable.GetType(((Func_declarationContext)_localctx).id->getText());
				            if (existingType != ((Func_declarationContext)_localctx).t.text) {
				                logError(_localctx.line, "Return type mismatch of " + ((Func_declarationContext)_localctx).id->getText());
				            }
				        }
				        writeIntoparserLogFile("Line " + std::to_string(_localctx.line) + ": func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON");
				        writeIntoparserLogFile("");
				        writeIntoparserLogFile(_localctx.code);
				        writeIntoparserLogFile("");
				    
				}
				break;
			case 2:
				enterOuterAlt(_localctx, 2);
				{
				setState(86);
				((Func_declarationContext)_localctx).t = type_specifier();
				setState(87);
				((Func_declarationContext)_localctx).id = match(ID);
				setState(88);
				match(LPAREN);
				 symbolTable.EnterScope(); 
				setState(90);
				match(RPAREN);
				 symbolTable.ExitScope(); 
						
				setState(92);
				((Func_declarationContext)_localctx).sm = match(SEMICOLON);

				        ((Func_declarationContext)_localctx).line =  ((Func_declarationContext)_localctx).sm->getLine();
				        ((Func_declarationContext)_localctx).code =  ((Func_declarationContext)_localctx).t.text + " " + ((Func_declarationContext)_localctx).id->getText() + "();";
				        if (isGlobalVariable(((Func_declarationContext)_localctx).id->getText())) {
				            logError(_localctx.line, "Multiple declaration of " + ((Func_declarationContext)_localctx).id->getText());
				        }
				        std::string signature = ((Func_declarationContext)_localctx).t.text + ":";
				        if (functionSignatures.count(((Func_declarationContext)_localctx).id->getText()) == 0) {
				            functionSignatures[((Func_declarationContext)_localctx).id->getText()] = signature;
				            functionDefined[((Func_declarationContext)_localctx).id->getText()] = false;
				        } else {
				            if (functionSignatures[((Func_declarationContext)_localctx).id->getText()] != signature) {
				                logError(_localctx.line, "Function signature mismatch of " + ((Func_declarationContext)_localctx).id->getText());
				            }
				        }
				        if (!symbolTable.Insert(((Func_declarationContext)_localctx).id->getText(), ((Func_declarationContext)_localctx).t.text)) {
				            std::string existingType = symbolTable.GetType(((Func_declarationContext)_localctx).id->getText());
				            if (existingType != ((Func_declarationContext)_localctx).t.text) {
				                logError(_localctx.line, "Return type mismatch of " + ((Func_declarationContext)_localctx).id->getText());
				            }
				        }
				        writeIntoparserLogFile("Line " + std::to_string(_localctx.line) + ": func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON");
				        writeIntoparserLogFile("");
				        writeIntoparserLogFile(_localctx.code);
				        writeIntoparserLogFile("");
				    
				}
				break;
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class Func_definitionContext extends ParserRuleContext {
		public std::string code;
		public int line;
		public Type_specifierContext t;
		public Token id;
		public Parameter_listContext pl;
		public Compound_statementContext cs;
		public TerminalNode LPAREN() { return getToken(C8086Parser.LPAREN, 0); }
		public TerminalNode RPAREN() { return getToken(C8086Parser.RPAREN, 0); }
		public Type_specifierContext type_specifier() {
			return getRuleContext(Type_specifierContext.class,0);
		}
		public TerminalNode ID() { return getToken(C8086Parser.ID, 0); }
		public Parameter_listContext parameter_list() {
			return getRuleContext(Parameter_listContext.class,0);
		}
		public Compound_statementContext compound_statement() {
			return getRuleContext(Compound_statementContext.class,0);
		}
		public Func_definitionContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_func_definition; }
	}

	public final Func_definitionContext func_definition() throws RecognitionException {
		Func_definitionContext _localctx = new Func_definitionContext(_ctx, getState());
		enterRule(_localctx, 8, RULE_func_definition);
		try {
			setState(116);
			_errHandler.sync(this);
			switch ( getInterpreter().adaptivePredict(_input,3,_ctx) ) {
			case 1:
				enterOuterAlt(_localctx, 1);
				{
				setState(97);
				((Func_definitionContext)_localctx).t = type_specifier();
				setState(98);
				((Func_definitionContext)_localctx).id = match(ID);

				        // Check for multiple declaration as variable in global scope
				        if (isGlobalVariable(((Func_definitionContext)_localctx).id->getText())) {
				            logError(((Func_definitionContext)_localctx).id->getLine(), "Multiple declaration of " + ((Func_definitionContext)_localctx).id->getText());
				        }
				        currentFunctionName = ((Func_definitionContext)_localctx).id->getText();
				        currentFunctionReturnType = ((Func_definitionContext)_localctx).t.text;
				        // Prepare signature for later check
				    
				setState(100);
				match(LPAREN);
				 symbolTable.EnterScope(); 
				setState(102);
				((Func_definitionContext)_localctx).pl = parameter_list(0);
				setState(103);
				match(RPAREN);
				setState(104);
				((Func_definitionContext)_localctx).cs = compound_statement();

				        ((Func_definitionContext)_localctx).line =  ((Func_definitionContext)_localctx).cs.line;
				        ((Func_definitionContext)_localctx).code =  ((Func_definitionContext)_localctx).t.text + " " + ((Func_definitionContext)_localctx).id->getText() + "(" + ((Func_definitionContext)_localctx).pl.code + ")" + ((Func_definitionContext)_localctx).cs.code;
				        std::string defSignature = ((Func_definitionContext)_localctx).t.text + ":" + ((Func_definitionContext)_localctx).pl.code;
				        if (functionDefined[((Func_definitionContext)_localctx).id->getText()]) {
				            logError(((Func_definitionContext)_localctx).id->getLine(), "Multiple definition of " + ((Func_definitionContext)_localctx).id->getText());
				        } else if (functionSignatures.count(((Func_definitionContext)_localctx).id->getText()) && functionSignatures[((Func_definitionContext)_localctx).id->getText()] != defSignature) {
				            logError(((Func_definitionContext)_localctx).id->getLine(), "Function signature mismatch of " + ((Func_definitionContext)_localctx).id->getText());
				        } else {
				            functionSignatures[((Func_definitionContext)_localctx).id->getText()] = defSignature;
				            functionDefined[((Func_definitionContext)_localctx).id->getText()] = true;
				        }
				        if (!symbolTable.Insert(((Func_definitionContext)_localctx).id->getText(), ((Func_definitionContext)_localctx).t.text)) {
				            std::string existingType = symbolTable.GetType(((Func_definitionContext)_localctx).id->getText());
				            if (existingType != ((Func_definitionContext)_localctx).t.text) {
				                logError(((Func_definitionContext)_localctx).id->getLine(), "Return type mismatch of " + ((Func_definitionContext)_localctx).id->getText());
				            }
				        }
				        currentFunctionName = "";
				        currentFunctionReturnType = "";
				        writeIntoparserLogFile("Line " + std::to_string(_localctx.line) + ": func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement");
				        writeIntoparserLogFile("");
				        writeIntoparserLogFile(_localctx.code);
				        writeIntoparserLogFile("");
				    
				}
				break;
			case 2:
				enterOuterAlt(_localctx, 2);
				{
				setState(107);
				((Func_definitionContext)_localctx).t = type_specifier();
				setState(108);
				((Func_definitionContext)_localctx).id = match(ID);

				        if (isGlobalVariable(((Func_definitionContext)_localctx).id->getText())) {
				            logError(((Func_definitionContext)_localctx).id->getLine(), "Multiple declaration of " + ((Func_definitionContext)_localctx).id->getText());
				        }
				        currentFunctionName = ((Func_definitionContext)_localctx).id->getText();
				        currentFunctionReturnType = ((Func_definitionContext)_localctx).t.text;
				    
				setState(110);
				match(LPAREN);
				 symbolTable.EnterScope(); 
				setState(112);
				match(RPAREN);
				setState(113);
				((Func_definitionContext)_localctx).cs = compound_statement();

				        ((Func_definitionContext)_localctx).line =  ((Func_definitionContext)_localctx).cs.line;
				        ((Func_definitionContext)_localctx).code =  ((Func_definitionContext)_localctx).t.text + " " + ((Func_definitionContext)_localctx).id->getText() + "()" + ((Func_definitionContext)_localctx).cs.code;
				        std::string defSignature = ((Func_definitionContext)_localctx).t.text + ":";
				        if (functionDefined[((Func_definitionContext)_localctx).id->getText()]) {
				            logError(((Func_definitionContext)_localctx).id->getLine(), "Multiple definition of " + ((Func_definitionContext)_localctx).id->getText());
				        } else if (functionSignatures.count(((Func_definitionContext)_localctx).id->getText()) && functionSignatures[((Func_definitionContext)_localctx).id->getText()] != defSignature) {
				            logError(((Func_definitionContext)_localctx).id->getLine(), "Function signature mismatch of " + ((Func_definitionContext)_localctx).id->getText());
				        } else {
				            functionSignatures[((Func_definitionContext)_localctx).id->getText()] = defSignature;
				            functionDefined[((Func_definitionContext)_localctx).id->getText()] = true;
				        }
				        if (!symbolTable.Insert(((Func_definitionContext)_localctx).id->getText(), ((Func_definitionContext)_localctx).t.text)) {
				            std::string existingType = symbolTable.GetType(((Func_definitionContext)_localctx).id->getText());
				            if (existingType != ((Func_definitionContext)_localctx).t.text) {
				                logError(((Func_definitionContext)_localctx).id->getLine(), "Return type mismatch of " + ((Func_definitionContext)_localctx).id->getText());
				            }
				        }
				        currentFunctionName = "";
				        currentFunctionReturnType = "";
				        writeIntoparserLogFile("Line " + std::to_string(_localctx.line) + ": func_definition : type_specifier ID LPAREN RPAREN compound_statement");
				        writeIntoparserLogFile("");
				        writeIntoparserLogFile(_localctx.code);
				        writeIntoparserLogFile("");
				    
				}
				break;
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class Parameter_listContext extends ParserRuleContext {
		public std::string code;
		public Parameter_listContext pl;
		public Type_specifierContext t;
		public Token id;
		public Type_specifierContext type_specifier() {
			return getRuleContext(Type_specifierContext.class,0);
		}
		public TerminalNode ID() { return getToken(C8086Parser.ID, 0); }
		public TerminalNode COMMA() { return getToken(C8086Parser.COMMA, 0); }
		public Parameter_listContext parameter_list() {
			return getRuleContext(Parameter_listContext.class,0);
		}
		public Parameter_listContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_parameter_list; }
	}

	public final Parameter_listContext parameter_list() throws RecognitionException {
		return parameter_list(0);
	}

	private Parameter_listContext parameter_list(int _p) throws RecognitionException {
		ParserRuleContext _parentctx = _ctx;
		int _parentState = getState();
		Parameter_listContext _localctx = new Parameter_listContext(_ctx, _parentState);
		Parameter_listContext _prevctx = _localctx;
		int _startState = 10;
		enterRecursionRule(_localctx, 10, RULE_parameter_list, _p);
		try {
			int _alt;
			enterOuterAlt(_localctx, 1);
			{
			setState(126);
			_errHandler.sync(this);
			switch ( getInterpreter().adaptivePredict(_input,4,_ctx) ) {
			case 1:
				{
				setState(119);
				((Parameter_listContext)_localctx).t = type_specifier();
				setState(120);
				((Parameter_listContext)_localctx).id = match(ID);

				        ((Parameter_listContext)_localctx).code =  ((Parameter_listContext)_localctx).t.text + " " + ((Parameter_listContext)_localctx).id->getText();
				        // Insert parameter into symbol table - Insert returns false if already exists
				        if (!symbolTable.Insert(((Parameter_listContext)_localctx).id->getText(), ((Parameter_listContext)_localctx).t.text)) {
				            logError(((Parameter_listContext)_localctx).id->getLine(), "Multiple declaration of " + ((Parameter_listContext)_localctx).id->getText());
				        }
				        writeIntoparserLogFile("Line " + std::to_string(((Parameter_listContext)_localctx).id->getLine()) + ": parameter_list : type_specifier ID");
				        writeIntoparserLogFile("");
				        writeIntoparserLogFile(_localctx.code);
				        writeIntoparserLogFile("");
				    
				}
				break;
			case 2:
				{
				setState(123);
				((Parameter_listContext)_localctx).t = type_specifier();

				        ((Parameter_listContext)_localctx).code =  ((Parameter_listContext)_localctx).t.text;
				        writeIntoparserLogFile("Line " + std::to_string(((Parameter_listContext)_localctx).t.line) + ": parameter_list : type_specifier");
				        writeIntoparserLogFile("");
				        writeIntoparserLogFile(_localctx.code);
				        writeIntoparserLogFile("");
				    
				}
				break;
			}
			_ctx.stop = _input.LT(-1);
			setState(141);
			_errHandler.sync(this);
			_alt = getInterpreter().adaptivePredict(_input,6,_ctx);
			while ( _alt!=2 && _alt!=org.antlr.v4.runtime.atn.ATN.INVALID_ALT_NUMBER ) {
				if ( _alt==1 ) {
					if ( _parseListeners!=null ) triggerExitRuleEvent();
					_prevctx = _localctx;
					{
					setState(139);
					_errHandler.sync(this);
					switch ( getInterpreter().adaptivePredict(_input,5,_ctx) ) {
					case 1:
						{
						_localctx = new Parameter_listContext(_parentctx, _parentState);
						_localctx.pl = _prevctx;
						pushNewRecursionContext(_localctx, _startState, RULE_parameter_list);
						setState(128);
						if (!(precpred(_ctx, 4))) throw new FailedPredicateException(this, "precpred(_ctx, 4)");
						setState(129);
						match(COMMA);
						setState(130);
						((Parameter_listContext)_localctx).t = type_specifier();
						setState(131);
						((Parameter_listContext)_localctx).id = match(ID);

						                  ((Parameter_listContext)_localctx).code =  ((Parameter_listContext)_localctx).pl.code + "," + ((Parameter_listContext)_localctx).t.text + " " + ((Parameter_listContext)_localctx).id->getText();
						                  // Insert parameter into symbol table - Insert returns false if already exists
						                  if (!symbolTable.Insert(((Parameter_listContext)_localctx).id->getText(), ((Parameter_listContext)_localctx).t.text)) {
						                      logError(((Parameter_listContext)_localctx).id->getLine(), "Multiple declaration of " + ((Parameter_listContext)_localctx).id->getText());
						                  }
						                  writeIntoparserLogFile("Line " + std::to_string(((Parameter_listContext)_localctx).id->getLine()) + ": parameter_list : parameter_list COMMA type_specifier ID");
						                  writeIntoparserLogFile("");
						                  writeIntoparserLogFile(_localctx.code);
						                  writeIntoparserLogFile("");
						              
						}
						break;
					case 2:
						{
						_localctx = new Parameter_listContext(_parentctx, _parentState);
						_localctx.pl = _prevctx;
						pushNewRecursionContext(_localctx, _startState, RULE_parameter_list);
						setState(134);
						if (!(precpred(_ctx, 3))) throw new FailedPredicateException(this, "precpred(_ctx, 3)");
						setState(135);
						match(COMMA);
						setState(136);
						((Parameter_listContext)_localctx).t = type_specifier();

						                  ((Parameter_listContext)_localctx).code =  ((Parameter_listContext)_localctx).pl.code + "," + ((Parameter_listContext)_localctx).t.text;
						                  writeIntoparserLogFile("Line " + std::to_string(((Parameter_listContext)_localctx).t.line) + ": parameter_list : parameter_list COMMA type_specifier");
						                  writeIntoparserLogFile("");
						                  writeIntoparserLogFile(_localctx.code);
						                  writeIntoparserLogFile("");
						              
						}
						break;
					}
					} 
				}
				setState(143);
				_errHandler.sync(this);
				_alt = getInterpreter().adaptivePredict(_input,6,_ctx);
			}
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			unrollRecursionContexts(_parentctx);
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class Compound_statementContext extends ParserRuleContext {
		public std::string code;
		public int line;
		public StatementsContext ss;
		public Token rc;
		public TerminalNode LCURL() { return getToken(C8086Parser.LCURL, 0); }
		public StatementsContext statements() {
			return getRuleContext(StatementsContext.class,0);
		}
		public TerminalNode RCURL() { return getToken(C8086Parser.RCURL, 0); }
		public Compound_statementContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_compound_statement; }
	}

	public final Compound_statementContext compound_statement() throws RecognitionException {
		Compound_statementContext _localctx = new Compound_statementContext(_ctx, getState());
		enterRule(_localctx, 12, RULE_compound_statement);
		try {
			setState(154);
			_errHandler.sync(this);
			switch ( getInterpreter().adaptivePredict(_input,7,_ctx) ) {
			case 1:
				enterOuterAlt(_localctx, 1);
				{
				setState(144);
				match(LCURL);

				        // Enter new scope for compound statement (not for function definitions)
				        symbolTable.EnterScope();
				    
				setState(146);
				((Compound_statementContext)_localctx).ss = statements(0);
				setState(147);
				((Compound_statementContext)_localctx).rc = match(RCURL);

				        ((Compound_statementContext)_localctx).line =  ((Compound_statementContext)_localctx).rc->getLine();
				        ((Compound_statementContext)_localctx).code =  "{\n" + ((Compound_statementContext)_localctx).ss.code + "\n}";
				        writeIntoparserLogFile("Line " + std::to_string(_localctx.line) + ": compound_statement : LCURL statements RCURL");
				        writeIntoparserLogFile("");
				        writeIntoparserLogFile(_localctx.code);
				        writeIntoparserLogFile("");
				        std::streambuf* originalCoutBuffer = std::cout.rdbuf();
				        std::cout.rdbuf(parserLogFile.rdbuf());
				        symbolTable.PrintAllScopeTable();  
				        std::cout.rdbuf(originalCoutBuffer);
				        symbolTable.ExitScope();
				    
				}
				break;
			case 2:
				enterOuterAlt(_localctx, 2);
				{
				setState(150);
				match(LCURL);

				        // Enter new scope for compound statement
				        symbolTable.EnterScope();
				    
				setState(152);
				((Compound_statementContext)_localctx).rc = match(RCURL);

				        ((Compound_statementContext)_localctx).line =  ((Compound_statementContext)_localctx).rc->getLine();
				        ((Compound_statementContext)_localctx).code =  "{}";
				        writeIntoparserLogFile("Line " + std::to_string(_localctx.line) + ": compound_statement : LCURL RCURL");
				        writeIntoparserLogFile("");
				        writeIntoparserLogFile(_localctx.code);
				        writeIntoparserLogFile("");
				        // Exit compound statement scope
				        std::streambuf* originalCoutBuffer = std::cout.rdbuf();
				        std::cout.rdbuf(parserLogFile.rdbuf());
				        symbolTable.PrintAllScopeTable();  
				        std::cout.rdbuf(originalCoutBuffer);
				        symbolTable.ExitScope();
				    
				}
				break;
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class Var_declarationContext extends ParserRuleContext {
		public std::string code;
		public int line;
		public Type_specifierContext t;
		public Declaration_listContext dl;
		public Token sm;
		public Declaration_list_errContext de;
		public Type_specifierContext type_specifier() {
			return getRuleContext(Type_specifierContext.class,0);
		}
		public Declaration_listContext declaration_list() {
			return getRuleContext(Declaration_listContext.class,0);
		}
		public TerminalNode SEMICOLON() { return getToken(C8086Parser.SEMICOLON, 0); }
		public Declaration_list_errContext declaration_list_err() {
			return getRuleContext(Declaration_list_errContext.class,0);
		}
		public Var_declarationContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_var_declaration; }
	}

	public final Var_declarationContext var_declaration() throws RecognitionException {
		Var_declarationContext _localctx = new Var_declarationContext(_ctx, getState());
		enterRule(_localctx, 14, RULE_var_declaration);
		try {
			setState(166);
			_errHandler.sync(this);
			switch ( getInterpreter().adaptivePredict(_input,8,_ctx) ) {
			case 1:
				enterOuterAlt(_localctx, 1);
				{
				setState(156);
				((Var_declarationContext)_localctx).t = type_specifier();
				setState(157);
				((Var_declarationContext)_localctx).dl = declaration_list(0);
				setState(158);
				((Var_declarationContext)_localctx).sm = match(SEMICOLON);

				        ((Var_declarationContext)_localctx).line =  ((Var_declarationContext)_localctx).sm->getLine();
				        ((Var_declarationContext)_localctx).code =  ((Var_declarationContext)_localctx).t.text + " " + ((Var_declarationContext)_localctx).dl.names + ";";
				        // Check for void variable type
				        if (((Var_declarationContext)_localctx).t.text == "void") {
				            logError(_localctx.line, "Variable type cannot be void");
				        }
				        // Insert variables into symbol table with duplicate checking
				        std::string varNames = ((Var_declarationContext)_localctx).dl.names;
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
				            std::string typeInfo = ((Var_declarationContext)_localctx).t.text;
				            if (isArray) typeInfo += "_ARRAY";
				            if (!symbolTable.Insert(token, typeInfo)) {
				                logError(_localctx.line, "Multiple declaration of " + token);
				            }
				            varNames.erase(0, pos + delimiter.length());
				        }
				        // Handle the last variable
				        size_t bracketPos = varNames.find('[');
				        bool isArray = (bracketPos != std::string::npos);
				        if (isArray) {
				            varNames = varNames.substr(0, bracketPos);
				        }
				        std::string typeInfo = ((Var_declarationContext)_localctx).t.text;
				        if (isArray) typeInfo += "_ARRAY";
				        if (!symbolTable.Insert(varNames, typeInfo)) {
				            logError(_localctx.line, "Multiple declaration of " + varNames);
				        }
				        writeIntoparserLogFile("Line " + std::to_string(_localctx.line) + ": var_declaration : type_specifier declaration_list SEMICOLON");
				        writeIntoparserLogFile("");
				        writeIntoparserLogFile(_localctx.code);
				        writeIntoparserLogFile("");
				    
				}
				break;
			case 2:
				enterOuterAlt(_localctx, 2);
				{
				setState(161);
				((Var_declarationContext)_localctx).t = type_specifier();
				setState(162);
				((Var_declarationContext)_localctx).de = declaration_list_err();
				setState(163);
				((Var_declarationContext)_localctx).sm = match(SEMICOLON);

				        writeIntoErrorFile(
				            std::string("Line# ") + std::to_string(((Var_declarationContext)_localctx).sm->getLine()) +
				            " with error name: " + ((Var_declarationContext)_localctx).de.error_name +
				            " - Syntax error at declaration list of variable declaration"
				        );
				        syntaxErrorCount++;
				    
				}
				break;
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class Declaration_list_errContext extends ParserRuleContext {
		public std::string error_name;
		public Declaration_list_errContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_declaration_list_err; }
	}

	public final Declaration_list_errContext declaration_list_err() throws RecognitionException {
		Declaration_list_errContext _localctx = new Declaration_list_errContext(_ctx, getState());
		enterRule(_localctx, 16, RULE_declaration_list_err);
		try {
			enterOuterAlt(_localctx, 1);
			{

			        ((Declaration_list_errContext)_localctx).error_name =  "Error in declaration list";
			    
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class Type_specifierContext extends ParserRuleContext {
		public std::string name_line;
		public std::string typeKeyword;
		public std::string text;
		public int line;
		public Token INT;
		public Token FLOAT;
		public Token VOID;
		public TerminalNode INT() { return getToken(C8086Parser.INT, 0); }
		public TerminalNode FLOAT() { return getToken(C8086Parser.FLOAT, 0); }
		public TerminalNode VOID() { return getToken(C8086Parser.VOID, 0); }
		public Type_specifierContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_type_specifier; }
	}

	public final Type_specifierContext type_specifier() throws RecognitionException {
		Type_specifierContext _localctx = new Type_specifierContext(_ctx, getState());
		enterRule(_localctx, 18, RULE_type_specifier);
		try {
			setState(176);
			_errHandler.sync(this);
			switch (_input.LA(1)) {
			case INT:
				enterOuterAlt(_localctx, 1);
				{
				setState(170);
				((Type_specifierContext)_localctx).INT = match(INT);

				        ((Type_specifierContext)_localctx).line =  ((Type_specifierContext)_localctx).INT->getLine();
				        ((Type_specifierContext)_localctx).name_line =  "type: INT at line" + std::to_string(_localctx.line);
				        ((Type_specifierContext)_localctx).typeKeyword =  ((Type_specifierContext)_localctx).INT->getText();
				        ((Type_specifierContext)_localctx).text =  ((Type_specifierContext)_localctx).INT->getText();
				        writeIntoparserLogFile("Line " + std::to_string(_localctx.line) + ": type_specifier : INT");
				        writeIntoparserLogFile(""); 
				        writeIntoparserLogFile(_localctx.text);
				        writeIntoparserLogFile(""); 
				    
				}
				break;
			case FLOAT:
				enterOuterAlt(_localctx, 2);
				{
				setState(172);
				((Type_specifierContext)_localctx).FLOAT = match(FLOAT);

				        ((Type_specifierContext)_localctx).line =  ((Type_specifierContext)_localctx).FLOAT->getLine();
				        ((Type_specifierContext)_localctx).name_line =  "type: FLOAT at line" + std::to_string(_localctx.line);
				        ((Type_specifierContext)_localctx).typeKeyword =  ((Type_specifierContext)_localctx).FLOAT->getText();
				        ((Type_specifierContext)_localctx).text =  ((Type_specifierContext)_localctx).FLOAT->getText();
				        writeIntoparserLogFile("Line " + std::to_string(_localctx.line) + ": type_specifier : FLOAT");
				        writeIntoparserLogFile(""); 
				        writeIntoparserLogFile(_localctx.text);
				        writeIntoparserLogFile(""); 
				    
				}
				break;
			case VOID:
				enterOuterAlt(_localctx, 3);
				{
				setState(174);
				((Type_specifierContext)_localctx).VOID = match(VOID);

				        ((Type_specifierContext)_localctx).line =  ((Type_specifierContext)_localctx).VOID->getLine();
				        ((Type_specifierContext)_localctx).name_line =  "type: VOID at line" + std::to_string(_localctx.line);
				        ((Type_specifierContext)_localctx).typeKeyword =  ((Type_specifierContext)_localctx).VOID->getText();
				        ((Type_specifierContext)_localctx).text =  ((Type_specifierContext)_localctx).VOID->getText();
				        writeIntoparserLogFile("Line " + std::to_string(_localctx.line) + ": type_specifier : VOID");
				        writeIntoparserLogFile(""); 
				        writeIntoparserLogFile(_localctx.text);
				        writeIntoparserLogFile(""); 
				    
				}
				break;
			default:
				throw new NoViableAltException(this);
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class Declaration_listContext extends ParserRuleContext {
		public std::string names;
		public Declaration_listContext d;
		public Declaration_listContext dl;
		public Token id1;
		public Token id;
		public Token ci;
		public Token id2;
		public TerminalNode ID() { return getToken(C8086Parser.ID, 0); }
		public TerminalNode LTHIRD() { return getToken(C8086Parser.LTHIRD, 0); }
		public TerminalNode RTHIRD() { return getToken(C8086Parser.RTHIRD, 0); }
		public TerminalNode CONST_INT() { return getToken(C8086Parser.CONST_INT, 0); }
		public TerminalNode COMMA() { return getToken(C8086Parser.COMMA, 0); }
		public Declaration_listContext declaration_list() {
			return getRuleContext(Declaration_listContext.class,0);
		}
		public Declaration_listContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_declaration_list; }
	}

	public final Declaration_listContext declaration_list() throws RecognitionException {
		return declaration_list(0);
	}

	private Declaration_listContext declaration_list(int _p) throws RecognitionException {
		ParserRuleContext _parentctx = _ctx;
		int _parentState = getState();
		Declaration_listContext _localctx = new Declaration_listContext(_ctx, _parentState);
		Declaration_listContext _prevctx = _localctx;
		int _startState = 20;
		enterRecursionRule(_localctx, 20, RULE_declaration_list, _p);
		try {
			int _alt;
			enterOuterAlt(_localctx, 1);
			{
			setState(186);
			_errHandler.sync(this);
			switch ( getInterpreter().adaptivePredict(_input,10,_ctx) ) {
			case 1:
				{
				setState(179);
				((Declaration_listContext)_localctx).id1 = match(ID);

				        ((Declaration_listContext)_localctx).names =  ((Declaration_listContext)_localctx).id1->getText();
				        writeIntoparserLogFile("Line " + std::to_string(((Declaration_listContext)_localctx).id1->getLine()) + ": declaration_list : ID");
				        writeIntoparserLogFile("");
				        writeIntoparserLogFile(_localctx.names);
				        writeIntoparserLogFile(""); 
				    
				}
				break;
			case 2:
				{
				setState(181);
				((Declaration_listContext)_localctx).id = match(ID);
				setState(182);
				match(LTHIRD);
				setState(183);
				((Declaration_listContext)_localctx).ci = match(CONST_INT);
				setState(184);
				match(RTHIRD);

				        ((Declaration_listContext)_localctx).names =  ((Declaration_listContext)_localctx).id->getText() + "[" + ((Declaration_listContext)_localctx).ci->getText() + "]";
				        writeIntoparserLogFile("Line " + std::to_string(((Declaration_listContext)_localctx).id->getLine()) + ": declaration_list : ID LTHIRD CONST_INT RTHIRD");
				        writeIntoparserLogFile("");
				        writeIntoparserLogFile(_localctx.names);
				        writeIntoparserLogFile("");
				    
				}
				break;
			}
			_ctx.stop = _input.LT(-1);
			setState(201);
			_errHandler.sync(this);
			_alt = getInterpreter().adaptivePredict(_input,12,_ctx);
			while ( _alt!=2 && _alt!=org.antlr.v4.runtime.atn.ATN.INVALID_ALT_NUMBER ) {
				if ( _alt==1 ) {
					if ( _parseListeners!=null ) triggerExitRuleEvent();
					_prevctx = _localctx;
					{
					setState(199);
					_errHandler.sync(this);
					switch ( getInterpreter().adaptivePredict(_input,11,_ctx) ) {
					case 1:
						{
						_localctx = new Declaration_listContext(_parentctx, _parentState);
						_localctx.d = _prevctx;
						pushNewRecursionContext(_localctx, _startState, RULE_declaration_list);
						setState(188);
						if (!(precpred(_ctx, 3))) throw new FailedPredicateException(this, "precpred(_ctx, 3)");
						setState(189);
						match(COMMA);
						setState(190);
						((Declaration_listContext)_localctx).id2 = match(ID);

						                  ((Declaration_listContext)_localctx).names =  ((Declaration_listContext)_localctx).d.names + "," + ((Declaration_listContext)_localctx).id2->getText();
						                  writeIntoparserLogFile("Line " + std::to_string(((Declaration_listContext)_localctx).id2->getLine()) + ": declaration_list : declaration_list COMMA ID");
						                  writeIntoparserLogFile("");
						                  writeIntoparserLogFile(_localctx.names);
						                  writeIntoparserLogFile(""); 
						              
						}
						break;
					case 2:
						{
						_localctx = new Declaration_listContext(_parentctx, _parentState);
						_localctx.dl = _prevctx;
						pushNewRecursionContext(_localctx, _startState, RULE_declaration_list);
						setState(192);
						if (!(precpred(_ctx, 1))) throw new FailedPredicateException(this, "precpred(_ctx, 1)");
						setState(193);
						match(COMMA);
						setState(194);
						((Declaration_listContext)_localctx).id = match(ID);
						setState(195);
						match(LTHIRD);
						setState(196);
						((Declaration_listContext)_localctx).ci = match(CONST_INT);
						setState(197);
						match(RTHIRD);

						                  ((Declaration_listContext)_localctx).names =  ((Declaration_listContext)_localctx).dl.names + "," + ((Declaration_listContext)_localctx).id->getText() + "[" + ((Declaration_listContext)_localctx).ci->getText() + "]";
						                  writeIntoparserLogFile("Line " + std::to_string(((Declaration_listContext)_localctx).id->getLine()) + ": declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD");
						                  writeIntoparserLogFile("");
						                  writeIntoparserLogFile(_localctx.names);
						                  writeIntoparserLogFile("");
						              
						}
						break;
					}
					} 
				}
				setState(203);
				_errHandler.sync(this);
				_alt = getInterpreter().adaptivePredict(_input,12,_ctx);
			}
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			unrollRecursionContexts(_parentctx);
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class StatementsContext extends ParserRuleContext {
		public std::string code;
		public StatementsContext ss;
		public StatementContext s;
		public StatementContext statement() {
			return getRuleContext(StatementContext.class,0);
		}
		public StatementsContext statements() {
			return getRuleContext(StatementsContext.class,0);
		}
		public StatementsContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_statements; }
	}

	public final StatementsContext statements() throws RecognitionException {
		return statements(0);
	}

	private StatementsContext statements(int _p) throws RecognitionException {
		ParserRuleContext _parentctx = _ctx;
		int _parentState = getState();
		StatementsContext _localctx = new StatementsContext(_ctx, _parentState);
		StatementsContext _prevctx = _localctx;
		int _startState = 22;
		enterRecursionRule(_localctx, 22, RULE_statements, _p);
		try {
			int _alt;
			enterOuterAlt(_localctx, 1);
			{
			{
			setState(205);
			((StatementsContext)_localctx).s = statement();

			        ((StatementsContext)_localctx).code =  ((StatementsContext)_localctx).s.code;
			        writeIntoparserLogFile("Line " + std::to_string(((StatementsContext)_localctx).s.line) + ": statements : statement");
			        writeIntoparserLogFile("");
			        writeIntoparserLogFile(_localctx.code);
			        writeIntoparserLogFile("");
			    
			}
			_ctx.stop = _input.LT(-1);
			setState(214);
			_errHandler.sync(this);
			_alt = getInterpreter().adaptivePredict(_input,13,_ctx);
			while ( _alt!=2 && _alt!=org.antlr.v4.runtime.atn.ATN.INVALID_ALT_NUMBER ) {
				if ( _alt==1 ) {
					if ( _parseListeners!=null ) triggerExitRuleEvent();
					_prevctx = _localctx;
					{
					{
					_localctx = new StatementsContext(_parentctx, _parentState);
					_localctx.ss = _prevctx;
					pushNewRecursionContext(_localctx, _startState, RULE_statements);
					setState(208);
					if (!(precpred(_ctx, 1))) throw new FailedPredicateException(this, "precpred(_ctx, 1)");
					setState(209);
					((StatementsContext)_localctx).s = statement();

					                  ((StatementsContext)_localctx).code =  ((StatementsContext)_localctx).ss.code + "\n" + ((StatementsContext)_localctx).s.code;
					                  writeIntoparserLogFile("Line " + std::to_string(((StatementsContext)_localctx).s.line) + ": statements : statements statement");
					                  writeIntoparserLogFile("");
					                  writeIntoparserLogFile(_localctx.code);
					                  writeIntoparserLogFile("");
					              
					}
					} 
				}
				setState(216);
				_errHandler.sync(this);
				_alt = getInterpreter().adaptivePredict(_input,13,_ctx);
			}
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			unrollRecursionContexts(_parentctx);
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class StatementContext extends ParserRuleContext {
		public std::string code;
		public int line;
		public Var_declarationContext vd;
		public Expression_statementContext es;
		public Compound_statementContext cs;
		public Token FOR;
		public Expression_statementContext es1;
		public Expression_statementContext es2;
		public ExpressionContext e;
		public StatementContext s;
		public Token IF;
		public StatementContext s1;
		public StatementContext s2;
		public Token WHILE;
		public Token id;
		public Token sm;
		public Var_declarationContext var_declaration() {
			return getRuleContext(Var_declarationContext.class,0);
		}
		public List<Expression_statementContext> expression_statement() {
			return getRuleContexts(Expression_statementContext.class);
		}
		public Expression_statementContext expression_statement(int i) {
			return getRuleContext(Expression_statementContext.class,i);
		}
		public Compound_statementContext compound_statement() {
			return getRuleContext(Compound_statementContext.class,0);
		}
		public TerminalNode FOR() { return getToken(C8086Parser.FOR, 0); }
		public TerminalNode LPAREN() { return getToken(C8086Parser.LPAREN, 0); }
		public TerminalNode RPAREN() { return getToken(C8086Parser.RPAREN, 0); }
		public ExpressionContext expression() {
			return getRuleContext(ExpressionContext.class,0);
		}
		public List<StatementContext> statement() {
			return getRuleContexts(StatementContext.class);
		}
		public StatementContext statement(int i) {
			return getRuleContext(StatementContext.class,i);
		}
		public TerminalNode IF() { return getToken(C8086Parser.IF, 0); }
		public TerminalNode ELSE() { return getToken(C8086Parser.ELSE, 0); }
		public TerminalNode WHILE() { return getToken(C8086Parser.WHILE, 0); }
		public TerminalNode PRINTLN() { return getToken(C8086Parser.PRINTLN, 0); }
		public TerminalNode ID() { return getToken(C8086Parser.ID, 0); }
		public TerminalNode SEMICOLON() { return getToken(C8086Parser.SEMICOLON, 0); }
		public TerminalNode RETURN() { return getToken(C8086Parser.RETURN, 0); }
		public StatementContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_statement; }
	}

	public final StatementContext statement() throws RecognitionException {
		StatementContext _localctx = new StatementContext(_ctx, getState());
		enterRule(_localctx, 24, RULE_statement);
		try {
			setState(269);
			_errHandler.sync(this);
			switch ( getInterpreter().adaptivePredict(_input,14,_ctx) ) {
			case 1:
				enterOuterAlt(_localctx, 1);
				{
				setState(217);
				((StatementContext)_localctx).vd = var_declaration();

				        ((StatementContext)_localctx).code =  ((StatementContext)_localctx).vd.code;
				        ((StatementContext)_localctx).line =  ((StatementContext)_localctx).vd.line;
				        writeIntoparserLogFile("Line " + std::to_string(_localctx.line) + ": statement : var_declaration");
				        writeIntoparserLogFile("");
				        writeIntoparserLogFile(_localctx.code);
				        writeIntoparserLogFile("");
				    
				}
				break;
			case 2:
				enterOuterAlt(_localctx, 2);
				{
				setState(220);
				((StatementContext)_localctx).es = expression_statement();

				        ((StatementContext)_localctx).code =  ((StatementContext)_localctx).es.code;
				        ((StatementContext)_localctx).line =  ((StatementContext)_localctx).es.line;
				        writeIntoparserLogFile("Line " + std::to_string(_localctx.line) + ": statement : expression_statement");
				        writeIntoparserLogFile("");
				        writeIntoparserLogFile(_localctx.code);
				        writeIntoparserLogFile("");
				    
				}
				break;
			case 3:
				enterOuterAlt(_localctx, 3);
				{
				setState(223);
				((StatementContext)_localctx).cs = compound_statement();

				        ((StatementContext)_localctx).code =  ((StatementContext)_localctx).cs.code;
				        ((StatementContext)_localctx).line =  ((StatementContext)_localctx).cs.line;
				        writeIntoparserLogFile("Line " + std::to_string(_localctx.line) + ": statement : compound_statement");
				        writeIntoparserLogFile("");
				        writeIntoparserLogFile(_localctx.code);
				        writeIntoparserLogFile("");
				    
				}
				break;
			case 4:
				enterOuterAlt(_localctx, 4);
				{
				setState(226);
				((StatementContext)_localctx).FOR = match(FOR);
				setState(227);
				match(LPAREN);
				setState(228);
				((StatementContext)_localctx).es1 = expression_statement();
				setState(229);
				((StatementContext)_localctx).es2 = expression_statement();
				setState(230);
				((StatementContext)_localctx).e = expression();
				setState(231);
				match(RPAREN);
				setState(232);
				((StatementContext)_localctx).s = statement();

				        ((StatementContext)_localctx).line =  ((StatementContext)_localctx).FOR->getLine();
				        ((StatementContext)_localctx).code =  "for(" + ((StatementContext)_localctx).es1.code + ((StatementContext)_localctx).es2.code + ((StatementContext)_localctx).e.code + ")" + ((StatementContext)_localctx).s.code;
				        writeIntoparserLogFile("Line " + std::to_string(_localctx.line) + ": statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement");
				        writeIntoparserLogFile("");
				        writeIntoparserLogFile(_localctx.code);
				        writeIntoparserLogFile("");
				    
				}
				break;
			case 5:
				enterOuterAlt(_localctx, 5);
				{
				setState(235);
				((StatementContext)_localctx).IF = match(IF);
				setState(236);
				match(LPAREN);
				setState(237);
				((StatementContext)_localctx).e = expression();
				setState(238);
				match(RPAREN);
				setState(239);
				((StatementContext)_localctx).s = statement();

				        ((StatementContext)_localctx).line =  ((StatementContext)_localctx).IF->getLine();
				        ((StatementContext)_localctx).code =  "if(" + ((StatementContext)_localctx).e.code + ")" + ((StatementContext)_localctx).s.code;
				        writeIntoparserLogFile("Line " + std::to_string(_localctx.line) + ": statement : IF LPAREN expression RPAREN statement");
				        writeIntoparserLogFile("");
				        writeIntoparserLogFile(_localctx.code);
				        writeIntoparserLogFile("");
				    
				}
				break;
			case 6:
				enterOuterAlt(_localctx, 6);
				{
				setState(242);
				((StatementContext)_localctx).IF = match(IF);
				setState(243);
				match(LPAREN);
				setState(244);
				((StatementContext)_localctx).e = expression();
				setState(245);
				match(RPAREN);
				setState(246);
				((StatementContext)_localctx).s1 = statement();
				setState(247);
				match(ELSE);
				setState(248);
				((StatementContext)_localctx).s2 = statement();

				        ((StatementContext)_localctx).line =  ((StatementContext)_localctx).IF->getLine();
				        ((StatementContext)_localctx).code =  "if(" + ((StatementContext)_localctx).e.code + ")" + ((StatementContext)_localctx).s1.code + "else" + ((StatementContext)_localctx).s2.code;
				        writeIntoparserLogFile("Line " + std::to_string(_localctx.line) + ": statement : IF LPAREN expression RPAREN statement ELSE statement");
				        writeIntoparserLogFile("");
				        writeIntoparserLogFile(_localctx.code);
				        writeIntoparserLogFile("");
				    
				}
				break;
			case 7:
				enterOuterAlt(_localctx, 7);
				{
				setState(251);
				((StatementContext)_localctx).WHILE = match(WHILE);
				setState(252);
				match(LPAREN);
				setState(253);
				((StatementContext)_localctx).e = expression();
				setState(254);
				match(RPAREN);
				setState(255);
				((StatementContext)_localctx).s = statement();

				        ((StatementContext)_localctx).line =  ((StatementContext)_localctx).WHILE->getLine();
				        ((StatementContext)_localctx).code =  "while(" + ((StatementContext)_localctx).e.code + ")" + ((StatementContext)_localctx).s.code;
				        writeIntoparserLogFile("Line " + std::to_string(_localctx.line) + ": statement : WHILE LPAREN expression RPAREN statement");
				        writeIntoparserLogFile("");
				        writeIntoparserLogFile(_localctx.code);
				        writeIntoparserLogFile("");
				    
				}
				break;
			case 8:
				enterOuterAlt(_localctx, 8);
				{
				setState(258);
				match(PRINTLN);
				setState(259);
				match(LPAREN);
				setState(260);
				((StatementContext)_localctx).id = match(ID);
				setState(261);
				match(RPAREN);
				setState(262);
				((StatementContext)_localctx).sm = match(SEMICOLON);

				        ((StatementContext)_localctx).line =  ((StatementContext)_localctx).sm->getLine();
				        ((StatementContext)_localctx).code =  "println(" + ((StatementContext)_localctx).id->getText() + ");";
				        writeIntoparserLogFile("Line " + std::to_string(_localctx.line) + ": statement : PRINTLN LPAREN ID RPAREN SEMICOLON");
				        writeIntoparserLogFile("");
				        writeIntoparserLogFile(_localctx.code);
				        writeIntoparserLogFile("");
				    
				}
				break;
			case 9:
				enterOuterAlt(_localctx, 9);
				{
				setState(264);
				match(RETURN);
				setState(265);
				((StatementContext)_localctx).e = expression();
				setState(266);
				((StatementContext)_localctx).sm = match(SEMICOLON);

				        ((StatementContext)_localctx).line =  ((StatementContext)_localctx).sm->getLine();
				        ((StatementContext)_localctx).code =  "return " + ((StatementContext)_localctx).e.code + ";";
				        // Check for void function used in expression
				        if (containsVoidFunctionCall(((StatementContext)_localctx).e.code)) {
				            logError(_localctx.line, "Void function used in expression");
				        }
				        // Check for return value in void function
				        if (currentFunctionReturnType == "void") {
				            logError(_localctx.line, "Cannot return value from function " + currentFunctionName + " with void return type");
				        }
				        writeIntoparserLogFile("Line " + std::to_string(_localctx.line) + ": statement : RETURN expression SEMICOLON");
				        writeIntoparserLogFile("");
				        writeIntoparserLogFile(_localctx.code);
				        writeIntoparserLogFile("");
				    
				}
				break;
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class Expression_statementContext extends ParserRuleContext {
		public std::string code;
		public int line;
		public Token sm;
		public ExpressionContext e;
		public TerminalNode SEMICOLON() { return getToken(C8086Parser.SEMICOLON, 0); }
		public ExpressionContext expression() {
			return getRuleContext(ExpressionContext.class,0);
		}
		public Expression_statementContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_expression_statement; }
	}

	public final Expression_statementContext expression_statement() throws RecognitionException {
		Expression_statementContext _localctx = new Expression_statementContext(_ctx, getState());
		enterRule(_localctx, 26, RULE_expression_statement);
		try {
			setState(277);
			_errHandler.sync(this);
			switch (_input.LA(1)) {
			case SEMICOLON:
				enterOuterAlt(_localctx, 1);
				{
				setState(271);
				((Expression_statementContext)_localctx).sm = match(SEMICOLON);

				        ((Expression_statementContext)_localctx).line =  ((Expression_statementContext)_localctx).sm->getLine();
				        ((Expression_statementContext)_localctx).code =  ";";
				        writeIntoparserLogFile("Line " + std::to_string(_localctx.line) + ": expression_statement : SEMICOLON");
				        writeIntoparserLogFile("");
				        writeIntoparserLogFile(_localctx.code);
				        writeIntoparserLogFile("");
				    
				}
				break;
			case LPAREN:
			case ADDOP:
			case NOT:
			case ID:
			case CONST_INT:
			case CONST_FLOAT:
				enterOuterAlt(_localctx, 2);
				{
				setState(273);
				((Expression_statementContext)_localctx).e = expression();
				setState(274);
				((Expression_statementContext)_localctx).sm = match(SEMICOLON);

				        ((Expression_statementContext)_localctx).line =  ((Expression_statementContext)_localctx).sm->getLine();
				        ((Expression_statementContext)_localctx).code =  ((Expression_statementContext)_localctx).e.code + ";";
				        writeIntoparserLogFile("Line " + std::to_string(_localctx.line) + ": expression_statement : expression SEMICOLON");
				        writeIntoparserLogFile("");
				        writeIntoparserLogFile(_localctx.code);
				        writeIntoparserLogFile("");
				    
				}
				break;
			default:
				throw new NoViableAltException(this);
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class VariableContext extends ParserRuleContext {
		public std::string code;
		public int line;
		public Token id;
		public ExpressionContext e;
		public TerminalNode ID() { return getToken(C8086Parser.ID, 0); }
		public TerminalNode LTHIRD() { return getToken(C8086Parser.LTHIRD, 0); }
		public TerminalNode RTHIRD() { return getToken(C8086Parser.RTHIRD, 0); }
		public ExpressionContext expression() {
			return getRuleContext(ExpressionContext.class,0);
		}
		public VariableContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_variable; }
	}

	public final VariableContext variable() throws RecognitionException {
		VariableContext _localctx = new VariableContext(_ctx, getState());
		enterRule(_localctx, 28, RULE_variable);
		try {
			setState(287);
			_errHandler.sync(this);
			switch ( getInterpreter().adaptivePredict(_input,16,_ctx) ) {
			case 1:
				enterOuterAlt(_localctx, 1);
				{
				setState(279);
				((VariableContext)_localctx).id = match(ID);

				        ((VariableContext)_localctx).line =  ((VariableContext)_localctx).id->getLine();
				        ((VariableContext)_localctx).code =  ((VariableContext)_localctx).id->getText();
				        if (symbolTable.Lookup(((VariableContext)_localctx).id->getText()) == NULL) {
				            logError(_localctx.line, "Undeclared variable " + ((VariableContext)_localctx).id->getText());
				        }
				        writeIntoparserLogFile("Line " + std::to_string(_localctx.line) + ": variable : ID");
				        writeIntoparserLogFile("");
				        writeIntoparserLogFile(_localctx.code);
				        writeIntoparserLogFile("");
				    
				}
				break;
			case 2:
				enterOuterAlt(_localctx, 2);
				{
				setState(281);
				((VariableContext)_localctx).id = match(ID);
				setState(282);
				match(LTHIRD);
				setState(283);
				((VariableContext)_localctx).e = expression();
				setState(284);
				match(RTHIRD);

				        ((VariableContext)_localctx).line =  ((VariableContext)_localctx).id->getLine();
				        ((VariableContext)_localctx).code =  ((VariableContext)_localctx).id->getText() + "[" + ((VariableContext)_localctx).e.code + "]";
				        if (symbolTable.Lookup(((VariableContext)_localctx).id->getText()) == NULL) {
				            logError(_localctx.line, "Undeclared variable " + ((VariableContext)_localctx).id->getText());
				        } else {
				            // Check if variable is actually an array
				            if (!isArrayVariable(((VariableContext)_localctx).id->getText())) {
				                logError(_localctx.line, ((VariableContext)_localctx).id->getText() + " not an array");
				            }
				            // Check if array index is integer
				            if (!isIntegerExpression(((VariableContext)_localctx).e.code)) {
				                logError(_localctx.line, "Expression inside third brackets not an integer");
				            }
				        }
				        writeIntoparserLogFile("Line " + std::to_string(_localctx.line) + ": variable : ID LTHIRD expression RTHIRD");
				        writeIntoparserLogFile("");
				        writeIntoparserLogFile(_localctx.code);
				        writeIntoparserLogFile("");
				    
				}
				break;
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class ExpressionContext extends ParserRuleContext {
		public std::string code;
		public int line;
		public Logic_expressionContext le;
		public VariableContext v;
		public Logic_expressionContext logic_expression() {
			return getRuleContext(Logic_expressionContext.class,0);
		}
		public TerminalNode ASSIGNOP() { return getToken(C8086Parser.ASSIGNOP, 0); }
		public VariableContext variable() {
			return getRuleContext(VariableContext.class,0);
		}
		public ExpressionContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_expression; }
	}

	public final ExpressionContext expression() throws RecognitionException {
		ExpressionContext _localctx = new ExpressionContext(_ctx, getState());
		enterRule(_localctx, 30, RULE_expression);
		try {
			setState(297);
			_errHandler.sync(this);
			switch ( getInterpreter().adaptivePredict(_input,17,_ctx) ) {
			case 1:
				enterOuterAlt(_localctx, 1);
				{
				setState(289);
				((ExpressionContext)_localctx).le = logic_expression();

				        ((ExpressionContext)_localctx).code =  ((ExpressionContext)_localctx).le.code; 
				        ((ExpressionContext)_localctx).line =  ((ExpressionContext)_localctx).le.line;
				        // Check for void function used in expression
				        if (containsVoidFunctionCall(((ExpressionContext)_localctx).le.code)) {
				            logError(_localctx.line, "Void function used in expression");
				        }
				        writeIntoparserLogFile("Line " + std::to_string(_localctx.line) + ": expression : logic_expression");
				        writeIntoparserLogFile("");
				        writeIntoparserLogFile(_localctx.code);
				        writeIntoparserLogFile("");
				    
				}
				break;
			case 2:
				enterOuterAlt(_localctx, 2);
				{
				setState(292);
				((ExpressionContext)_localctx).v = variable();
				setState(293);
				match(ASSIGNOP);
				setState(294);
				((ExpressionContext)_localctx).le = logic_expression();

				        ((ExpressionContext)_localctx).line =  ((ExpressionContext)_localctx).v.line;
				        ((ExpressionContext)_localctx).code =  ((ExpressionContext)_localctx).v.code + "=" + ((ExpressionContext)_localctx).le.code;
				        // Check for void function used in expression
				        if (containsVoidFunctionCall(((ExpressionContext)_localctx).le.code)) {
				            logError(_localctx.line, "Void function used in expression");
				        }
				        std::string varName = ((ExpressionContext)_localctx).v.code;
				        size_t bracketPos = varName.find('[');
				        if (bracketPos != std::string::npos) {
				            varName = varName.substr(0, bracketPos);
				        }
				        SymbolInfo* varInfo = symbolTable.Lookup(varName);
				        if (varInfo != NULL) {
				            std::string varType = getVariableType(varName);
				            bool isArray = isArrayVariable(varName);
				            if (isArray && bracketPos == std::string::npos) {
				                logError(_localctx.line, "Type mismatch, " + varName + " is an array");
				            }
				            else if (varType == "int" && ((ExpressionContext)_localctx).le.code.find('.') != std::string::npos) {
				                logError(_localctx.line, "Type Mismatch");
				            }
				        }
				        writeIntoparserLogFile("Line " + std::to_string(_localctx.line) + ": expression : variable ASSIGNOP logic_expression");
				        writeIntoparserLogFile("");
				        writeIntoparserLogFile(_localctx.code);
				        writeIntoparserLogFile("");
				    
				}
				break;
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class Logic_expressionContext extends ParserRuleContext {
		public std::string code;
		public int line;
		public Rel_expressionContext re;
		public Rel_expressionContext re1;
		public Token op;
		public Rel_expressionContext re2;
		public List<Rel_expressionContext> rel_expression() {
			return getRuleContexts(Rel_expressionContext.class);
		}
		public Rel_expressionContext rel_expression(int i) {
			return getRuleContext(Rel_expressionContext.class,i);
		}
		public TerminalNode LOGICOP() { return getToken(C8086Parser.LOGICOP, 0); }
		public Logic_expressionContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_logic_expression; }
	}

	public final Logic_expressionContext logic_expression() throws RecognitionException {
		Logic_expressionContext _localctx = new Logic_expressionContext(_ctx, getState());
		enterRule(_localctx, 32, RULE_logic_expression);
		try {
			setState(307);
			_errHandler.sync(this);
			switch ( getInterpreter().adaptivePredict(_input,18,_ctx) ) {
			case 1:
				enterOuterAlt(_localctx, 1);
				{
				setState(299);
				((Logic_expressionContext)_localctx).re = rel_expression();

				        ((Logic_expressionContext)_localctx).code =  ((Logic_expressionContext)_localctx).re.code;
				        ((Logic_expressionContext)_localctx).line =  ((Logic_expressionContext)_localctx).re.line;
				        writeIntoparserLogFile("Line " + std::to_string(_localctx.line) + ": logic_expression : rel_expression");
				        writeIntoparserLogFile("");
				        writeIntoparserLogFile(_localctx.code);
				        writeIntoparserLogFile("");
				    
				}
				break;
			case 2:
				enterOuterAlt(_localctx, 2);
				{
				setState(302);
				((Logic_expressionContext)_localctx).re1 = rel_expression();
				setState(303);
				((Logic_expressionContext)_localctx).op = match(LOGICOP);
				setState(304);
				((Logic_expressionContext)_localctx).re2 = rel_expression();

				        ((Logic_expressionContext)_localctx).line =  ((Logic_expressionContext)_localctx).re1.line;
				        ((Logic_expressionContext)_localctx).code =  ((Logic_expressionContext)_localctx).re1.code + ((Logic_expressionContext)_localctx).op->getText() + ((Logic_expressionContext)_localctx).re2.code;
				        writeIntoparserLogFile("Line " + std::to_string(_localctx.line) + ": logic_expression : rel_expression LOGICOP rel_expression");
				        writeIntoparserLogFile("");
				        writeIntoparserLogFile(_localctx.code);
				        writeIntoparserLogFile("");
				    
				}
				break;
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class Rel_expressionContext extends ParserRuleContext {
		public std::string code;
		public int line;
		public Simple_expressionContext se;
		public Simple_expressionContext se1;
		public Token op;
		public Simple_expressionContext se2;
		public List<Simple_expressionContext> simple_expression() {
			return getRuleContexts(Simple_expressionContext.class);
		}
		public Simple_expressionContext simple_expression(int i) {
			return getRuleContext(Simple_expressionContext.class,i);
		}
		public TerminalNode RELOP() { return getToken(C8086Parser.RELOP, 0); }
		public Rel_expressionContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_rel_expression; }
	}

	public final Rel_expressionContext rel_expression() throws RecognitionException {
		Rel_expressionContext _localctx = new Rel_expressionContext(_ctx, getState());
		enterRule(_localctx, 34, RULE_rel_expression);
		try {
			setState(317);
			_errHandler.sync(this);
			switch ( getInterpreter().adaptivePredict(_input,19,_ctx) ) {
			case 1:
				enterOuterAlt(_localctx, 1);
				{
				setState(309);
				((Rel_expressionContext)_localctx).se = simple_expression(0);

				        ((Rel_expressionContext)_localctx).code =  ((Rel_expressionContext)_localctx).se.code;
				        ((Rel_expressionContext)_localctx).line =  ((Rel_expressionContext)_localctx).se.line;
				        writeIntoparserLogFile("Line " + std::to_string(_localctx.line) + ": rel_expression : simple_expression");
				        writeIntoparserLogFile("");
				        writeIntoparserLogFile(_localctx.code);
				        writeIntoparserLogFile("");
				    
				}
				break;
			case 2:
				enterOuterAlt(_localctx, 2);
				{
				setState(312);
				((Rel_expressionContext)_localctx).se1 = simple_expression(0);
				setState(313);
				((Rel_expressionContext)_localctx).op = match(RELOP);
				setState(314);
				((Rel_expressionContext)_localctx).se2 = simple_expression(0);

				        ((Rel_expressionContext)_localctx).line =  ((Rel_expressionContext)_localctx).se1.line;
				        ((Rel_expressionContext)_localctx).code =  ((Rel_expressionContext)_localctx).se1.code + ((Rel_expressionContext)_localctx).op->getText() + ((Rel_expressionContext)_localctx).se2.code;
				        writeIntoparserLogFile("Line " + std::to_string(_localctx.line) + ": rel_expression : simple_expression RELOP simple_expression");
				        writeIntoparserLogFile("");
				        writeIntoparserLogFile(_localctx.code);
				        writeIntoparserLogFile("");
				    
				}
				break;
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class Simple_expressionContext extends ParserRuleContext {
		public std::string code;
		public int line;
		public Simple_expressionContext se;
		public TermContext t;
		public Token op;
		public TermContext term() {
			return getRuleContext(TermContext.class,0);
		}
		public Simple_expressionContext simple_expression() {
			return getRuleContext(Simple_expressionContext.class,0);
		}
		public TerminalNode ADDOP() { return getToken(C8086Parser.ADDOP, 0); }
		public Simple_expressionContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_simple_expression; }
	}

	public final Simple_expressionContext simple_expression() throws RecognitionException {
		return simple_expression(0);
	}

	private Simple_expressionContext simple_expression(int _p) throws RecognitionException {
		ParserRuleContext _parentctx = _ctx;
		int _parentState = getState();
		Simple_expressionContext _localctx = new Simple_expressionContext(_ctx, _parentState);
		Simple_expressionContext _prevctx = _localctx;
		int _startState = 36;
		enterRecursionRule(_localctx, 36, RULE_simple_expression, _p);
		try {
			int _alt;
			enterOuterAlt(_localctx, 1);
			{
			{
			setState(320);
			((Simple_expressionContext)_localctx).t = term(0);

			        ((Simple_expressionContext)_localctx).code =  ((Simple_expressionContext)_localctx).t.code;
			        ((Simple_expressionContext)_localctx).line =  ((Simple_expressionContext)_localctx).t.line;
			        writeIntoparserLogFile("Line " + std::to_string(_localctx.line) + ": simple_expression : term");
			        writeIntoparserLogFile("");
			        writeIntoparserLogFile(_localctx.code);
			        writeIntoparserLogFile("");
			    
			}
			_ctx.stop = _input.LT(-1);
			setState(330);
			_errHandler.sync(this);
			_alt = getInterpreter().adaptivePredict(_input,20,_ctx);
			while ( _alt!=2 && _alt!=org.antlr.v4.runtime.atn.ATN.INVALID_ALT_NUMBER ) {
				if ( _alt==1 ) {
					if ( _parseListeners!=null ) triggerExitRuleEvent();
					_prevctx = _localctx;
					{
					{
					_localctx = new Simple_expressionContext(_parentctx, _parentState);
					_localctx.se = _prevctx;
					pushNewRecursionContext(_localctx, _startState, RULE_simple_expression);
					setState(323);
					if (!(precpred(_ctx, 1))) throw new FailedPredicateException(this, "precpred(_ctx, 1)");
					setState(324);
					((Simple_expressionContext)_localctx).op = match(ADDOP);
					setState(325);
					((Simple_expressionContext)_localctx).t = term(0);

					                  ((Simple_expressionContext)_localctx).line =  ((Simple_expressionContext)_localctx).se.line;
					                  ((Simple_expressionContext)_localctx).code =  ((Simple_expressionContext)_localctx).se.code + ((Simple_expressionContext)_localctx).op->getText() + ((Simple_expressionContext)_localctx).t.code;
					                  writeIntoparserLogFile("Line " + std::to_string(_localctx.line) + ": simple_expression : simple_expression ADDOP term");
					                  writeIntoparserLogFile("");
					                  writeIntoparserLogFile(_localctx.code);
					                  writeIntoparserLogFile("");
					              
					}
					} 
				}
				setState(332);
				_errHandler.sync(this);
				_alt = getInterpreter().adaptivePredict(_input,20,_ctx);
			}
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			unrollRecursionContexts(_parentctx);
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class TermContext extends ParserRuleContext {
		public std::string code;
		public int line;
		public TermContext t;
		public Unary_expressionContext ue;
		public Token op;
		public Unary_expressionContext unary_expression() {
			return getRuleContext(Unary_expressionContext.class,0);
		}
		public TermContext term() {
			return getRuleContext(TermContext.class,0);
		}
		public TerminalNode MULOP() { return getToken(C8086Parser.MULOP, 0); }
		public TermContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_term; }
	}

	public final TermContext term() throws RecognitionException {
		return term(0);
	}

	private TermContext term(int _p) throws RecognitionException {
		ParserRuleContext _parentctx = _ctx;
		int _parentState = getState();
		TermContext _localctx = new TermContext(_ctx, _parentState);
		TermContext _prevctx = _localctx;
		int _startState = 38;
		enterRecursionRule(_localctx, 38, RULE_term, _p);
		try {
			int _alt;
			enterOuterAlt(_localctx, 1);
			{
			{
			setState(334);
			((TermContext)_localctx).ue = unary_expression();

			        ((TermContext)_localctx).code =  ((TermContext)_localctx).ue.code;
			        ((TermContext)_localctx).line =  ((TermContext)_localctx).ue.line;
			        writeIntoparserLogFile("Line " + std::to_string(_localctx.line) + ": term : unary_expression");
			        writeIntoparserLogFile("");
			        writeIntoparserLogFile(_localctx.code);
			        writeIntoparserLogFile("");
			    
			}
			_ctx.stop = _input.LT(-1);
			setState(344);
			_errHandler.sync(this);
			_alt = getInterpreter().adaptivePredict(_input,21,_ctx);
			while ( _alt!=2 && _alt!=org.antlr.v4.runtime.atn.ATN.INVALID_ALT_NUMBER ) {
				if ( _alt==1 ) {
					if ( _parseListeners!=null ) triggerExitRuleEvent();
					_prevctx = _localctx;
					{
					{
					_localctx = new TermContext(_parentctx, _parentState);
					_localctx.t = _prevctx;
					pushNewRecursionContext(_localctx, _startState, RULE_term);
					setState(337);
					if (!(precpred(_ctx, 1))) throw new FailedPredicateException(this, "precpred(_ctx, 1)");
					setState(338);
					((TermContext)_localctx).op = match(MULOP);
					setState(339);
					((TermContext)_localctx).ue = unary_expression();

					                  ((TermContext)_localctx).line =  ((TermContext)_localctx).t.line;
					                  ((TermContext)_localctx).code =  ((TermContext)_localctx).t.code + ((TermContext)_localctx).op->getText() + ((TermContext)_localctx).ue.code;
					                  if (((TermContext)_localctx).op->getText() == "%") {
					                      // Check for modulus by zero
					                      if (isZeroDivision(((TermContext)_localctx).ue.code)) {
					                          logError(_localctx.line, "Modulus by Zero");
					                      }
					                      // Check for non-integer operands
					                      else if (!isIntegerExpression(((TermContext)_localctx).t.code) || !isIntegerExpression(((TermContext)_localctx).ue.code)) {
					                          logError(_localctx.line, "Non-Integer operand on modulus operator");
					                      }
					                  }
					                  writeIntoparserLogFile("Line " + std::to_string(_localctx.line) + ": term : term MULOP unary_expression");
					                  writeIntoparserLogFile("");
					                  writeIntoparserLogFile(_localctx.code);
					                  writeIntoparserLogFile("");
					              
					}
					} 
				}
				setState(346);
				_errHandler.sync(this);
				_alt = getInterpreter().adaptivePredict(_input,21,_ctx);
			}
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			unrollRecursionContexts(_parentctx);
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class Unary_expressionContext extends ParserRuleContext {
		public std::string code;
		public int line;
		public Token op;
		public Unary_expressionContext ue;
		public Token NOT;
		public FactorContext f;
		public TerminalNode ADDOP() { return getToken(C8086Parser.ADDOP, 0); }
		public Unary_expressionContext unary_expression() {
			return getRuleContext(Unary_expressionContext.class,0);
		}
		public TerminalNode NOT() { return getToken(C8086Parser.NOT, 0); }
		public FactorContext factor() {
			return getRuleContext(FactorContext.class,0);
		}
		public Unary_expressionContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_unary_expression; }
	}

	public final Unary_expressionContext unary_expression() throws RecognitionException {
		Unary_expressionContext _localctx = new Unary_expressionContext(_ctx, getState());
		enterRule(_localctx, 40, RULE_unary_expression);
		try {
			setState(358);
			_errHandler.sync(this);
			switch (_input.LA(1)) {
			case ADDOP:
				enterOuterAlt(_localctx, 1);
				{
				setState(347);
				((Unary_expressionContext)_localctx).op = match(ADDOP);
				setState(348);
				((Unary_expressionContext)_localctx).ue = unary_expression();

				        ((Unary_expressionContext)_localctx).line =  ((Unary_expressionContext)_localctx).op->getLine();
				        ((Unary_expressionContext)_localctx).code =  ((Unary_expressionContext)_localctx).op->getText() + ((Unary_expressionContext)_localctx).ue.code;
				        writeIntoparserLogFile("Line " + std::to_string(_localctx.line) + ": unary_expression : ADDOP unary_expression");
				        writeIntoparserLogFile("");
				        writeIntoparserLogFile(_localctx.code);
				        writeIntoparserLogFile("");
				    
				}
				break;
			case NOT:
				enterOuterAlt(_localctx, 2);
				{
				setState(351);
				((Unary_expressionContext)_localctx).NOT = match(NOT);
				setState(352);
				((Unary_expressionContext)_localctx).ue = unary_expression();

				        ((Unary_expressionContext)_localctx).line =  ((Unary_expressionContext)_localctx).NOT->getLine();
				        ((Unary_expressionContext)_localctx).code =  "!" + ((Unary_expressionContext)_localctx).ue.code;
				        writeIntoparserLogFile("Line " + std::to_string(_localctx.line) + ": unary_expression : NOT unary_expression");
				        writeIntoparserLogFile("");
				        writeIntoparserLogFile(_localctx.code);
				        writeIntoparserLogFile("");
				    
				}
				break;
			case LPAREN:
			case ID:
			case CONST_INT:
			case CONST_FLOAT:
				enterOuterAlt(_localctx, 3);
				{
				setState(355);
				((Unary_expressionContext)_localctx).f = factor();

				        ((Unary_expressionContext)_localctx).code =  ((Unary_expressionContext)_localctx).f.code;
				        ((Unary_expressionContext)_localctx).line =  ((Unary_expressionContext)_localctx).f.line;
				        writeIntoparserLogFile("Line " + std::to_string(_localctx.line) + ": unary_expression : factor");
				        writeIntoparserLogFile("");
				        writeIntoparserLogFile(_localctx.code);
				        writeIntoparserLogFile("");
				    
				}
				break;
			default:
				throw new NoViableAltException(this);
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class FactorContext extends ParserRuleContext {
		public std::string code;
		public int line;
		public VariableContext v;
		public Token id;
		public Argument_listContext al;
		public Token LPAREN;
		public ExpressionContext e;
		public Token ci;
		public Token cf;
		public VariableContext variable() {
			return getRuleContext(VariableContext.class,0);
		}
		public TerminalNode LPAREN() { return getToken(C8086Parser.LPAREN, 0); }
		public TerminalNode RPAREN() { return getToken(C8086Parser.RPAREN, 0); }
		public TerminalNode ID() { return getToken(C8086Parser.ID, 0); }
		public Argument_listContext argument_list() {
			return getRuleContext(Argument_listContext.class,0);
		}
		public ExpressionContext expression() {
			return getRuleContext(ExpressionContext.class,0);
		}
		public TerminalNode CONST_INT() { return getToken(C8086Parser.CONST_INT, 0); }
		public TerminalNode CONST_FLOAT() { return getToken(C8086Parser.CONST_FLOAT, 0); }
		public TerminalNode INCOP() { return getToken(C8086Parser.INCOP, 0); }
		public TerminalNode DECOP() { return getToken(C8086Parser.DECOP, 0); }
		public FactorContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_factor; }
	}

	public final FactorContext factor() throws RecognitionException {
		FactorContext _localctx = new FactorContext(_ctx, getState());
		enterRule(_localctx, 42, RULE_factor);
		try {
			setState(386);
			_errHandler.sync(this);
			switch ( getInterpreter().adaptivePredict(_input,23,_ctx) ) {
			case 1:
				enterOuterAlt(_localctx, 1);
				{
				setState(360);
				((FactorContext)_localctx).v = variable();

				        ((FactorContext)_localctx).code =  ((FactorContext)_localctx).v.code;
				        ((FactorContext)_localctx).line =  ((FactorContext)_localctx).v.line;
				        writeIntoparserLogFile("Line " + std::to_string(_localctx.line) + ": factor : variable");
				        writeIntoparserLogFile("");
				        writeIntoparserLogFile(_localctx.code);
				        writeIntoparserLogFile("");
				    
				}
				break;
			case 2:
				enterOuterAlt(_localctx, 2);
				{
				setState(363);
				((FactorContext)_localctx).id = match(ID);
				setState(364);
				match(LPAREN);
				setState(365);
				((FactorContext)_localctx).al = argument_list();
				setState(366);
				match(RPAREN);

				        ((FactorContext)_localctx).line =  ((FactorContext)_localctx).id->getLine();
				        ((FactorContext)_localctx).code =  ((FactorContext)_localctx).id->getText() + "(" + ((FactorContext)_localctx).al.code + ")";
				        // Check if function is declared
				        if (symbolTable.Lookup(((FactorContext)_localctx).id->getText()) == NULL) {
				            logError(_localctx.line, "Undefined function " + ((FactorContext)_localctx).id->getText());
				        }
				        // Argument checking
				        std::string funcName = ((FactorContext)_localctx).id->getText();
				        std::string signature = functionSignatures.count(funcName) ? functionSignatures[funcName] : "";
				        std::string paramList = "";
				        size_t colon = signature.find(':');
				        if (colon != std::string::npos) paramList = signature.substr(colon+1);
				        std::vector<std::string> paramTypes = splitParameterTypes(paramList);
				        std::vector<std::string> argList = splitArgumentList(((FactorContext)_localctx).al.code);
				        if (paramTypes.size() != argList.size()) {
				            logError(_localctx.line, "Total number of arguments mismatch with declaration in function " + funcName);
				        } else {
				            for (size_t i = 0; i < paramTypes.size(); ++i) {
				                std::string argType = getArgumentType(argList[i]);
				                std::string paramType = paramTypes[i];
				                // If argument is an array but parameter is not
				                if (isArrayVariable(argList[i]) && paramType != "int_ARRAY" && paramType != "float_ARRAY") {
				                    logError(_localctx.line, "Type mismatch, " + argList[i] + " is an array");
				                }
				                // If type does not match
				                else if (paramType == "int" && argType != "int") {
				                    logError(_localctx.line, std::to_string(i+1) + "th argument mismatch in function " + funcName);
				                } else if (paramType == "float" && argType != "float") {
				                    logError(_localctx.line, std::to_string(i+1) + "th argument mismatch in function " + funcName);
				                } else if ((paramType == "int_ARRAY" || paramType == "float_ARRAY") && argType != paramType) {
				                    logError(_localctx.line, std::to_string(i+1) + "th argument mismatch in function " + funcName);
				                }
				            }
				        }
				        writeIntoparserLogFile("Line " + std::to_string(_localctx.line) + ": factor : ID LPAREN argument_list RPAREN");
				        writeIntoparserLogFile("");
				        writeIntoparserLogFile(_localctx.code);
				        writeIntoparserLogFile("");
				    
				}
				break;
			case 3:
				enterOuterAlt(_localctx, 3);
				{
				setState(369);
				((FactorContext)_localctx).LPAREN = match(LPAREN);
				setState(370);
				((FactorContext)_localctx).e = expression();
				setState(371);
				match(RPAREN);

				        ((FactorContext)_localctx).line =  ((FactorContext)_localctx).LPAREN->getLine();
				        ((FactorContext)_localctx).code =  "(" + ((FactorContext)_localctx).e.code + ")";
				        writeIntoparserLogFile("Line " + std::to_string(_localctx.line) + ": factor : LPAREN expression RPAREN");
				        writeIntoparserLogFile("");
				        writeIntoparserLogFile(_localctx.code);
				        writeIntoparserLogFile("");
				    
				}
				break;
			case 4:
				enterOuterAlt(_localctx, 4);
				{
				setState(374);
				((FactorContext)_localctx).ci = match(CONST_INT);

				        ((FactorContext)_localctx).line =  ((FactorContext)_localctx).ci->getLine();
				        ((FactorContext)_localctx).code =  ((FactorContext)_localctx).ci->getText();
				        writeIntoparserLogFile("Line " + std::to_string(_localctx.line) + ": factor : CONST_INT");
				        writeIntoparserLogFile("");
				        writeIntoparserLogFile(_localctx.code);
				        writeIntoparserLogFile("");
				    
				}
				break;
			case 5:
				enterOuterAlt(_localctx, 5);
				{
				setState(376);
				((FactorContext)_localctx).cf = match(CONST_FLOAT);

				        ((FactorContext)_localctx).line =  ((FactorContext)_localctx).cf->getLine();
				        ((FactorContext)_localctx).code =  ((FactorContext)_localctx).cf->getText();
				        writeIntoparserLogFile("Line " + std::to_string(_localctx.line) + ": factor : CONST_FLOAT");
				        writeIntoparserLogFile("");
				        writeIntoparserLogFile(_localctx.code);
				        writeIntoparserLogFile("");
				    
				}
				break;
			case 6:
				enterOuterAlt(_localctx, 6);
				{
				setState(378);
				((FactorContext)_localctx).v = variable();
				setState(379);
				match(INCOP);

				        ((FactorContext)_localctx).line =  ((FactorContext)_localctx).v.line;
				        ((FactorContext)_localctx).code =  ((FactorContext)_localctx).v.code + "++";
				        writeIntoparserLogFile("Line " + std::to_string(_localctx.line) + ": factor : variable INCOP");
				        writeIntoparserLogFile("");
				        writeIntoparserLogFile(_localctx.code);
				        writeIntoparserLogFile("");
				    
				}
				break;
			case 7:
				enterOuterAlt(_localctx, 7);
				{
				setState(382);
				((FactorContext)_localctx).v = variable();
				setState(383);
				match(DECOP);

				        ((FactorContext)_localctx).line =  ((FactorContext)_localctx).v.line;
				        ((FactorContext)_localctx).code =  ((FactorContext)_localctx).v.code + "--";
				        writeIntoparserLogFile("Line " + std::to_string(_localctx.line) + ": factor : variable DECOP");
				        writeIntoparserLogFile("");
				        writeIntoparserLogFile(_localctx.code);
				        writeIntoparserLogFile("");
				    
				}
				break;
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class Argument_listContext extends ParserRuleContext {
		public std::string code;
		public ArgumentsContext a;
		public ArgumentsContext arguments() {
			return getRuleContext(ArgumentsContext.class,0);
		}
		public Argument_listContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_argument_list; }
	}

	public final Argument_listContext argument_list() throws RecognitionException {
		Argument_listContext _localctx = new Argument_listContext(_ctx, getState());
		enterRule(_localctx, 44, RULE_argument_list);
		try {
			setState(392);
			_errHandler.sync(this);
			switch (_input.LA(1)) {
			case LPAREN:
			case ADDOP:
			case NOT:
			case ID:
			case CONST_INT:
			case CONST_FLOAT:
				enterOuterAlt(_localctx, 1);
				{
				setState(388);
				((Argument_listContext)_localctx).a = arguments(0);

				        ((Argument_listContext)_localctx).code =  ((Argument_listContext)_localctx).a.code;
				        writeIntoparserLogFile("Line " + std::to_string(((Argument_listContext)_localctx).a.line) + ": argument_list : arguments");
				        writeIntoparserLogFile("");
				        writeIntoparserLogFile(_localctx.code);
				        writeIntoparserLogFile("");
				    
				}
				break;
			case RPAREN:
				enterOuterAlt(_localctx, 2);
				{

				        ((Argument_listContext)_localctx).code =  "";
				        // No logging for empty argument list
				    
				}
				break;
			default:
				throw new NoViableAltException(this);
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	@SuppressWarnings("CheckReturnValue")
	public static class ArgumentsContext extends ParserRuleContext {
		public std::string code;
		public int line;
		public ArgumentsContext a;
		public Logic_expressionContext le;
		public Logic_expressionContext logic_expression() {
			return getRuleContext(Logic_expressionContext.class,0);
		}
		public TerminalNode COMMA() { return getToken(C8086Parser.COMMA, 0); }
		public ArgumentsContext arguments() {
			return getRuleContext(ArgumentsContext.class,0);
		}
		public ArgumentsContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_arguments; }
	}

	public final ArgumentsContext arguments() throws RecognitionException {
		return arguments(0);
	}

	private ArgumentsContext arguments(int _p) throws RecognitionException {
		ParserRuleContext _parentctx = _ctx;
		int _parentState = getState();
		ArgumentsContext _localctx = new ArgumentsContext(_ctx, _parentState);
		ArgumentsContext _prevctx = _localctx;
		int _startState = 46;
		enterRecursionRule(_localctx, 46, RULE_arguments, _p);
		try {
			int _alt;
			enterOuterAlt(_localctx, 1);
			{
			{
			setState(395);
			((ArgumentsContext)_localctx).le = logic_expression();

			        ((ArgumentsContext)_localctx).line =  ((ArgumentsContext)_localctx).le.line;
			        ((ArgumentsContext)_localctx).code =  ((ArgumentsContext)_localctx).le.code;
			        writeIntoparserLogFile("Line " + std::to_string(_localctx.line) + ": arguments : logic_expression");
			        writeIntoparserLogFile("");
			        writeIntoparserLogFile(_localctx.code);
			        writeIntoparserLogFile("");
			    
			}
			_ctx.stop = _input.LT(-1);
			setState(405);
			_errHandler.sync(this);
			_alt = getInterpreter().adaptivePredict(_input,25,_ctx);
			while ( _alt!=2 && _alt!=org.antlr.v4.runtime.atn.ATN.INVALID_ALT_NUMBER ) {
				if ( _alt==1 ) {
					if ( _parseListeners!=null ) triggerExitRuleEvent();
					_prevctx = _localctx;
					{
					{
					_localctx = new ArgumentsContext(_parentctx, _parentState);
					_localctx.a = _prevctx;
					pushNewRecursionContext(_localctx, _startState, RULE_arguments);
					setState(398);
					if (!(precpred(_ctx, 2))) throw new FailedPredicateException(this, "precpred(_ctx, 2)");
					setState(399);
					match(COMMA);
					setState(400);
					((ArgumentsContext)_localctx).le = logic_expression();

					                  ((ArgumentsContext)_localctx).line =  ((ArgumentsContext)_localctx).a.line;
					                  ((ArgumentsContext)_localctx).code =  ((ArgumentsContext)_localctx).a.code + "," + ((ArgumentsContext)_localctx).le.code;
					                  writeIntoparserLogFile("Line " + std::to_string(_localctx.line) + ": arguments : arguments COMMA logic_expression");
					                  writeIntoparserLogFile("");
					                  writeIntoparserLogFile(_localctx.code);
					                  writeIntoparserLogFile("");
					              
					}
					} 
				}
				setState(407);
				_errHandler.sync(this);
				_alt = getInterpreter().adaptivePredict(_input,25,_ctx);
			}
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			unrollRecursionContexts(_parentctx);
		}
		return _localctx;
	}

	public boolean sempred(RuleContext _localctx, int ruleIndex, int predIndex) {
		switch (ruleIndex) {
		case 1:
			return program_sempred((ProgramContext)_localctx, predIndex);
		case 5:
			return parameter_list_sempred((Parameter_listContext)_localctx, predIndex);
		case 10:
			return declaration_list_sempred((Declaration_listContext)_localctx, predIndex);
		case 11:
			return statements_sempred((StatementsContext)_localctx, predIndex);
		case 18:
			return simple_expression_sempred((Simple_expressionContext)_localctx, predIndex);
		case 19:
			return term_sempred((TermContext)_localctx, predIndex);
		case 23:
			return arguments_sempred((ArgumentsContext)_localctx, predIndex);
		}
		return true;
	}
	private boolean program_sempred(ProgramContext _localctx, int predIndex) {
		switch (predIndex) {
		case 0:
			return precpred(_ctx, 2);
		}
		return true;
	}
	private boolean parameter_list_sempred(Parameter_listContext _localctx, int predIndex) {
		switch (predIndex) {
		case 1:
			return precpred(_ctx, 4);
		case 2:
			return precpred(_ctx, 3);
		}
		return true;
	}
	private boolean declaration_list_sempred(Declaration_listContext _localctx, int predIndex) {
		switch (predIndex) {
		case 3:
			return precpred(_ctx, 3);
		case 4:
			return precpred(_ctx, 1);
		}
		return true;
	}
	private boolean statements_sempred(StatementsContext _localctx, int predIndex) {
		switch (predIndex) {
		case 5:
			return precpred(_ctx, 1);
		}
		return true;
	}
	private boolean simple_expression_sempred(Simple_expressionContext _localctx, int predIndex) {
		switch (predIndex) {
		case 6:
			return precpred(_ctx, 1);
		}
		return true;
	}
	private boolean term_sempred(TermContext _localctx, int predIndex) {
		switch (predIndex) {
		case 7:
			return precpred(_ctx, 1);
		}
		return true;
	}
	private boolean arguments_sempred(ArgumentsContext _localctx, int predIndex) {
		switch (predIndex) {
		case 8:
			return precpred(_ctx, 2);
		}
		return true;
	}

	public static final String _serializedATN =
		"\u0004\u0001!\u0199\u0002\u0000\u0007\u0000\u0002\u0001\u0007\u0001\u0002"+
		"\u0002\u0007\u0002\u0002\u0003\u0007\u0003\u0002\u0004\u0007\u0004\u0002"+
		"\u0005\u0007\u0005\u0002\u0006\u0007\u0006\u0002\u0007\u0007\u0007\u0002"+
		"\b\u0007\b\u0002\t\u0007\t\u0002\n\u0007\n\u0002\u000b\u0007\u000b\u0002"+
		"\f\u0007\f\u0002\r\u0007\r\u0002\u000e\u0007\u000e\u0002\u000f\u0007\u000f"+
		"\u0002\u0010\u0007\u0010\u0002\u0011\u0007\u0011\u0002\u0012\u0007\u0012"+
		"\u0002\u0013\u0007\u0013\u0002\u0014\u0007\u0014\u0002\u0015\u0007\u0015"+
		"\u0002\u0016\u0007\u0016\u0002\u0017\u0007\u0017\u0001\u0000\u0001\u0000"+
		"\u0001\u0000\u0001\u0000\u0001\u0001\u0001\u0001\u0001\u0001\u0001\u0001"+
		"\u0001\u0001\u0001\u0001\u0001\u0001\u0001\u0001\u0005\u0001=\b\u0001"+
		"\n\u0001\f\u0001@\t\u0001\u0001\u0002\u0001\u0002\u0001\u0002\u0001\u0002"+
		"\u0001\u0002\u0001\u0002\u0001\u0002\u0001\u0002\u0001\u0002\u0003\u0002"+
		"K\b\u0002\u0001\u0003\u0001\u0003\u0001\u0003\u0001\u0003\u0001\u0003"+
		"\u0001\u0003\u0001\u0003\u0001\u0003\u0001\u0003\u0001\u0003\u0001\u0003"+
		"\u0001\u0003\u0001\u0003\u0001\u0003\u0001\u0003\u0001\u0003\u0001\u0003"+
		"\u0001\u0003\u0001\u0003\u0003\u0003`\b\u0003\u0001\u0004\u0001\u0004"+
		"\u0001\u0004\u0001\u0004\u0001\u0004\u0001\u0004\u0001\u0004\u0001\u0004"+
		"\u0001\u0004\u0001\u0004\u0001\u0004\u0001\u0004\u0001\u0004\u0001\u0004"+
		"\u0001\u0004\u0001\u0004\u0001\u0004\u0001\u0004\u0001\u0004\u0003\u0004"+
		"u\b\u0004\u0001\u0005\u0001\u0005\u0001\u0005\u0001\u0005\u0001\u0005"+
		"\u0001\u0005\u0001\u0005\u0001\u0005\u0003\u0005\u007f\b\u0005\u0001\u0005"+
		"\u0001\u0005\u0001\u0005\u0001\u0005\u0001\u0005\u0001\u0005\u0001\u0005"+
		"\u0001\u0005\u0001\u0005\u0001\u0005\u0001\u0005\u0005\u0005\u008c\b\u0005"+
		"\n\u0005\f\u0005\u008f\t\u0005\u0001\u0006\u0001\u0006\u0001\u0006\u0001"+
		"\u0006\u0001\u0006\u0001\u0006\u0001\u0006\u0001\u0006\u0001\u0006\u0001"+
		"\u0006\u0003\u0006\u009b\b\u0006\u0001\u0007\u0001\u0007\u0001\u0007\u0001"+
		"\u0007\u0001\u0007\u0001\u0007\u0001\u0007\u0001\u0007\u0001\u0007\u0001"+
		"\u0007\u0003\u0007\u00a7\b\u0007\u0001\b\u0001\b\u0001\t\u0001\t\u0001"+
		"\t\u0001\t\u0001\t\u0001\t\u0003\t\u00b1\b\t\u0001\n\u0001\n\u0001\n\u0001"+
		"\n\u0001\n\u0001\n\u0001\n\u0001\n\u0003\n\u00bb\b\n\u0001\n\u0001\n\u0001"+
		"\n\u0001\n\u0001\n\u0001\n\u0001\n\u0001\n\u0001\n\u0001\n\u0001\n\u0005"+
		"\n\u00c8\b\n\n\n\f\n\u00cb\t\n\u0001\u000b\u0001\u000b\u0001\u000b\u0001"+
		"\u000b\u0001\u000b\u0001\u000b\u0001\u000b\u0001\u000b\u0005\u000b\u00d5"+
		"\b\u000b\n\u000b\f\u000b\u00d8\t\u000b\u0001\f\u0001\f\u0001\f\u0001\f"+
		"\u0001\f\u0001\f\u0001\f\u0001\f\u0001\f\u0001\f\u0001\f\u0001\f\u0001"+
		"\f\u0001\f\u0001\f\u0001\f\u0001\f\u0001\f\u0001\f\u0001\f\u0001\f\u0001"+
		"\f\u0001\f\u0001\f\u0001\f\u0001\f\u0001\f\u0001\f\u0001\f\u0001\f\u0001"+
		"\f\u0001\f\u0001\f\u0001\f\u0001\f\u0001\f\u0001\f\u0001\f\u0001\f\u0001"+
		"\f\u0001\f\u0001\f\u0001\f\u0001\f\u0001\f\u0001\f\u0001\f\u0001\f\u0001"+
		"\f\u0001\f\u0001\f\u0001\f\u0003\f\u010e\b\f\u0001\r\u0001\r\u0001\r\u0001"+
		"\r\u0001\r\u0001\r\u0003\r\u0116\b\r\u0001\u000e\u0001\u000e\u0001\u000e"+
		"\u0001\u000e\u0001\u000e\u0001\u000e\u0001\u000e\u0001\u000e\u0003\u000e"+
		"\u0120\b\u000e\u0001\u000f\u0001\u000f\u0001\u000f\u0001\u000f\u0001\u000f"+
		"\u0001\u000f\u0001\u000f\u0001\u000f\u0003\u000f\u012a\b\u000f\u0001\u0010"+
		"\u0001\u0010\u0001\u0010\u0001\u0010\u0001\u0010\u0001\u0010\u0001\u0010"+
		"\u0001\u0010\u0003\u0010\u0134\b\u0010\u0001\u0011\u0001\u0011\u0001\u0011"+
		"\u0001\u0011\u0001\u0011\u0001\u0011\u0001\u0011\u0001\u0011\u0003\u0011"+
		"\u013e\b\u0011\u0001\u0012\u0001\u0012\u0001\u0012\u0001\u0012\u0001\u0012"+
		"\u0001\u0012\u0001\u0012\u0001\u0012\u0001\u0012\u0005\u0012\u0149\b\u0012"+
		"\n\u0012\f\u0012\u014c\t\u0012\u0001\u0013\u0001\u0013\u0001\u0013\u0001"+
		"\u0013\u0001\u0013\u0001\u0013\u0001\u0013\u0001\u0013\u0001\u0013\u0005"+
		"\u0013\u0157\b\u0013\n\u0013\f\u0013\u015a\t\u0013\u0001\u0014\u0001\u0014"+
		"\u0001\u0014\u0001\u0014\u0001\u0014\u0001\u0014\u0001\u0014\u0001\u0014"+
		"\u0001\u0014\u0001\u0014\u0001\u0014\u0003\u0014\u0167\b\u0014\u0001\u0015"+
		"\u0001\u0015\u0001\u0015\u0001\u0015\u0001\u0015\u0001\u0015\u0001\u0015"+
		"\u0001\u0015\u0001\u0015\u0001\u0015\u0001\u0015\u0001\u0015\u0001\u0015"+
		"\u0001\u0015\u0001\u0015\u0001\u0015\u0001\u0015\u0001\u0015\u0001\u0015"+
		"\u0001\u0015\u0001\u0015\u0001\u0015\u0001\u0015\u0001\u0015\u0001\u0015"+
		"\u0001\u0015\u0003\u0015\u0183\b\u0015\u0001\u0016\u0001\u0016\u0001\u0016"+
		"\u0001\u0016\u0003\u0016\u0189\b\u0016\u0001\u0017\u0001\u0017\u0001\u0017"+
		"\u0001\u0017\u0001\u0017\u0001\u0017\u0001\u0017\u0001\u0017\u0001\u0017"+
		"\u0005\u0017\u0194\b\u0017\n\u0017\f\u0017\u0197\t\u0017\u0001\u0017\u0000"+
		"\u0007\u0002\n\u0014\u0016$&.\u0018\u0000\u0002\u0004\u0006\b\n\f\u000e"+
		"\u0010\u0012\u0014\u0016\u0018\u001a\u001c\u001e \"$&(*,.\u0000\u0000"+
		"\u01a9\u00000\u0001\u0000\u0000\u0000\u00024\u0001\u0000\u0000\u0000\u0004"+
		"J\u0001\u0000\u0000\u0000\u0006_\u0001\u0000\u0000\u0000\bt\u0001\u0000"+
		"\u0000\u0000\n~\u0001\u0000\u0000\u0000\f\u009a\u0001\u0000\u0000\u0000"+
		"\u000e\u00a6\u0001\u0000\u0000\u0000\u0010\u00a8\u0001\u0000\u0000\u0000"+
		"\u0012\u00b0\u0001\u0000\u0000\u0000\u0014\u00ba\u0001\u0000\u0000\u0000"+
		"\u0016\u00cc\u0001\u0000\u0000\u0000\u0018\u010d\u0001\u0000\u0000\u0000"+
		"\u001a\u0115\u0001\u0000\u0000\u0000\u001c\u011f\u0001\u0000\u0000\u0000"+
		"\u001e\u0129\u0001\u0000\u0000\u0000 \u0133\u0001\u0000\u0000\u0000\""+
		"\u013d\u0001\u0000\u0000\u0000$\u013f\u0001\u0000\u0000\u0000&\u014d\u0001"+
		"\u0000\u0000\u0000(\u0166\u0001\u0000\u0000\u0000*\u0182\u0001\u0000\u0000"+
		"\u0000,\u0188\u0001\u0000\u0000\u0000.\u018a\u0001\u0000\u0000\u00000"+
		"1\u0006\u0000\uffff\uffff\u000012\u0003\u0002\u0001\u000023\u0006\u0000"+
		"\uffff\uffff\u00003\u0001\u0001\u0000\u0000\u000045\u0006\u0001\uffff"+
		"\uffff\u000056\u0003\u0004\u0002\u000067\u0006\u0001\uffff\uffff\u0000"+
		"7>\u0001\u0000\u0000\u000089\n\u0002\u0000\u00009:\u0003\u0004\u0002\u0000"+
		":;\u0006\u0001\uffff\uffff\u0000;=\u0001\u0000\u0000\u0000<8\u0001\u0000"+
		"\u0000\u0000=@\u0001\u0000\u0000\u0000><\u0001\u0000\u0000\u0000>?\u0001"+
		"\u0000\u0000\u0000?\u0003\u0001\u0000\u0000\u0000@>\u0001\u0000\u0000"+
		"\u0000AB\u0003\u000e\u0007\u0000BC\u0006\u0002\uffff\uffff\u0000CK\u0001"+
		"\u0000\u0000\u0000DE\u0003\u0006\u0003\u0000EF\u0006\u0002\uffff\uffff"+
		"\u0000FK\u0001\u0000\u0000\u0000GH\u0003\b\u0004\u0000HI\u0006\u0002\uffff"+
		"\uffff\u0000IK\u0001\u0000\u0000\u0000JA\u0001\u0000\u0000\u0000JD\u0001"+
		"\u0000\u0000\u0000JG\u0001\u0000\u0000\u0000K\u0005\u0001\u0000\u0000"+
		"\u0000LM\u0003\u0012\t\u0000MN\u0005\u001f\u0000\u0000NO\u0005\u000e\u0000"+
		"\u0000OP\u0006\u0003\uffff\uffff\u0000PQ\u0003\n\u0005\u0000QR\u0006\u0003"+
		"\uffff\uffff\u0000RS\u0005\u000f\u0000\u0000ST\u0005\u0014\u0000\u0000"+
		"TU\u0006\u0003\uffff\uffff\u0000U`\u0001\u0000\u0000\u0000VW\u0003\u0012"+
		"\t\u0000WX\u0005\u001f\u0000\u0000XY\u0005\u000e\u0000\u0000YZ\u0006\u0003"+
		"\uffff\uffff\u0000Z[\u0005\u000f\u0000\u0000[\\\u0006\u0003\uffff\uffff"+
		"\u0000\\]\u0005\u0014\u0000\u0000]^\u0006\u0003\uffff\uffff\u0000^`\u0001"+
		"\u0000\u0000\u0000_L\u0001\u0000\u0000\u0000_V\u0001\u0000\u0000\u0000"+
		"`\u0007\u0001\u0000\u0000\u0000ab\u0003\u0012\t\u0000bc\u0005\u001f\u0000"+
		"\u0000cd\u0006\u0004\uffff\uffff\u0000de\u0005\u000e\u0000\u0000ef\u0006"+
		"\u0004\uffff\uffff\u0000fg\u0003\n\u0005\u0000gh\u0005\u000f\u0000\u0000"+
		"hi\u0003\f\u0006\u0000ij\u0006\u0004\uffff\uffff\u0000ju\u0001\u0000\u0000"+
		"\u0000kl\u0003\u0012\t\u0000lm\u0005\u001f\u0000\u0000mn\u0006\u0004\uffff"+
		"\uffff\u0000no\u0005\u000e\u0000\u0000op\u0006\u0004\uffff\uffff\u0000"+
		"pq\u0005\u000f\u0000\u0000qr\u0003\f\u0006\u0000rs\u0006\u0004\uffff\uffff"+
		"\u0000su\u0001\u0000\u0000\u0000ta\u0001\u0000\u0000\u0000tk\u0001\u0000"+
		"\u0000\u0000u\t\u0001\u0000\u0000\u0000vw\u0006\u0005\uffff\uffff\u0000"+
		"wx\u0003\u0012\t\u0000xy\u0005\u001f\u0000\u0000yz\u0006\u0005\uffff\uffff"+
		"\u0000z\u007f\u0001\u0000\u0000\u0000{|\u0003\u0012\t\u0000|}\u0006\u0005"+
		"\uffff\uffff\u0000}\u007f\u0001\u0000\u0000\u0000~v\u0001\u0000\u0000"+
		"\u0000~{\u0001\u0000\u0000\u0000\u007f\u008d\u0001\u0000\u0000\u0000\u0080"+
		"\u0081\n\u0004\u0000\u0000\u0081\u0082\u0005\u0015\u0000\u0000\u0082\u0083"+
		"\u0003\u0012\t\u0000\u0083\u0084\u0005\u001f\u0000\u0000\u0084\u0085\u0006"+
		"\u0005\uffff\uffff\u0000\u0085\u008c\u0001\u0000\u0000\u0000\u0086\u0087"+
		"\n\u0003\u0000\u0000\u0087\u0088\u0005\u0015\u0000\u0000\u0088\u0089\u0003"+
		"\u0012\t\u0000\u0089\u008a\u0006\u0005\uffff\uffff\u0000\u008a\u008c\u0001"+
		"\u0000\u0000\u0000\u008b\u0080\u0001\u0000\u0000\u0000\u008b\u0086\u0001"+
		"\u0000\u0000\u0000\u008c\u008f\u0001\u0000\u0000\u0000\u008d\u008b\u0001"+
		"\u0000\u0000\u0000\u008d\u008e\u0001\u0000\u0000\u0000\u008e\u000b\u0001"+
		"\u0000\u0000\u0000\u008f\u008d\u0001\u0000\u0000\u0000\u0090\u0091\u0005"+
		"\u0010\u0000\u0000\u0091\u0092\u0006\u0006\uffff\uffff\u0000\u0092\u0093"+
		"\u0003\u0016\u000b\u0000\u0093\u0094\u0005\u0011\u0000\u0000\u0094\u0095"+
		"\u0006\u0006\uffff\uffff\u0000\u0095\u009b\u0001\u0000\u0000\u0000\u0096"+
		"\u0097\u0005\u0010\u0000\u0000\u0097\u0098\u0006\u0006\uffff\uffff\u0000"+
		"\u0098\u0099\u0005\u0011\u0000\u0000\u0099\u009b\u0006\u0006\uffff\uffff"+
		"\u0000\u009a\u0090\u0001\u0000\u0000\u0000\u009a\u0096\u0001\u0000\u0000"+
		"\u0000\u009b\r\u0001\u0000\u0000\u0000\u009c\u009d\u0003\u0012\t\u0000"+
		"\u009d\u009e\u0003\u0014\n\u0000\u009e\u009f\u0005\u0014\u0000\u0000\u009f"+
		"\u00a0\u0006\u0007\uffff\uffff\u0000\u00a0\u00a7\u0001\u0000\u0000\u0000"+
		"\u00a1\u00a2\u0003\u0012\t\u0000\u00a2\u00a3\u0003\u0010\b\u0000\u00a3"+
		"\u00a4\u0005\u0014\u0000\u0000\u00a4\u00a5\u0006\u0007\uffff\uffff\u0000"+
		"\u00a5\u00a7\u0001\u0000\u0000\u0000\u00a6\u009c\u0001\u0000\u0000\u0000"+
		"\u00a6\u00a1\u0001\u0000\u0000\u0000\u00a7\u000f\u0001\u0000\u0000\u0000"+
		"\u00a8\u00a9\u0006\b\uffff\uffff\u0000\u00a9\u0011\u0001\u0000\u0000\u0000"+
		"\u00aa\u00ab\u0005\u000b\u0000\u0000\u00ab\u00b1\u0006\t\uffff\uffff\u0000"+
		"\u00ac\u00ad\u0005\f\u0000\u0000\u00ad\u00b1\u0006\t\uffff\uffff\u0000"+
		"\u00ae\u00af\u0005\r\u0000\u0000\u00af\u00b1\u0006\t\uffff\uffff\u0000"+
		"\u00b0\u00aa\u0001\u0000\u0000\u0000\u00b0\u00ac\u0001\u0000\u0000\u0000"+
		"\u00b0\u00ae\u0001\u0000\u0000\u0000\u00b1\u0013\u0001\u0000\u0000\u0000"+
		"\u00b2\u00b3\u0006\n\uffff\uffff\u0000\u00b3\u00b4\u0005\u001f\u0000\u0000"+
		"\u00b4\u00bb\u0006\n\uffff\uffff\u0000\u00b5\u00b6\u0005\u001f\u0000\u0000"+
		"\u00b6\u00b7\u0005\u0012\u0000\u0000\u00b7\u00b8\u0005 \u0000\u0000\u00b8"+
		"\u00b9\u0005\u0013\u0000\u0000\u00b9\u00bb\u0006\n\uffff\uffff\u0000\u00ba"+
		"\u00b2\u0001\u0000\u0000\u0000\u00ba\u00b5\u0001\u0000\u0000\u0000\u00bb"+
		"\u00c9\u0001\u0000\u0000\u0000\u00bc\u00bd\n\u0003\u0000\u0000\u00bd\u00be"+
		"\u0005\u0015\u0000\u0000\u00be\u00bf\u0005\u001f\u0000\u0000\u00bf\u00c8"+
		"\u0006\n\uffff\uffff\u0000\u00c0\u00c1\n\u0001\u0000\u0000\u00c1\u00c2"+
		"\u0005\u0015\u0000\u0000\u00c2\u00c3\u0005\u001f\u0000\u0000\u00c3\u00c4"+
		"\u0005\u0012\u0000\u0000\u00c4\u00c5\u0005 \u0000\u0000\u00c5\u00c6\u0005"+
		"\u0013\u0000\u0000\u00c6\u00c8\u0006\n\uffff\uffff\u0000\u00c7\u00bc\u0001"+
		"\u0000\u0000\u0000\u00c7\u00c0\u0001\u0000\u0000\u0000\u00c8\u00cb\u0001"+
		"\u0000\u0000\u0000\u00c9\u00c7\u0001\u0000\u0000\u0000\u00c9\u00ca\u0001"+
		"\u0000\u0000\u0000\u00ca\u0015\u0001\u0000\u0000\u0000\u00cb\u00c9\u0001"+
		"\u0000\u0000\u0000\u00cc\u00cd\u0006\u000b\uffff\uffff\u0000\u00cd\u00ce"+
		"\u0003\u0018\f\u0000\u00ce\u00cf\u0006\u000b\uffff\uffff\u0000\u00cf\u00d6"+
		"\u0001\u0000\u0000\u0000\u00d0\u00d1\n\u0001\u0000\u0000\u00d1\u00d2\u0003"+
		"\u0018\f\u0000\u00d2\u00d3\u0006\u000b\uffff\uffff\u0000\u00d3\u00d5\u0001"+
		"\u0000\u0000\u0000\u00d4\u00d0\u0001\u0000\u0000\u0000\u00d5\u00d8\u0001"+
		"\u0000\u0000\u0000\u00d6\u00d4\u0001\u0000\u0000\u0000\u00d6\u00d7\u0001"+
		"\u0000\u0000\u0000\u00d7\u0017\u0001\u0000\u0000\u0000\u00d8\u00d6\u0001"+
		"\u0000\u0000\u0000\u00d9\u00da\u0003\u000e\u0007\u0000\u00da\u00db\u0006"+
		"\f\uffff\uffff\u0000\u00db\u010e\u0001\u0000\u0000\u0000\u00dc\u00dd\u0003"+
		"\u001a\r\u0000\u00dd\u00de\u0006\f\uffff\uffff\u0000\u00de\u010e\u0001"+
		"\u0000\u0000\u0000\u00df\u00e0\u0003\f\u0006\u0000\u00e0\u00e1\u0006\f"+
		"\uffff\uffff\u0000\u00e1\u010e\u0001\u0000\u0000\u0000\u00e2\u00e3\u0005"+
		"\u0007\u0000\u0000\u00e3\u00e4\u0005\u000e\u0000\u0000\u00e4\u00e5\u0003"+
		"\u001a\r\u0000\u00e5\u00e6\u0003\u001a\r\u0000\u00e6\u00e7\u0003\u001e"+
		"\u000f\u0000\u00e7\u00e8\u0005\u000f\u0000\u0000\u00e8\u00e9\u0003\u0018"+
		"\f\u0000\u00e9\u00ea\u0006\f\uffff\uffff\u0000\u00ea\u010e\u0001\u0000"+
		"\u0000\u0000\u00eb\u00ec\u0005\u0005\u0000\u0000\u00ec\u00ed\u0005\u000e"+
		"\u0000\u0000\u00ed\u00ee\u0003\u001e\u000f\u0000\u00ee\u00ef\u0005\u000f"+
		"\u0000\u0000\u00ef\u00f0\u0003\u0018\f\u0000\u00f0\u00f1\u0006\f\uffff"+
		"\uffff\u0000\u00f1\u010e\u0001\u0000\u0000\u0000\u00f2\u00f3\u0005\u0005"+
		"\u0000\u0000\u00f3\u00f4\u0005\u000e\u0000\u0000\u00f4\u00f5\u0003\u001e"+
		"\u000f\u0000\u00f5\u00f6\u0005\u000f\u0000\u0000\u00f6\u00f7\u0003\u0018"+
		"\f\u0000\u00f7\u00f8\u0005\u0006\u0000\u0000\u00f8\u00f9\u0003\u0018\f"+
		"\u0000\u00f9\u00fa\u0006\f\uffff\uffff\u0000\u00fa\u010e\u0001\u0000\u0000"+
		"\u0000\u00fb\u00fc\u0005\b\u0000\u0000\u00fc\u00fd\u0005\u000e\u0000\u0000"+
		"\u00fd\u00fe\u0003\u001e\u000f\u0000\u00fe\u00ff\u0005\u000f\u0000\u0000"+
		"\u00ff\u0100\u0003\u0018\f\u0000\u0100\u0101\u0006\f\uffff\uffff\u0000"+
		"\u0101\u010e\u0001\u0000\u0000\u0000\u0102\u0103\u0005\t\u0000\u0000\u0103"+
		"\u0104\u0005\u000e\u0000\u0000\u0104\u0105\u0005\u001f\u0000\u0000\u0105"+
		"\u0106\u0005\u000f\u0000\u0000\u0106\u0107\u0005\u0014\u0000\u0000\u0107"+
		"\u010e\u0006\f\uffff\uffff\u0000\u0108\u0109\u0005\n\u0000\u0000\u0109"+
		"\u010a\u0003\u001e\u000f\u0000\u010a\u010b\u0005\u0014\u0000\u0000\u010b"+
		"\u010c\u0006\f\uffff\uffff\u0000\u010c\u010e\u0001\u0000\u0000\u0000\u010d"+
		"\u00d9\u0001\u0000\u0000\u0000\u010d\u00dc\u0001\u0000\u0000\u0000\u010d"+
		"\u00df\u0001\u0000\u0000\u0000\u010d\u00e2\u0001\u0000\u0000\u0000\u010d"+
		"\u00eb\u0001\u0000\u0000\u0000\u010d\u00f2\u0001\u0000\u0000\u0000\u010d"+
		"\u00fb\u0001\u0000\u0000\u0000\u010d\u0102\u0001\u0000\u0000\u0000\u010d"+
		"\u0108\u0001\u0000\u0000\u0000\u010e\u0019\u0001\u0000\u0000\u0000\u010f"+
		"\u0110\u0005\u0014\u0000\u0000\u0110\u0116\u0006\r\uffff\uffff\u0000\u0111"+
		"\u0112\u0003\u001e\u000f\u0000\u0112\u0113\u0005\u0014\u0000\u0000\u0113"+
		"\u0114\u0006\r\uffff\uffff\u0000\u0114\u0116\u0001\u0000\u0000\u0000\u0115"+
		"\u010f\u0001\u0000\u0000\u0000\u0115\u0111\u0001\u0000\u0000\u0000\u0116"+
		"\u001b\u0001\u0000\u0000\u0000\u0117\u0118\u0005\u001f\u0000\u0000\u0118"+
		"\u0120\u0006\u000e\uffff\uffff\u0000\u0119\u011a\u0005\u001f\u0000\u0000"+
		"\u011a\u011b\u0005\u0012\u0000\u0000\u011b\u011c\u0003\u001e\u000f\u0000"+
		"\u011c\u011d\u0005\u0013\u0000\u0000\u011d\u011e\u0006\u000e\uffff\uffff"+
		"\u0000\u011e\u0120\u0001\u0000\u0000\u0000\u011f\u0117\u0001\u0000\u0000"+
		"\u0000\u011f\u0119\u0001\u0000\u0000\u0000\u0120\u001d\u0001\u0000\u0000"+
		"\u0000\u0121\u0122\u0003 \u0010\u0000\u0122\u0123\u0006\u000f\uffff\uffff"+
		"\u0000\u0123\u012a\u0001\u0000\u0000\u0000\u0124\u0125\u0003\u001c\u000e"+
		"\u0000\u0125\u0126\u0005\u001e\u0000\u0000\u0126\u0127\u0003 \u0010\u0000"+
		"\u0127\u0128\u0006\u000f\uffff\uffff\u0000\u0128\u012a\u0001\u0000\u0000"+
		"\u0000\u0129\u0121\u0001\u0000\u0000\u0000\u0129\u0124\u0001\u0000\u0000"+
		"\u0000\u012a\u001f\u0001\u0000\u0000\u0000\u012b\u012c\u0003\"\u0011\u0000"+
		"\u012c\u012d\u0006\u0010\uffff\uffff\u0000\u012d\u0134\u0001\u0000\u0000"+
		"\u0000\u012e\u012f\u0003\"\u0011\u0000\u012f\u0130\u0005\u001d\u0000\u0000"+
		"\u0130\u0131\u0003\"\u0011\u0000\u0131\u0132\u0006\u0010\uffff\uffff\u0000"+
		"\u0132\u0134\u0001\u0000\u0000\u0000\u0133\u012b\u0001\u0000\u0000\u0000"+
		"\u0133\u012e\u0001\u0000\u0000\u0000\u0134!\u0001\u0000\u0000\u0000\u0135"+
		"\u0136\u0003$\u0012\u0000\u0136\u0137\u0006\u0011\uffff\uffff\u0000\u0137"+
		"\u013e\u0001\u0000\u0000\u0000\u0138\u0139\u0003$\u0012\u0000\u0139\u013a"+
		"\u0005\u001c\u0000\u0000\u013a\u013b\u0003$\u0012\u0000\u013b\u013c\u0006"+
		"\u0011\uffff\uffff\u0000\u013c\u013e\u0001\u0000\u0000\u0000\u013d\u0135"+
		"\u0001\u0000\u0000\u0000\u013d\u0138\u0001\u0000\u0000\u0000\u013e#\u0001"+
		"\u0000\u0000\u0000\u013f\u0140\u0006\u0012\uffff\uffff\u0000\u0140\u0141"+
		"\u0003&\u0013\u0000\u0141\u0142\u0006\u0012\uffff\uffff\u0000\u0142\u014a"+
		"\u0001\u0000\u0000\u0000\u0143\u0144\n\u0001\u0000\u0000\u0144\u0145\u0005"+
		"\u0016\u0000\u0000\u0145\u0146\u0003&\u0013\u0000\u0146\u0147\u0006\u0012"+
		"\uffff\uffff\u0000\u0147\u0149\u0001\u0000\u0000\u0000\u0148\u0143\u0001"+
		"\u0000\u0000\u0000\u0149\u014c\u0001\u0000\u0000\u0000\u014a\u0148\u0001"+
		"\u0000\u0000\u0000\u014a\u014b\u0001\u0000\u0000\u0000\u014b%\u0001\u0000"+
		"\u0000\u0000\u014c\u014a\u0001\u0000\u0000\u0000\u014d\u014e\u0006\u0013"+
		"\uffff\uffff\u0000\u014e\u014f\u0003(\u0014\u0000\u014f\u0150\u0006\u0013"+
		"\uffff\uffff\u0000\u0150\u0158\u0001\u0000\u0000\u0000\u0151\u0152\n\u0001"+
		"\u0000\u0000\u0152\u0153\u0005\u0018\u0000\u0000\u0153\u0154\u0003(\u0014"+
		"\u0000\u0154\u0155\u0006\u0013\uffff\uffff\u0000\u0155\u0157\u0001\u0000"+
		"\u0000\u0000\u0156\u0151\u0001\u0000\u0000\u0000\u0157\u015a\u0001\u0000"+
		"\u0000\u0000\u0158\u0156\u0001\u0000\u0000\u0000\u0158\u0159\u0001\u0000"+
		"\u0000\u0000\u0159\'\u0001\u0000\u0000\u0000\u015a\u0158\u0001\u0000\u0000"+
		"\u0000\u015b\u015c\u0005\u0016\u0000\u0000\u015c\u015d\u0003(\u0014\u0000"+
		"\u015d\u015e\u0006\u0014\uffff\uffff\u0000\u015e\u0167\u0001\u0000\u0000"+
		"\u0000\u015f\u0160\u0005\u001b\u0000\u0000\u0160\u0161\u0003(\u0014\u0000"+
		"\u0161\u0162\u0006\u0014\uffff\uffff\u0000\u0162\u0167\u0001\u0000\u0000"+
		"\u0000\u0163\u0164\u0003*\u0015\u0000\u0164\u0165\u0006\u0014\uffff\uffff"+
		"\u0000\u0165\u0167\u0001\u0000\u0000\u0000\u0166\u015b\u0001\u0000\u0000"+
		"\u0000\u0166\u015f\u0001\u0000\u0000\u0000\u0166\u0163\u0001\u0000\u0000"+
		"\u0000\u0167)\u0001\u0000\u0000\u0000\u0168\u0169\u0003\u001c\u000e\u0000"+
		"\u0169\u016a\u0006\u0015\uffff\uffff\u0000\u016a\u0183\u0001\u0000\u0000"+
		"\u0000\u016b\u016c\u0005\u001f\u0000\u0000\u016c\u016d\u0005\u000e\u0000"+
		"\u0000\u016d\u016e\u0003,\u0016\u0000\u016e\u016f\u0005\u000f\u0000\u0000"+
		"\u016f\u0170\u0006\u0015\uffff\uffff\u0000\u0170\u0183\u0001\u0000\u0000"+
		"\u0000\u0171\u0172\u0005\u000e\u0000\u0000\u0172\u0173\u0003\u001e\u000f"+
		"\u0000\u0173\u0174\u0005\u000f\u0000\u0000\u0174\u0175\u0006\u0015\uffff"+
		"\uffff\u0000\u0175\u0183\u0001\u0000\u0000\u0000\u0176\u0177\u0005 \u0000"+
		"\u0000\u0177\u0183\u0006\u0015\uffff\uffff\u0000\u0178\u0179\u0005!\u0000"+
		"\u0000\u0179\u0183\u0006\u0015\uffff\uffff\u0000\u017a\u017b\u0003\u001c"+
		"\u000e\u0000\u017b\u017c\u0005\u0019\u0000\u0000\u017c\u017d\u0006\u0015"+
		"\uffff\uffff\u0000\u017d\u0183\u0001\u0000\u0000\u0000\u017e\u017f\u0003"+
		"\u001c\u000e\u0000\u017f\u0180\u0005\u001a\u0000\u0000\u0180\u0181\u0006"+
		"\u0015\uffff\uffff\u0000\u0181\u0183\u0001\u0000\u0000\u0000\u0182\u0168"+
		"\u0001\u0000\u0000\u0000\u0182\u016b\u0001\u0000\u0000\u0000\u0182\u0171"+
		"\u0001\u0000\u0000\u0000\u0182\u0176\u0001\u0000\u0000\u0000\u0182\u0178"+
		"\u0001\u0000\u0000\u0000\u0182\u017a\u0001\u0000\u0000\u0000\u0182\u017e"+
		"\u0001\u0000\u0000\u0000\u0183+\u0001\u0000\u0000\u0000\u0184\u0185\u0003"+
		".\u0017\u0000\u0185\u0186\u0006\u0016\uffff\uffff\u0000\u0186\u0189\u0001"+
		"\u0000\u0000\u0000\u0187\u0189\u0006\u0016\uffff\uffff\u0000\u0188\u0184"+
		"\u0001\u0000\u0000\u0000\u0188\u0187\u0001\u0000\u0000\u0000\u0189-\u0001"+
		"\u0000\u0000\u0000\u018a\u018b\u0006\u0017\uffff\uffff\u0000\u018b\u018c"+
		"\u0003 \u0010\u0000\u018c\u018d\u0006\u0017\uffff\uffff\u0000\u018d\u0195"+
		"\u0001\u0000\u0000\u0000\u018e\u018f\n\u0002\u0000\u0000\u018f\u0190\u0005"+
		"\u0015\u0000\u0000\u0190\u0191\u0003 \u0010\u0000\u0191\u0192\u0006\u0017"+
		"\uffff\uffff\u0000\u0192\u0194\u0001\u0000\u0000\u0000\u0193\u018e\u0001"+
		"\u0000\u0000\u0000\u0194\u0197\u0001\u0000\u0000\u0000\u0195\u0193\u0001"+
		"\u0000\u0000\u0000\u0195\u0196\u0001\u0000\u0000\u0000\u0196/\u0001\u0000"+
		"\u0000\u0000\u0197\u0195\u0001\u0000\u0000\u0000\u001a>J_t~\u008b\u008d"+
		"\u009a\u00a6\u00b0\u00ba\u00c7\u00c9\u00d6\u010d\u0115\u011f\u0129\u0133"+
		"\u013d\u014a\u0158\u0166\u0182\u0188\u0195";
	public static final ATN _ATN =
		new ATNDeserializer().deserialize(_serializedATN.toCharArray());
	static {
		_decisionToDFA = new DFA[_ATN.getNumberOfDecisions()];
		for (int i = 0; i < _ATN.getNumberOfDecisions(); i++) {
			_decisionToDFA[i] = new DFA(_ATN.getDecisionState(i), i);
		}
	}
}