// Generated from /Users/shahirbinzulfikeraorko/workspace/Academia/CSE-310/assignment-3/parser/C8086Lexer.g4 by ANTLR 4.13.1

    #pragma once
    #include <iostream>
    #include <fstream>
    #include <string>

    extern std::ofstream lexLogFile;

import org.antlr.v4.runtime.Lexer;
import org.antlr.v4.runtime.CharStream;
import org.antlr.v4.runtime.Token;
import org.antlr.v4.runtime.TokenStream;
import org.antlr.v4.runtime.*;
import org.antlr.v4.runtime.atn.*;
import org.antlr.v4.runtime.dfa.DFA;
import org.antlr.v4.runtime.misc.*;

@SuppressWarnings({"all", "warnings", "unchecked", "unused", "cast", "CheckReturnValue", "this-escape"})
public class C8086Lexer extends Lexer {
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
	public static String[] channelNames = {
		"DEFAULT_TOKEN_CHANNEL", "HIDDEN"
	};

	public static String[] modeNames = {
		"DEFAULT_MODE"
	};

	private static String[] makeRuleNames() {
		return new String[] {
			"LINE_COMMENT", "BLOCK_COMMENT", "STRING", "WS", "IF", "ELSE", "FOR", 
			"WHILE", "PRINTLN", "RETURN", "INT", "FLOAT", "VOID", "LPAREN", "RPAREN", 
			"LCURL", "RCURL", "LTHIRD", "RTHIRD", "SEMICOLON", "COMMA", "ADDOP", 
			"SUBOP", "MULOP", "INCOP", "DECOP", "NOT", "RELOP", "LOGICOP", "ASSIGNOP", 
			"ID", "CONST_INT", "CONST_FLOAT"
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


	    void writeIntoLexLogFile(const std::string &message) {
	        if (!lexLogFile.is_open()) {
	            lexLogFile.open("lexLogFile.txt", std::ios::app);
	            if (!lexLogFile) {
	                std::cerr << "Error opening lexLogFile.txt" << std::endl;
	                return;
	            }
	        }
	        lexLogFile << message << std::endl;
	        lexLogFile.flush();
	    }


	public C8086Lexer(CharStream input) {
		super(input);
		_interp = new LexerATNSimulator(this,_ATN,_decisionToDFA,_sharedContextCache);
	}

	@Override
	public String getGrammarFileName() { return "C8086Lexer.g4"; }

	@Override
	public String[] getRuleNames() { return ruleNames; }

	@Override
	public String getSerializedATN() { return _serializedATN; }

	@Override
	public String[] getChannelNames() { return channelNames; }

	@Override
	public String[] getModeNames() { return modeNames; }

	@Override
	public ATN getATN() { return _ATN; }

	@Override
	public void action(RuleContext _localctx, int ruleIndex, int actionIndex) {
		switch (ruleIndex) {
		case 0:
			LINE_COMMENT_action((RuleContext)_localctx, actionIndex);
			break;
		case 1:
			BLOCK_COMMENT_action((RuleContext)_localctx, actionIndex);
			break;
		case 2:
			STRING_action((RuleContext)_localctx, actionIndex);
			break;
		case 4:
			IF_action((RuleContext)_localctx, actionIndex);
			break;
		case 5:
			ELSE_action((RuleContext)_localctx, actionIndex);
			break;
		case 6:
			FOR_action((RuleContext)_localctx, actionIndex);
			break;
		case 7:
			WHILE_action((RuleContext)_localctx, actionIndex);
			break;
		case 8:
			PRINTLN_action((RuleContext)_localctx, actionIndex);
			break;
		case 9:
			RETURN_action((RuleContext)_localctx, actionIndex);
			break;
		case 10:
			INT_action((RuleContext)_localctx, actionIndex);
			break;
		case 11:
			FLOAT_action((RuleContext)_localctx, actionIndex);
			break;
		case 12:
			VOID_action((RuleContext)_localctx, actionIndex);
			break;
		case 13:
			LPAREN_action((RuleContext)_localctx, actionIndex);
			break;
		case 14:
			RPAREN_action((RuleContext)_localctx, actionIndex);
			break;
		case 15:
			LCURL_action((RuleContext)_localctx, actionIndex);
			break;
		case 16:
			RCURL_action((RuleContext)_localctx, actionIndex);
			break;
		case 17:
			LTHIRD_action((RuleContext)_localctx, actionIndex);
			break;
		case 18:
			RTHIRD_action((RuleContext)_localctx, actionIndex);
			break;
		case 19:
			SEMICOLON_action((RuleContext)_localctx, actionIndex);
			break;
		case 20:
			COMMA_action((RuleContext)_localctx, actionIndex);
			break;
		case 21:
			ADDOP_action((RuleContext)_localctx, actionIndex);
			break;
		case 22:
			SUBOP_action((RuleContext)_localctx, actionIndex);
			break;
		case 23:
			MULOP_action((RuleContext)_localctx, actionIndex);
			break;
		case 24:
			INCOP_action((RuleContext)_localctx, actionIndex);
			break;
		case 25:
			DECOP_action((RuleContext)_localctx, actionIndex);
			break;
		case 26:
			NOT_action((RuleContext)_localctx, actionIndex);
			break;
		case 27:
			RELOP_action((RuleContext)_localctx, actionIndex);
			break;
		case 28:
			LOGICOP_action((RuleContext)_localctx, actionIndex);
			break;
		case 29:
			ASSIGNOP_action((RuleContext)_localctx, actionIndex);
			break;
		case 30:
			ID_action((RuleContext)_localctx, actionIndex);
			break;
		case 31:
			CONST_INT_action((RuleContext)_localctx, actionIndex);
			break;
		case 32:
			CONST_FLOAT_action((RuleContext)_localctx, actionIndex);
			break;
		}
	}
	private void LINE_COMMENT_action(RuleContext _localctx, int actionIndex) {
		switch (actionIndex) {
		case 0:

			        writeIntoLexLogFile(
			          "Line# " + std::to_string(getLine())
			          + ": Token <SINGLE LINE COMMENT> Lexeme "
			          + getText()
			        );
			    
			break;
		}
	}
	private void BLOCK_COMMENT_action(RuleContext _localctx, int actionIndex) {
		switch (actionIndex) {
		case 1:

			      // extra braces create a new scope for your variables
			      {
			        std::string txt = getText();
			        std::string content = txt.substr(2, txt.size() - 4);
			        writeIntoLexLogFile(
			          "Line# " + std::to_string(getLine())
			          + ": Token <MULTI LINE COMMENT> Lexeme /*"
			          + content + "*/"
			        );
			      }
			    
			break;
		}
	}
	private void STRING_action(RuleContext _localctx, int actionIndex) {
		switch (actionIndex) {
		case 2:

			        writeIntoLexLogFile(
			          "Line# " + std::to_string(getLine())
			          + ": Token <STRING> Lexeme " + getText()
			        );
			    
			break;
		}
	}
	private void IF_action(RuleContext _localctx, int actionIndex) {
		switch (actionIndex) {
		case 3:
			 writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <IF> Lexeme " + getText()); 
			break;
		}
	}
	private void ELSE_action(RuleContext _localctx, int actionIndex) {
		switch (actionIndex) {
		case 4:
			 writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <ELSE> Lexeme " + getText()); 
			break;
		}
	}
	private void FOR_action(RuleContext _localctx, int actionIndex) {
		switch (actionIndex) {
		case 5:
			 writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <FOR> Lexeme " + getText()); 
			break;
		}
	}
	private void WHILE_action(RuleContext _localctx, int actionIndex) {
		switch (actionIndex) {
		case 6:
			 writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <WHILE> Lexeme " + getText()); 
			break;
		}
	}
	private void PRINTLN_action(RuleContext _localctx, int actionIndex) {
		switch (actionIndex) {
		case 7:
			 writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <PRINTLN> Lexeme " + getText()); 
			break;
		}
	}
	private void RETURN_action(RuleContext _localctx, int actionIndex) {
		switch (actionIndex) {
		case 8:
			 writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <RETURN> Lexeme " + getText()); 
			break;
		}
	}
	private void INT_action(RuleContext _localctx, int actionIndex) {
		switch (actionIndex) {
		case 9:
			 writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <INT> Lexeme " + getText()); 
			break;
		}
	}
	private void FLOAT_action(RuleContext _localctx, int actionIndex) {
		switch (actionIndex) {
		case 10:
			 writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <FLOAT> Lexeme " + getText()); 
			break;
		}
	}
	private void VOID_action(RuleContext _localctx, int actionIndex) {
		switch (actionIndex) {
		case 11:
			 writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <VOID> Lexeme " + getText()); 
			break;
		}
	}
	private void LPAREN_action(RuleContext _localctx, int actionIndex) {
		switch (actionIndex) {
		case 12:
			 writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <LPAREN> Lexeme " + getText()); 
			break;
		}
	}
	private void RPAREN_action(RuleContext _localctx, int actionIndex) {
		switch (actionIndex) {
		case 13:
			 writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <RPAREN> Lexeme " + getText()); 
			break;
		}
	}
	private void LCURL_action(RuleContext _localctx, int actionIndex) {
		switch (actionIndex) {
		case 14:
			 writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <LCURL> Lexeme " + getText()); 
			break;
		}
	}
	private void RCURL_action(RuleContext _localctx, int actionIndex) {
		switch (actionIndex) {
		case 15:
			 writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <RCURL> Lexeme " + getText()); 
			break;
		}
	}
	private void LTHIRD_action(RuleContext _localctx, int actionIndex) {
		switch (actionIndex) {
		case 16:
			 writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <LTHIRD> Lexeme " + getText()); 
			break;
		}
	}
	private void RTHIRD_action(RuleContext _localctx, int actionIndex) {
		switch (actionIndex) {
		case 17:
			 writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <RTHIRD> Lexeme " + getText()); 
			break;
		}
	}
	private void SEMICOLON_action(RuleContext _localctx, int actionIndex) {
		switch (actionIndex) {
		case 18:
			 writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <SEMICOLON> Lexeme " + getText()); 
			break;
		}
	}
	private void COMMA_action(RuleContext _localctx, int actionIndex) {
		switch (actionIndex) {
		case 19:
			 writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <COMMA> Lexeme " + getText()); 
			break;
		}
	}
	private void ADDOP_action(RuleContext _localctx, int actionIndex) {
		switch (actionIndex) {
		case 20:
			 writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <ADDOP> Lexeme " + getText()); 
			break;
		}
	}
	private void SUBOP_action(RuleContext _localctx, int actionIndex) {
		switch (actionIndex) {
		case 21:
			 writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <SUBOP> Lexeme " + getText()); 
			break;
		}
	}
	private void MULOP_action(RuleContext _localctx, int actionIndex) {
		switch (actionIndex) {
		case 22:
			 writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <MULOP> Lexeme " + getText()); 
			break;
		}
	}
	private void INCOP_action(RuleContext _localctx, int actionIndex) {
		switch (actionIndex) {
		case 23:
			 writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <INCOP> Lexeme " + getText()); 
			break;
		}
	}
	private void DECOP_action(RuleContext _localctx, int actionIndex) {
		switch (actionIndex) {
		case 24:
			 writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <DECOP> Lexeme " + getText()); 
			break;
		}
	}
	private void NOT_action(RuleContext _localctx, int actionIndex) {
		switch (actionIndex) {
		case 25:
			 writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <NOT> Lexeme " + getText()); 
			break;
		}
	}
	private void RELOP_action(RuleContext _localctx, int actionIndex) {
		switch (actionIndex) {
		case 26:
			 writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <RELOP> Lexeme " + getText()); 
			break;
		}
	}
	private void LOGICOP_action(RuleContext _localctx, int actionIndex) {
		switch (actionIndex) {
		case 27:
			 writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <LOGICOP> Lexeme " + getText()); 
			break;
		}
	}
	private void ASSIGNOP_action(RuleContext _localctx, int actionIndex) {
		switch (actionIndex) {
		case 28:
			 writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <ASSIGNOP> Lexeme " + getText()); 
			break;
		}
	}
	private void ID_action(RuleContext _localctx, int actionIndex) {
		switch (actionIndex) {
		case 29:
			 writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <ID> Lexeme " + getText()); 
			break;
		}
	}
	private void CONST_INT_action(RuleContext _localctx, int actionIndex) {
		switch (actionIndex) {
		case 30:
			 writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <CONST_INT> Lexeme " + getText()); 
			break;
		}
	}
	private void CONST_FLOAT_action(RuleContext _localctx, int actionIndex) {
		switch (actionIndex) {
		case 31:

			        writeIntoLexLogFile(
			          "Line# " + std::to_string(getLine())
			          + ": Token <CONST_FLOAT> Lexeme " + getText()
			        );
			    
			break;
		case 32:

			        writeIntoLexLogFile(
			          "Line# " + std::to_string(getLine())
			          + ": Token <CONST_FLOAT> Lexeme " + getText()
			        );
			    
			break;
		case 33:

			        writeIntoLexLogFile(
			          "Line# " + std::to_string(getLine())
			          + ": Token <CONST_FLOAT> Lexeme " + getText()
			        );
			    
			break;
		}
	}

	public static final String _serializedATN =
		"\u0004\u0000!\u0138\u0006\uffff\uffff\u0002\u0000\u0007\u0000\u0002\u0001"+
		"\u0007\u0001\u0002\u0002\u0007\u0002\u0002\u0003\u0007\u0003\u0002\u0004"+
		"\u0007\u0004\u0002\u0005\u0007\u0005\u0002\u0006\u0007\u0006\u0002\u0007"+
		"\u0007\u0007\u0002\b\u0007\b\u0002\t\u0007\t\u0002\n\u0007\n\u0002\u000b"+
		"\u0007\u000b\u0002\f\u0007\f\u0002\r\u0007\r\u0002\u000e\u0007\u000e\u0002"+
		"\u000f\u0007\u000f\u0002\u0010\u0007\u0010\u0002\u0011\u0007\u0011\u0002"+
		"\u0012\u0007\u0012\u0002\u0013\u0007\u0013\u0002\u0014\u0007\u0014\u0002"+
		"\u0015\u0007\u0015\u0002\u0016\u0007\u0016\u0002\u0017\u0007\u0017\u0002"+
		"\u0018\u0007\u0018\u0002\u0019\u0007\u0019\u0002\u001a\u0007\u001a\u0002"+
		"\u001b\u0007\u001b\u0002\u001c\u0007\u001c\u0002\u001d\u0007\u001d\u0002"+
		"\u001e\u0007\u001e\u0002\u001f\u0007\u001f\u0002 \u0007 \u0001\u0000\u0001"+
		"\u0000\u0001\u0000\u0001\u0000\u0005\u0000H\b\u0000\n\u0000\f\u0000K\t"+
		"\u0000\u0001\u0000\u0001\u0000\u0001\u0000\u0001\u0000\u0001\u0001\u0001"+
		"\u0001\u0001\u0001\u0001\u0001\u0001\u0001\u0005\u0001V\b\u0001\n\u0001"+
		"\f\u0001Y\t\u0001\u0001\u0001\u0001\u0001\u0001\u0001\u0001\u0001\u0001"+
		"\u0001\u0001\u0001\u0001\u0001\u0001\u0002\u0001\u0002\u0001\u0002\u0001"+
		"\u0002\u0005\u0002f\b\u0002\n\u0002\f\u0002i\t\u0002\u0001\u0002\u0001"+
		"\u0002\u0001\u0002\u0001\u0002\u0001\u0002\u0001\u0003\u0004\u0003q\b"+
		"\u0003\u000b\u0003\f\u0003r\u0001\u0003\u0001\u0003\u0001\u0004\u0001"+
		"\u0004\u0001\u0004\u0001\u0004\u0001\u0004\u0001\u0005\u0001\u0005\u0001"+
		"\u0005\u0001\u0005\u0001\u0005\u0001\u0005\u0001\u0005\u0001\u0006\u0001"+
		"\u0006\u0001\u0006\u0001\u0006\u0001\u0006\u0001\u0006\u0001\u0007\u0001"+
		"\u0007\u0001\u0007\u0001\u0007\u0001\u0007\u0001\u0007\u0001\u0007\u0001"+
		"\u0007\u0001\b\u0001\b\u0001\b\u0001\b\u0001\b\u0001\b\u0001\b\u0001\b"+
		"\u0001\b\u0001\b\u0001\t\u0001\t\u0001\t\u0001\t\u0001\t\u0001\t\u0001"+
		"\t\u0001\t\u0001\t\u0001\n\u0001\n\u0001\n\u0001\n\u0001\n\u0001\n\u0001"+
		"\u000b\u0001\u000b\u0001\u000b\u0001\u000b\u0001\u000b\u0001\u000b\u0001"+
		"\u000b\u0001\u000b\u0001\f\u0001\f\u0001\f\u0001\f\u0001\f\u0001\f\u0001"+
		"\f\u0001\r\u0001\r\u0001\r\u0001\u000e\u0001\u000e\u0001\u000e\u0001\u000f"+
		"\u0001\u000f\u0001\u000f\u0001\u0010\u0001\u0010\u0001\u0010\u0001\u0011"+
		"\u0001\u0011\u0001\u0011\u0001\u0012\u0001\u0012\u0001\u0012\u0001\u0013"+
		"\u0001\u0013\u0001\u0013\u0001\u0014\u0001\u0014\u0001\u0014\u0001\u0015"+
		"\u0001\u0015\u0001\u0015\u0001\u0016\u0001\u0016\u0001\u0016\u0001\u0017"+
		"\u0001\u0017\u0001\u0017\u0001\u0018\u0001\u0018\u0001\u0018\u0001\u0018"+
		"\u0001\u0018\u0001\u0019\u0001\u0019\u0001\u0019\u0001\u0019\u0001\u0019"+
		"\u0001\u001a\u0001\u001a\u0001\u001a\u0001\u001b\u0001\u001b\u0001\u001b"+
		"\u0001\u001b\u0001\u001b\u0001\u001b\u0001\u001b\u0001\u001b\u0001\u001b"+
		"\u0001\u001b\u0001\u001b\u0003\u001b\u00f2\b\u001b\u0001\u001c\u0001\u001c"+
		"\u0001\u001c\u0001\u001c\u0001\u001c\u0001\u001c\u0003\u001c\u00fa\b\u001c"+
		"\u0001\u001d\u0001\u001d\u0001\u001d\u0001\u001e\u0001\u001e\u0005\u001e"+
		"\u0101\b\u001e\n\u001e\f\u001e\u0104\t\u001e\u0001\u001e\u0001\u001e\u0001"+
		"\u001f\u0004\u001f\u0109\b\u001f\u000b\u001f\f\u001f\u010a\u0001\u001f"+
		"\u0001\u001f\u0001 \u0004 \u0110\b \u000b \f \u0111\u0001 \u0001 \u0005"+
		" \u0116\b \n \f \u0119\t \u0003 \u011b\b \u0001 \u0001 \u0003 \u011f\b"+
		" \u0001 \u0004 \u0122\b \u000b \f \u0123\u0003 \u0126\b \u0001 \u0001"+
		" \u0001 \u0004 \u012b\b \u000b \f \u012c\u0001 \u0001 \u0004 \u0131\b"+
		" \u000b \f \u0132\u0001 \u0001 \u0003 \u0137\b \u0001W\u0000!\u0001\u0001"+
		"\u0003\u0002\u0005\u0003\u0007\u0004\t\u0005\u000b\u0006\r\u0007\u000f"+
		"\b\u0011\t\u0013\n\u0015\u000b\u0017\f\u0019\r\u001b\u000e\u001d\u000f"+
		"\u001f\u0010!\u0011#\u0012%\u0013\'\u0014)\u0015+\u0016-\u0017/\u0018"+
		"1\u00193\u001a5\u001b7\u001c9\u001d;\u001e=\u001f? A!\u0001\u0000\n\u0002"+
		"\u0000\n\n\r\r\u0004\u0000\n\n\r\r\"\"\\\\\u0003\u0000\t\n\f\r  \u0002"+
		"\u0000++--\u0003\u0000%%**//\u0002\u0000<<>>\u0003\u0000AZ__az\u0004\u0000"+
		"09AZ__az\u0001\u000009\u0002\u0000EEee\u014e\u0000\u0001\u0001\u0000\u0000"+
		"\u0000\u0000\u0003\u0001\u0000\u0000\u0000\u0000\u0005\u0001\u0000\u0000"+
		"\u0000\u0000\u0007\u0001\u0000\u0000\u0000\u0000\t\u0001\u0000\u0000\u0000"+
		"\u0000\u000b\u0001\u0000\u0000\u0000\u0000\r\u0001\u0000\u0000\u0000\u0000"+
		"\u000f\u0001\u0000\u0000\u0000\u0000\u0011\u0001\u0000\u0000\u0000\u0000"+
		"\u0013\u0001\u0000\u0000\u0000\u0000\u0015\u0001\u0000\u0000\u0000\u0000"+
		"\u0017\u0001\u0000\u0000\u0000\u0000\u0019\u0001\u0000\u0000\u0000\u0000"+
		"\u001b\u0001\u0000\u0000\u0000\u0000\u001d\u0001\u0000\u0000\u0000\u0000"+
		"\u001f\u0001\u0000\u0000\u0000\u0000!\u0001\u0000\u0000\u0000\u0000#\u0001"+
		"\u0000\u0000\u0000\u0000%\u0001\u0000\u0000\u0000\u0000\'\u0001\u0000"+
		"\u0000\u0000\u0000)\u0001\u0000\u0000\u0000\u0000+\u0001\u0000\u0000\u0000"+
		"\u0000-\u0001\u0000\u0000\u0000\u0000/\u0001\u0000\u0000\u0000\u00001"+
		"\u0001\u0000\u0000\u0000\u00003\u0001\u0000\u0000\u0000\u00005\u0001\u0000"+
		"\u0000\u0000\u00007\u0001\u0000\u0000\u0000\u00009\u0001\u0000\u0000\u0000"+
		"\u0000;\u0001\u0000\u0000\u0000\u0000=\u0001\u0000\u0000\u0000\u0000?"+
		"\u0001\u0000\u0000\u0000\u0000A\u0001\u0000\u0000\u0000\u0001C\u0001\u0000"+
		"\u0000\u0000\u0003P\u0001\u0000\u0000\u0000\u0005a\u0001\u0000\u0000\u0000"+
		"\u0007p\u0001\u0000\u0000\u0000\tv\u0001\u0000\u0000\u0000\u000b{\u0001"+
		"\u0000\u0000\u0000\r\u0082\u0001\u0000\u0000\u0000\u000f\u0088\u0001\u0000"+
		"\u0000\u0000\u0011\u0090\u0001\u0000\u0000\u0000\u0013\u009a\u0001\u0000"+
		"\u0000\u0000\u0015\u00a3\u0001\u0000\u0000\u0000\u0017\u00a9\u0001\u0000"+
		"\u0000\u0000\u0019\u00b1\u0001\u0000\u0000\u0000\u001b\u00b8\u0001\u0000"+
		"\u0000\u0000\u001d\u00bb\u0001\u0000\u0000\u0000\u001f\u00be\u0001\u0000"+
		"\u0000\u0000!\u00c1\u0001\u0000\u0000\u0000#\u00c4\u0001\u0000\u0000\u0000"+
		"%\u00c7\u0001\u0000\u0000\u0000\'\u00ca\u0001\u0000\u0000\u0000)\u00cd"+
		"\u0001\u0000\u0000\u0000+\u00d0\u0001\u0000\u0000\u0000-\u00d3\u0001\u0000"+
		"\u0000\u0000/\u00d6\u0001\u0000\u0000\u00001\u00d9\u0001\u0000\u0000\u0000"+
		"3\u00de\u0001\u0000\u0000\u00005\u00e3\u0001\u0000\u0000\u00007\u00f1"+
		"\u0001\u0000\u0000\u00009\u00f9\u0001\u0000\u0000\u0000;\u00fb\u0001\u0000"+
		"\u0000\u0000=\u00fe\u0001\u0000\u0000\u0000?\u0108\u0001\u0000\u0000\u0000"+
		"A\u0136\u0001\u0000\u0000\u0000CD\u0005/\u0000\u0000DE\u0005/\u0000\u0000"+
		"EI\u0001\u0000\u0000\u0000FH\b\u0000\u0000\u0000GF\u0001\u0000\u0000\u0000"+
		"HK\u0001\u0000\u0000\u0000IG\u0001\u0000\u0000\u0000IJ\u0001\u0000\u0000"+
		"\u0000JL\u0001\u0000\u0000\u0000KI\u0001\u0000\u0000\u0000LM\u0006\u0000"+
		"\u0000\u0000MN\u0001\u0000\u0000\u0000NO\u0006\u0000\u0001\u0000O\u0002"+
		"\u0001\u0000\u0000\u0000PQ\u0005/\u0000\u0000QR\u0005*\u0000\u0000RW\u0001"+
		"\u0000\u0000\u0000SV\t\u0000\u0000\u0000TV\u0007\u0000\u0000\u0000US\u0001"+
		"\u0000\u0000\u0000UT\u0001\u0000\u0000\u0000VY\u0001\u0000\u0000\u0000"+
		"WX\u0001\u0000\u0000\u0000WU\u0001\u0000\u0000\u0000XZ\u0001\u0000\u0000"+
		"\u0000YW\u0001\u0000\u0000\u0000Z[\u0005*\u0000\u0000[\\\u0005/\u0000"+
		"\u0000\\]\u0001\u0000\u0000\u0000]^\u0006\u0001\u0002\u0000^_\u0001\u0000"+
		"\u0000\u0000_`\u0006\u0001\u0001\u0000`\u0004\u0001\u0000\u0000\u0000"+
		"ag\u0005\"\u0000\u0000bc\u0005\\\u0000\u0000cf\t\u0000\u0000\u0000df\b"+
		"\u0001\u0000\u0000eb\u0001\u0000\u0000\u0000ed\u0001\u0000\u0000\u0000"+
		"fi\u0001\u0000\u0000\u0000ge\u0001\u0000\u0000\u0000gh\u0001\u0000\u0000"+
		"\u0000hj\u0001\u0000\u0000\u0000ig\u0001\u0000\u0000\u0000jk\u0005\"\u0000"+
		"\u0000kl\u0006\u0002\u0003\u0000lm\u0001\u0000\u0000\u0000mn\u0006\u0002"+
		"\u0001\u0000n\u0006\u0001\u0000\u0000\u0000oq\u0007\u0002\u0000\u0000"+
		"po\u0001\u0000\u0000\u0000qr\u0001\u0000\u0000\u0000rp\u0001\u0000\u0000"+
		"\u0000rs\u0001\u0000\u0000\u0000st\u0001\u0000\u0000\u0000tu\u0006\u0003"+
		"\u0001\u0000u\b\u0001\u0000\u0000\u0000vw\u0005i\u0000\u0000wx\u0005f"+
		"\u0000\u0000xy\u0001\u0000\u0000\u0000yz\u0006\u0004\u0004\u0000z\n\u0001"+
		"\u0000\u0000\u0000{|\u0005e\u0000\u0000|}\u0005l\u0000\u0000}~\u0005s"+
		"\u0000\u0000~\u007f\u0005e\u0000\u0000\u007f\u0080\u0001\u0000\u0000\u0000"+
		"\u0080\u0081\u0006\u0005\u0005\u0000\u0081\f\u0001\u0000\u0000\u0000\u0082"+
		"\u0083\u0005f\u0000\u0000\u0083\u0084\u0005o\u0000\u0000\u0084\u0085\u0005"+
		"r\u0000\u0000\u0085\u0086\u0001\u0000\u0000\u0000\u0086\u0087\u0006\u0006"+
		"\u0006\u0000\u0087\u000e\u0001\u0000\u0000\u0000\u0088\u0089\u0005w\u0000"+
		"\u0000\u0089\u008a\u0005h\u0000\u0000\u008a\u008b\u0005i\u0000\u0000\u008b"+
		"\u008c\u0005l\u0000\u0000\u008c\u008d\u0005e\u0000\u0000\u008d\u008e\u0001"+
		"\u0000\u0000\u0000\u008e\u008f\u0006\u0007\u0007\u0000\u008f\u0010\u0001"+
		"\u0000\u0000\u0000\u0090\u0091\u0005p\u0000\u0000\u0091\u0092\u0005r\u0000"+
		"\u0000\u0092\u0093\u0005i\u0000\u0000\u0093\u0094\u0005n\u0000\u0000\u0094"+
		"\u0095\u0005t\u0000\u0000\u0095\u0096\u0005l\u0000\u0000\u0096\u0097\u0005"+
		"n\u0000\u0000\u0097\u0098\u0001\u0000\u0000\u0000\u0098\u0099\u0006\b"+
		"\b\u0000\u0099\u0012\u0001\u0000\u0000\u0000\u009a\u009b\u0005r\u0000"+
		"\u0000\u009b\u009c\u0005e\u0000\u0000\u009c\u009d\u0005t\u0000\u0000\u009d"+
		"\u009e\u0005u\u0000\u0000\u009e\u009f\u0005r\u0000\u0000\u009f\u00a0\u0005"+
		"n\u0000\u0000\u00a0\u00a1\u0001\u0000\u0000\u0000\u00a1\u00a2\u0006\t"+
		"\t\u0000\u00a2\u0014\u0001\u0000\u0000\u0000\u00a3\u00a4\u0005i\u0000"+
		"\u0000\u00a4\u00a5\u0005n\u0000\u0000\u00a5\u00a6\u0005t\u0000\u0000\u00a6"+
		"\u00a7\u0001\u0000\u0000\u0000\u00a7\u00a8\u0006\n\n\u0000\u00a8\u0016"+
		"\u0001\u0000\u0000\u0000\u00a9\u00aa\u0005f\u0000\u0000\u00aa\u00ab\u0005"+
		"l\u0000\u0000\u00ab\u00ac\u0005o\u0000\u0000\u00ac\u00ad\u0005a\u0000"+
		"\u0000\u00ad\u00ae\u0005t\u0000\u0000\u00ae\u00af\u0001\u0000\u0000\u0000"+
		"\u00af\u00b0\u0006\u000b\u000b\u0000\u00b0\u0018\u0001\u0000\u0000\u0000"+
		"\u00b1\u00b2\u0005v\u0000\u0000\u00b2\u00b3\u0005o\u0000\u0000\u00b3\u00b4"+
		"\u0005i\u0000\u0000\u00b4\u00b5\u0005d\u0000\u0000\u00b5\u00b6\u0001\u0000"+
		"\u0000\u0000\u00b6\u00b7\u0006\f\f\u0000\u00b7\u001a\u0001\u0000\u0000"+
		"\u0000\u00b8\u00b9\u0005(\u0000\u0000\u00b9\u00ba\u0006\r\r\u0000\u00ba"+
		"\u001c\u0001\u0000\u0000\u0000\u00bb\u00bc\u0005)\u0000\u0000\u00bc\u00bd"+
		"\u0006\u000e\u000e\u0000\u00bd\u001e\u0001\u0000\u0000\u0000\u00be\u00bf"+
		"\u0005{\u0000\u0000\u00bf\u00c0\u0006\u000f\u000f\u0000\u00c0 \u0001\u0000"+
		"\u0000\u0000\u00c1\u00c2\u0005}\u0000\u0000\u00c2\u00c3\u0006\u0010\u0010"+
		"\u0000\u00c3\"\u0001\u0000\u0000\u0000\u00c4\u00c5\u0005[\u0000\u0000"+
		"\u00c5\u00c6\u0006\u0011\u0011\u0000\u00c6$\u0001\u0000\u0000\u0000\u00c7"+
		"\u00c8\u0005]\u0000\u0000\u00c8\u00c9\u0006\u0012\u0012\u0000\u00c9&\u0001"+
		"\u0000\u0000\u0000\u00ca\u00cb\u0005;\u0000\u0000\u00cb\u00cc\u0006\u0013"+
		"\u0013\u0000\u00cc(\u0001\u0000\u0000\u0000\u00cd\u00ce\u0005,\u0000\u0000"+
		"\u00ce\u00cf\u0006\u0014\u0014\u0000\u00cf*\u0001\u0000\u0000\u0000\u00d0"+
		"\u00d1\u0007\u0003\u0000\u0000\u00d1\u00d2\u0006\u0015\u0015\u0000\u00d2"+
		",\u0001\u0000\u0000\u0000\u00d3\u00d4\u0007\u0003\u0000\u0000\u00d4\u00d5"+
		"\u0006\u0016\u0016\u0000\u00d5.\u0001\u0000\u0000\u0000\u00d6\u00d7\u0007"+
		"\u0004\u0000\u0000\u00d7\u00d8\u0006\u0017\u0017\u0000\u00d80\u0001\u0000"+
		"\u0000\u0000\u00d9\u00da\u0005+\u0000\u0000\u00da\u00db\u0005+\u0000\u0000"+
		"\u00db\u00dc\u0001\u0000\u0000\u0000\u00dc\u00dd\u0006\u0018\u0018\u0000"+
		"\u00dd2\u0001\u0000\u0000\u0000\u00de\u00df\u0005-\u0000\u0000\u00df\u00e0"+
		"\u0005-\u0000\u0000\u00e0\u00e1\u0001\u0000\u0000\u0000\u00e1\u00e2\u0006"+
		"\u0019\u0019\u0000\u00e24\u0001\u0000\u0000\u0000\u00e3\u00e4\u0005!\u0000"+
		"\u0000\u00e4\u00e5\u0006\u001a\u001a\u0000\u00e56\u0001\u0000\u0000\u0000"+
		"\u00e6\u00e7\u0005<\u0000\u0000\u00e7\u00f2\u0005=\u0000\u0000\u00e8\u00e9"+
		"\u0005=\u0000\u0000\u00e9\u00f2\u0005=\u0000\u0000\u00ea\u00eb\u0005>"+
		"\u0000\u0000\u00eb\u00f2\u0005=\u0000\u0000\u00ec\u00f2\u0007\u0005\u0000"+
		"\u0000\u00ed\u00ee\u0005!\u0000\u0000\u00ee\u00ef\u0005=\u0000\u0000\u00ef"+
		"\u00f0\u0001\u0000\u0000\u0000\u00f0\u00f2\u0006\u001b\u001b\u0000\u00f1"+
		"\u00e6\u0001\u0000\u0000\u0000\u00f1\u00e8\u0001\u0000\u0000\u0000\u00f1"+
		"\u00ea\u0001\u0000\u0000\u0000\u00f1\u00ec\u0001\u0000\u0000\u0000\u00f1"+
		"\u00ed\u0001\u0000\u0000\u0000\u00f28\u0001\u0000\u0000\u0000\u00f3\u00f4"+
		"\u0005&\u0000\u0000\u00f4\u00fa\u0005&\u0000\u0000\u00f5\u00f6\u0005|"+
		"\u0000\u0000\u00f6\u00f7\u0005|\u0000\u0000\u00f7\u00f8\u0001\u0000\u0000"+
		"\u0000\u00f8\u00fa\u0006\u001c\u001c\u0000\u00f9\u00f3\u0001\u0000\u0000"+
		"\u0000\u00f9\u00f5\u0001\u0000\u0000\u0000\u00fa:\u0001\u0000\u0000\u0000"+
		"\u00fb\u00fc\u0005=\u0000\u0000\u00fc\u00fd\u0006\u001d\u001d\u0000\u00fd"+
		"<\u0001\u0000\u0000\u0000\u00fe\u0102\u0007\u0006\u0000\u0000\u00ff\u0101"+
		"\u0007\u0007\u0000\u0000\u0100\u00ff\u0001\u0000\u0000\u0000\u0101\u0104"+
		"\u0001\u0000\u0000\u0000\u0102\u0100\u0001\u0000\u0000\u0000\u0102\u0103"+
		"\u0001\u0000\u0000\u0000\u0103\u0105\u0001\u0000\u0000\u0000\u0104\u0102"+
		"\u0001\u0000\u0000\u0000\u0105\u0106\u0006\u001e\u001e\u0000\u0106>\u0001"+
		"\u0000\u0000\u0000\u0107\u0109\u0007\b\u0000\u0000\u0108\u0107\u0001\u0000"+
		"\u0000\u0000\u0109\u010a\u0001\u0000\u0000\u0000\u010a\u0108\u0001\u0000"+
		"\u0000\u0000\u010a\u010b\u0001\u0000\u0000\u0000\u010b\u010c\u0001\u0000"+
		"\u0000\u0000\u010c\u010d\u0006\u001f\u001f\u0000\u010d@\u0001\u0000\u0000"+
		"\u0000\u010e\u0110\u0007\b\u0000\u0000\u010f\u010e\u0001\u0000\u0000\u0000"+
		"\u0110\u0111\u0001\u0000\u0000\u0000\u0111\u010f\u0001\u0000\u0000\u0000"+
		"\u0111\u0112\u0001\u0000\u0000\u0000\u0112\u011a\u0001\u0000\u0000\u0000"+
		"\u0113\u0117\u0005.\u0000\u0000\u0114\u0116\u0007\b\u0000\u0000\u0115"+
		"\u0114\u0001\u0000\u0000\u0000\u0116\u0119\u0001\u0000\u0000\u0000\u0117"+
		"\u0115\u0001\u0000\u0000\u0000\u0117\u0118\u0001\u0000\u0000\u0000\u0118"+
		"\u011b\u0001\u0000\u0000\u0000\u0119\u0117\u0001\u0000\u0000\u0000\u011a"+
		"\u0113\u0001\u0000\u0000\u0000\u011a\u011b\u0001\u0000\u0000\u0000\u011b"+
		"\u0125\u0001\u0000\u0000\u0000\u011c\u011e\u0007\t\u0000\u0000\u011d\u011f"+
		"\u0007\u0003\u0000\u0000\u011e\u011d\u0001\u0000\u0000\u0000\u011e\u011f"+
		"\u0001\u0000\u0000\u0000\u011f\u0121\u0001\u0000\u0000\u0000\u0120\u0122"+
		"\u0007\b\u0000\u0000\u0121\u0120\u0001\u0000\u0000\u0000\u0122\u0123\u0001"+
		"\u0000\u0000\u0000\u0123\u0121\u0001\u0000\u0000\u0000\u0123\u0124\u0001"+
		"\u0000\u0000\u0000\u0124\u0126\u0001\u0000\u0000\u0000\u0125\u011c\u0001"+
		"\u0000\u0000\u0000\u0125\u0126\u0001\u0000\u0000\u0000\u0126\u0127\u0001"+
		"\u0000\u0000\u0000\u0127\u0137\u0006  \u0000\u0128\u012a\u0005.\u0000"+
		"\u0000\u0129\u012b\u0007\b\u0000\u0000\u012a\u0129\u0001\u0000\u0000\u0000"+
		"\u012b\u012c\u0001\u0000\u0000\u0000\u012c\u012a\u0001\u0000\u0000\u0000"+
		"\u012c\u012d\u0001\u0000\u0000\u0000\u012d\u012e\u0001\u0000\u0000\u0000"+
		"\u012e\u0137\u0006 !\u0000\u012f\u0131\u0007\b\u0000\u0000\u0130\u012f"+
		"\u0001\u0000\u0000\u0000\u0131\u0132\u0001\u0000\u0000\u0000\u0132\u0130"+
		"\u0001\u0000\u0000\u0000\u0132\u0133\u0001\u0000\u0000\u0000\u0133\u0134"+
		"\u0001\u0000\u0000\u0000\u0134\u0135\u0005.\u0000\u0000\u0135\u0137\u0006"+
		" \"\u0000\u0136\u010f\u0001\u0000\u0000\u0000\u0136\u0128\u0001\u0000"+
		"\u0000\u0000\u0136\u0130\u0001\u0000\u0000\u0000\u0137B\u0001\u0000\u0000"+
		"\u0000\u0014\u0000IUWegr\u00f1\u00f9\u0102\u010a\u0111\u0117\u011a\u011e"+
		"\u0123\u0125\u012c\u0132\u0136#\u0001\u0000\u0000\u0006\u0000\u0000\u0001"+
		"\u0001\u0001\u0001\u0002\u0002\u0001\u0004\u0003\u0001\u0005\u0004\u0001"+
		"\u0006\u0005\u0001\u0007\u0006\u0001\b\u0007\u0001\t\b\u0001\n\t\u0001"+
		"\u000b\n\u0001\f\u000b\u0001\r\f\u0001\u000e\r\u0001\u000f\u000e\u0001"+
		"\u0010\u000f\u0001\u0011\u0010\u0001\u0012\u0011\u0001\u0013\u0012\u0001"+
		"\u0014\u0013\u0001\u0015\u0014\u0001\u0016\u0015\u0001\u0017\u0016\u0001"+
		"\u0018\u0017\u0001\u0019\u0018\u0001\u001a\u0019\u0001\u001b\u001a\u0001"+
		"\u001c\u001b\u0001\u001d\u001c\u0001\u001e\u001d\u0001\u001f\u001e\u0001"+
		" \u001f\u0001  \u0001 !";
	public static final ATN _ATN =
		new ATNDeserializer().deserialize(_serializedATN.toCharArray());
	static {
		_decisionToDFA = new DFA[_ATN.getNumberOfDecisions()];
		for (int i = 0; i < _ATN.getNumberOfDecisions(); i++) {
			_decisionToDFA[i] = new DFA(_ATN.getDecisionState(i), i);
		}
	}
}