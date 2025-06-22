
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


// Generated from C8086Parser.g4 by ANTLR 4.13.2


#include "C8086ParserListener.h"

#include "C8086Parser.h"


using namespace antlrcpp;

using namespace antlr4;

namespace {

struct C8086ParserStaticData final {
  C8086ParserStaticData(std::vector<std::string> ruleNames,
                        std::vector<std::string> literalNames,
                        std::vector<std::string> symbolicNames)
      : ruleNames(std::move(ruleNames)), literalNames(std::move(literalNames)),
        symbolicNames(std::move(symbolicNames)),
        vocabulary(this->literalNames, this->symbolicNames) {}

  C8086ParserStaticData(const C8086ParserStaticData&) = delete;
  C8086ParserStaticData(C8086ParserStaticData&&) = delete;
  C8086ParserStaticData& operator=(const C8086ParserStaticData&) = delete;
  C8086ParserStaticData& operator=(C8086ParserStaticData&&) = delete;

  std::vector<antlr4::dfa::DFA> decisionToDFA;
  antlr4::atn::PredictionContextCache sharedContextCache;
  const std::vector<std::string> ruleNames;
  const std::vector<std::string> literalNames;
  const std::vector<std::string> symbolicNames;
  const antlr4::dfa::Vocabulary vocabulary;
  antlr4::atn::SerializedATNView serializedATN;
  std::unique_ptr<antlr4::atn::ATN> atn;
};

::antlr4::internal::OnceFlag c8086parserParserOnceFlag;
#if ANTLR4_USE_THREAD_LOCAL_CACHE
static thread_local
#endif
std::unique_ptr<C8086ParserStaticData> c8086parserParserStaticData = nullptr;

void c8086parserParserInitialize() {
#if ANTLR4_USE_THREAD_LOCAL_CACHE
  if (c8086parserParserStaticData != nullptr) {
    return;
  }
#else
  assert(c8086parserParserStaticData == nullptr);
#endif
  auto staticData = std::make_unique<C8086ParserStaticData>(
    std::vector<std::string>{
      "start", "program", "unit", "func_declaration", "func_definition", 
      "parameter_list", "compound_statement", "var_declaration", "declaration_list_err", 
      "type_specifier", "declaration_list", "statements", "statement", "expression_statement", 
      "variable", "expression", "logic_expression", "rel_expression", "simple_expression", 
      "term", "unary_expression", "factor", "argument_list", "arguments"
    },
    std::vector<std::string>{
      "", "", "", "", "", "'if'", "'else'", "'for'", "'while'", "'println'", 
      "'return'", "'int'", "'float'", "'void'", "'('", "')'", "'{'", "'}'", 
      "'['", "']'", "';'", "','", "", "", "", "'++'", "'--'", "'!'", "", 
      "", "'='"
    },
    std::vector<std::string>{
      "", "LINE_COMMENT", "BLOCK_COMMENT", "STRING", "WS", "IF", "ELSE", 
      "FOR", "WHILE", "PRINTLN", "RETURN", "INT", "FLOAT", "VOID", "LPAREN", 
      "RPAREN", "LCURL", "RCURL", "LTHIRD", "RTHIRD", "SEMICOLON", "COMMA", 
      "ADDOP", "SUBOP", "MULOP", "INCOP", "DECOP", "NOT", "RELOP", "LOGICOP", 
      "ASSIGNOP", "ID", "CONST_INT", "CONST_FLOAT"
    }
  );
  static const int32_t serializedATNSegment[] = {
  	4,1,33,398,2,0,7,0,2,1,7,1,2,2,7,2,2,3,7,3,2,4,7,4,2,5,7,5,2,6,7,6,2,
  	7,7,7,2,8,7,8,2,9,7,9,2,10,7,10,2,11,7,11,2,12,7,12,2,13,7,13,2,14,7,
  	14,2,15,7,15,2,16,7,16,2,17,7,17,2,18,7,18,2,19,7,19,2,20,7,20,2,21,7,
  	21,2,22,7,22,2,23,7,23,1,0,1,0,1,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,5,
  	1,60,8,1,10,1,12,1,63,9,1,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,3,2,74,
  	8,2,1,3,1,3,1,3,1,3,1,3,1,3,1,3,1,3,1,3,1,3,1,3,1,3,1,3,1,3,1,3,3,3,91,
  	8,3,1,4,1,4,1,4,1,4,1,4,1,4,1,4,1,4,1,4,1,4,1,4,1,4,1,4,1,4,1,4,3,4,108,
  	8,4,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,3,5,118,8,5,1,5,1,5,1,5,1,5,1,5,1,
  	5,1,5,1,5,1,5,1,5,1,5,5,5,131,8,5,10,5,12,5,134,9,5,1,6,1,6,1,6,1,6,1,
  	6,1,6,1,6,1,6,3,6,144,8,6,1,7,1,7,1,7,1,7,1,7,1,7,1,7,1,7,1,7,1,7,3,7,
  	156,8,7,1,8,1,8,1,9,1,9,1,9,1,9,1,9,1,9,3,9,166,8,9,1,10,1,10,1,10,1,
  	10,1,10,1,10,1,10,1,10,3,10,176,8,10,1,10,1,10,1,10,1,10,1,10,1,10,1,
  	10,1,10,1,10,1,10,1,10,5,10,189,8,10,10,10,12,10,192,9,10,1,11,1,11,1,
  	11,1,11,1,11,1,11,1,11,1,11,5,11,202,8,11,10,11,12,11,205,9,11,1,12,1,
  	12,1,12,1,12,1,12,1,12,1,12,1,12,1,12,1,12,1,12,1,12,1,12,1,12,1,12,1,
  	12,1,12,1,12,1,12,1,12,1,12,1,12,1,12,1,12,1,12,1,12,1,12,1,12,1,12,1,
  	12,1,12,1,12,1,12,1,12,1,12,1,12,1,12,1,12,1,12,1,12,1,12,1,12,1,12,1,
  	12,1,12,1,12,1,12,1,12,1,12,1,12,1,12,1,12,3,12,259,8,12,1,13,1,13,1,
  	13,1,13,1,13,1,13,3,13,267,8,13,1,14,1,14,1,14,1,14,1,14,1,14,1,14,1,
  	14,3,14,277,8,14,1,15,1,15,1,15,1,15,1,15,1,15,1,15,1,15,3,15,287,8,15,
  	1,16,1,16,1,16,1,16,1,16,1,16,1,16,1,16,3,16,297,8,16,1,17,1,17,1,17,
  	1,17,1,17,1,17,1,17,1,17,3,17,307,8,17,1,18,1,18,1,18,1,18,1,18,1,18,
  	1,18,1,18,1,18,5,18,318,8,18,10,18,12,18,321,9,18,1,19,1,19,1,19,1,19,
  	1,19,1,19,1,19,1,19,1,19,5,19,332,8,19,10,19,12,19,335,9,19,1,20,1,20,
  	1,20,1,20,1,20,1,20,1,20,1,20,1,20,1,20,1,20,3,20,348,8,20,1,21,1,21,
  	1,21,1,21,1,21,1,21,1,21,1,21,1,21,1,21,1,21,1,21,1,21,1,21,1,21,1,21,
  	1,21,1,21,1,21,1,21,1,21,1,21,1,21,1,21,1,21,1,21,3,21,376,8,21,1,22,
  	1,22,1,22,1,22,3,22,382,8,22,1,23,1,23,1,23,1,23,1,23,1,23,1,23,1,23,
  	1,23,5,23,393,8,23,10,23,12,23,396,9,23,1,23,0,7,2,10,20,22,36,38,46,
  	24,0,2,4,6,8,10,12,14,16,18,20,22,24,26,28,30,32,34,36,38,40,42,44,46,
  	0,0,414,0,48,1,0,0,0,2,51,1,0,0,0,4,73,1,0,0,0,6,90,1,0,0,0,8,107,1,0,
  	0,0,10,117,1,0,0,0,12,143,1,0,0,0,14,155,1,0,0,0,16,157,1,0,0,0,18,165,
  	1,0,0,0,20,175,1,0,0,0,22,193,1,0,0,0,24,258,1,0,0,0,26,266,1,0,0,0,28,
  	276,1,0,0,0,30,286,1,0,0,0,32,296,1,0,0,0,34,306,1,0,0,0,36,308,1,0,0,
  	0,38,322,1,0,0,0,40,347,1,0,0,0,42,375,1,0,0,0,44,381,1,0,0,0,46,383,
  	1,0,0,0,48,49,3,2,1,0,49,50,6,0,-1,0,50,1,1,0,0,0,51,52,6,1,-1,0,52,53,
  	3,4,2,0,53,54,6,1,-1,0,54,61,1,0,0,0,55,56,10,2,0,0,56,57,3,4,2,0,57,
  	58,6,1,-1,0,58,60,1,0,0,0,59,55,1,0,0,0,60,63,1,0,0,0,61,59,1,0,0,0,61,
  	62,1,0,0,0,62,3,1,0,0,0,63,61,1,0,0,0,64,65,3,14,7,0,65,66,6,2,-1,0,66,
  	74,1,0,0,0,67,68,3,6,3,0,68,69,6,2,-1,0,69,74,1,0,0,0,70,71,3,8,4,0,71,
  	72,6,2,-1,0,72,74,1,0,0,0,73,64,1,0,0,0,73,67,1,0,0,0,73,70,1,0,0,0,74,
  	5,1,0,0,0,75,76,3,18,9,0,76,77,5,31,0,0,77,78,5,14,0,0,78,79,3,10,5,0,
  	79,80,5,15,0,0,80,81,5,20,0,0,81,82,6,3,-1,0,82,91,1,0,0,0,83,84,3,18,
  	9,0,84,85,5,31,0,0,85,86,5,14,0,0,86,87,5,15,0,0,87,88,5,20,0,0,88,89,
  	6,3,-1,0,89,91,1,0,0,0,90,75,1,0,0,0,90,83,1,0,0,0,91,7,1,0,0,0,92,93,
  	3,18,9,0,93,94,5,31,0,0,94,95,5,14,0,0,95,96,3,10,5,0,96,97,5,15,0,0,
  	97,98,3,12,6,0,98,99,6,4,-1,0,99,108,1,0,0,0,100,101,3,18,9,0,101,102,
  	5,31,0,0,102,103,5,14,0,0,103,104,5,15,0,0,104,105,3,12,6,0,105,106,6,
  	4,-1,0,106,108,1,0,0,0,107,92,1,0,0,0,107,100,1,0,0,0,108,9,1,0,0,0,109,
  	110,6,5,-1,0,110,111,3,18,9,0,111,112,5,31,0,0,112,113,6,5,-1,0,113,118,
  	1,0,0,0,114,115,3,18,9,0,115,116,6,5,-1,0,116,118,1,0,0,0,117,109,1,0,
  	0,0,117,114,1,0,0,0,118,132,1,0,0,0,119,120,10,4,0,0,120,121,5,21,0,0,
  	121,122,3,18,9,0,122,123,5,31,0,0,123,124,6,5,-1,0,124,131,1,0,0,0,125,
  	126,10,3,0,0,126,127,5,21,0,0,127,128,3,18,9,0,128,129,6,5,-1,0,129,131,
  	1,0,0,0,130,119,1,0,0,0,130,125,1,0,0,0,131,134,1,0,0,0,132,130,1,0,0,
  	0,132,133,1,0,0,0,133,11,1,0,0,0,134,132,1,0,0,0,135,136,5,16,0,0,136,
  	137,3,22,11,0,137,138,5,17,0,0,138,139,6,6,-1,0,139,144,1,0,0,0,140,141,
  	5,16,0,0,141,142,5,17,0,0,142,144,6,6,-1,0,143,135,1,0,0,0,143,140,1,
  	0,0,0,144,13,1,0,0,0,145,146,3,18,9,0,146,147,3,20,10,0,147,148,5,20,
  	0,0,148,149,6,7,-1,0,149,156,1,0,0,0,150,151,3,18,9,0,151,152,3,16,8,
  	0,152,153,5,20,0,0,153,154,6,7,-1,0,154,156,1,0,0,0,155,145,1,0,0,0,155,
  	150,1,0,0,0,156,15,1,0,0,0,157,158,6,8,-1,0,158,17,1,0,0,0,159,160,5,
  	11,0,0,160,166,6,9,-1,0,161,162,5,12,0,0,162,166,6,9,-1,0,163,164,5,13,
  	0,0,164,166,6,9,-1,0,165,159,1,0,0,0,165,161,1,0,0,0,165,163,1,0,0,0,
  	166,19,1,0,0,0,167,168,6,10,-1,0,168,169,5,31,0,0,169,176,6,10,-1,0,170,
  	171,5,31,0,0,171,172,5,18,0,0,172,173,5,32,0,0,173,174,5,19,0,0,174,176,
  	6,10,-1,0,175,167,1,0,0,0,175,170,1,0,0,0,176,190,1,0,0,0,177,178,10,
  	3,0,0,178,179,5,21,0,0,179,180,5,31,0,0,180,189,6,10,-1,0,181,182,10,
  	1,0,0,182,183,5,21,0,0,183,184,5,31,0,0,184,185,5,18,0,0,185,186,5,32,
  	0,0,186,187,5,19,0,0,187,189,6,10,-1,0,188,177,1,0,0,0,188,181,1,0,0,
  	0,189,192,1,0,0,0,190,188,1,0,0,0,190,191,1,0,0,0,191,21,1,0,0,0,192,
  	190,1,0,0,0,193,194,6,11,-1,0,194,195,3,24,12,0,195,196,6,11,-1,0,196,
  	203,1,0,0,0,197,198,10,1,0,0,198,199,3,24,12,0,199,200,6,11,-1,0,200,
  	202,1,0,0,0,201,197,1,0,0,0,202,205,1,0,0,0,203,201,1,0,0,0,203,204,1,
  	0,0,0,204,23,1,0,0,0,205,203,1,0,0,0,206,207,3,14,7,0,207,208,6,12,-1,
  	0,208,259,1,0,0,0,209,210,3,26,13,0,210,211,6,12,-1,0,211,259,1,0,0,0,
  	212,213,3,12,6,0,213,214,6,12,-1,0,214,259,1,0,0,0,215,216,5,7,0,0,216,
  	217,5,14,0,0,217,218,3,26,13,0,218,219,3,26,13,0,219,220,3,30,15,0,220,
  	221,5,15,0,0,221,222,3,24,12,0,222,223,6,12,-1,0,223,259,1,0,0,0,224,
  	225,5,5,0,0,225,226,5,14,0,0,226,227,3,30,15,0,227,228,5,15,0,0,228,229,
  	3,24,12,0,229,230,6,12,-1,0,230,259,1,0,0,0,231,232,5,5,0,0,232,233,5,
  	14,0,0,233,234,3,30,15,0,234,235,5,15,0,0,235,236,3,24,12,0,236,237,5,
  	6,0,0,237,238,3,24,12,0,238,239,6,12,-1,0,239,259,1,0,0,0,240,241,5,8,
  	0,0,241,242,5,14,0,0,242,243,3,30,15,0,243,244,5,15,0,0,244,245,3,24,
  	12,0,245,246,6,12,-1,0,246,259,1,0,0,0,247,248,5,9,0,0,248,249,5,14,0,
  	0,249,250,5,31,0,0,250,251,5,15,0,0,251,252,5,20,0,0,252,259,6,12,-1,
  	0,253,254,5,10,0,0,254,255,3,30,15,0,255,256,5,20,0,0,256,257,6,12,-1,
  	0,257,259,1,0,0,0,258,206,1,0,0,0,258,209,1,0,0,0,258,212,1,0,0,0,258,
  	215,1,0,0,0,258,224,1,0,0,0,258,231,1,0,0,0,258,240,1,0,0,0,258,247,1,
  	0,0,0,258,253,1,0,0,0,259,25,1,0,0,0,260,261,5,20,0,0,261,267,6,13,-1,
  	0,262,263,3,30,15,0,263,264,5,20,0,0,264,265,6,13,-1,0,265,267,1,0,0,
  	0,266,260,1,0,0,0,266,262,1,0,0,0,267,27,1,0,0,0,268,269,5,31,0,0,269,
  	277,6,14,-1,0,270,271,5,31,0,0,271,272,5,18,0,0,272,273,3,30,15,0,273,
  	274,5,19,0,0,274,275,6,14,-1,0,275,277,1,0,0,0,276,268,1,0,0,0,276,270,
  	1,0,0,0,277,29,1,0,0,0,278,279,3,32,16,0,279,280,6,15,-1,0,280,287,1,
  	0,0,0,281,282,3,28,14,0,282,283,5,30,0,0,283,284,3,32,16,0,284,285,6,
  	15,-1,0,285,287,1,0,0,0,286,278,1,0,0,0,286,281,1,0,0,0,287,31,1,0,0,
  	0,288,289,3,34,17,0,289,290,6,16,-1,0,290,297,1,0,0,0,291,292,3,34,17,
  	0,292,293,5,29,0,0,293,294,3,34,17,0,294,295,6,16,-1,0,295,297,1,0,0,
  	0,296,288,1,0,0,0,296,291,1,0,0,0,297,33,1,0,0,0,298,299,3,36,18,0,299,
  	300,6,17,-1,0,300,307,1,0,0,0,301,302,3,36,18,0,302,303,5,28,0,0,303,
  	304,3,36,18,0,304,305,6,17,-1,0,305,307,1,0,0,0,306,298,1,0,0,0,306,301,
  	1,0,0,0,307,35,1,0,0,0,308,309,6,18,-1,0,309,310,3,38,19,0,310,311,6,
  	18,-1,0,311,319,1,0,0,0,312,313,10,1,0,0,313,314,5,22,0,0,314,315,3,38,
  	19,0,315,316,6,18,-1,0,316,318,1,0,0,0,317,312,1,0,0,0,318,321,1,0,0,
  	0,319,317,1,0,0,0,319,320,1,0,0,0,320,37,1,0,0,0,321,319,1,0,0,0,322,
  	323,6,19,-1,0,323,324,3,40,20,0,324,325,6,19,-1,0,325,333,1,0,0,0,326,
  	327,10,1,0,0,327,328,5,24,0,0,328,329,3,40,20,0,329,330,6,19,-1,0,330,
  	332,1,0,0,0,331,326,1,0,0,0,332,335,1,0,0,0,333,331,1,0,0,0,333,334,1,
  	0,0,0,334,39,1,0,0,0,335,333,1,0,0,0,336,337,5,22,0,0,337,338,3,40,20,
  	0,338,339,6,20,-1,0,339,348,1,0,0,0,340,341,5,27,0,0,341,342,3,40,20,
  	0,342,343,6,20,-1,0,343,348,1,0,0,0,344,345,3,42,21,0,345,346,6,20,-1,
  	0,346,348,1,0,0,0,347,336,1,0,0,0,347,340,1,0,0,0,347,344,1,0,0,0,348,
  	41,1,0,0,0,349,350,3,28,14,0,350,351,6,21,-1,0,351,376,1,0,0,0,352,353,
  	5,31,0,0,353,354,5,14,0,0,354,355,3,44,22,0,355,356,5,15,0,0,356,357,
  	6,21,-1,0,357,376,1,0,0,0,358,359,5,14,0,0,359,360,3,30,15,0,360,361,
  	5,15,0,0,361,362,6,21,-1,0,362,376,1,0,0,0,363,364,5,32,0,0,364,376,6,
  	21,-1,0,365,366,5,33,0,0,366,376,6,21,-1,0,367,368,3,28,14,0,368,369,
  	5,25,0,0,369,370,6,21,-1,0,370,376,1,0,0,0,371,372,3,28,14,0,372,373,
  	5,26,0,0,373,374,6,21,-1,0,374,376,1,0,0,0,375,349,1,0,0,0,375,352,1,
  	0,0,0,375,358,1,0,0,0,375,363,1,0,0,0,375,365,1,0,0,0,375,367,1,0,0,0,
  	375,371,1,0,0,0,376,43,1,0,0,0,377,378,3,46,23,0,378,379,6,22,-1,0,379,
  	382,1,0,0,0,380,382,6,22,-1,0,381,377,1,0,0,0,381,380,1,0,0,0,382,45,
  	1,0,0,0,383,384,6,23,-1,0,384,385,3,32,16,0,385,386,6,23,-1,0,386,394,
  	1,0,0,0,387,388,10,2,0,0,388,389,5,21,0,0,389,390,3,32,16,0,390,391,6,
  	23,-1,0,391,393,1,0,0,0,392,387,1,0,0,0,393,396,1,0,0,0,394,392,1,0,0,
  	0,394,395,1,0,0,0,395,47,1,0,0,0,396,394,1,0,0,0,26,61,73,90,107,117,
  	130,132,143,155,165,175,188,190,203,258,266,276,286,296,306,319,333,347,
  	375,381,394
  };
  staticData->serializedATN = antlr4::atn::SerializedATNView(serializedATNSegment, sizeof(serializedATNSegment) / sizeof(serializedATNSegment[0]));

  antlr4::atn::ATNDeserializer deserializer;
  staticData->atn = deserializer.deserialize(staticData->serializedATN);

  const size_t count = staticData->atn->getNumberOfDecisions();
  staticData->decisionToDFA.reserve(count);
  for (size_t i = 0; i < count; i++) { 
    staticData->decisionToDFA.emplace_back(staticData->atn->getDecisionState(i), i);
  }
  c8086parserParserStaticData = std::move(staticData);
}

}

C8086Parser::C8086Parser(TokenStream *input) : C8086Parser(input, antlr4::atn::ParserATNSimulatorOptions()) {}

C8086Parser::C8086Parser(TokenStream *input, const antlr4::atn::ParserATNSimulatorOptions &options) : Parser(input) {
  C8086Parser::initialize();
  _interpreter = new atn::ParserATNSimulator(this, *c8086parserParserStaticData->atn, c8086parserParserStaticData->decisionToDFA, c8086parserParserStaticData->sharedContextCache, options);
}

C8086Parser::~C8086Parser() {
  delete _interpreter;
}

const atn::ATN& C8086Parser::getATN() const {
  return *c8086parserParserStaticData->atn;
}

std::string C8086Parser::getGrammarFileName() const {
  return "C8086Parser.g4";
}

const std::vector<std::string>& C8086Parser::getRuleNames() const {
  return c8086parserParserStaticData->ruleNames;
}

const dfa::Vocabulary& C8086Parser::getVocabulary() const {
  return c8086parserParserStaticData->vocabulary;
}

antlr4::atn::SerializedATNView C8086Parser::getSerializedATN() const {
  return c8086parserParserStaticData->serializedATN;
}


//----------------- StartContext ------------------------------------------------------------------

C8086Parser::StartContext::StartContext(ParserRuleContext *parent, size_t invokingState)
  : ParserRuleContext(parent, invokingState) {
}

C8086Parser::ProgramContext* C8086Parser::StartContext::program() {
  return getRuleContext<C8086Parser::ProgramContext>(0);
}


size_t C8086Parser::StartContext::getRuleIndex() const {
  return C8086Parser::RuleStart;
}

void C8086Parser::StartContext::enterRule(tree::ParseTreeListener *listener) {
  auto parserListener = dynamic_cast<C8086ParserListener *>(listener);
  if (parserListener != nullptr)
    parserListener->enterStart(this);
}

void C8086Parser::StartContext::exitRule(tree::ParseTreeListener *listener) {
  auto parserListener = dynamic_cast<C8086ParserListener *>(listener);
  if (parserListener != nullptr)
    parserListener->exitStart(this);
}

C8086Parser::StartContext* C8086Parser::start() {
  StartContext *_localctx = _tracker.createInstance<StartContext>(_ctx, getState());
  enterRule(_localctx, 0, C8086Parser::RuleStart);

#if __cplusplus > 201703L
  auto onExit = finally([=, this] {
#else
  auto onExit = finally([=] {
#endif
    exitRule();
  });
  try {
    enterOuterAlt(_localctx, 1);
    setState(48);
    antlrcpp::downCast<StartContext *>(_localctx)->programContext = program(0);

            writeIntoparserLogFile("Line " + std::to_string((antlrcpp::downCast<StartContext *>(_localctx)->programContext != nullptr ? (antlrcpp::downCast<StartContext *>(_localctx)->programContext->start) : nullptr)->getLine()) + ": start : program");
            writeIntoparserLogFile("");
            writeIntoparserLogFile("Parsing completed successfully with " + std::to_string(syntaxErrorCount) + " syntax errors.");
    	
   
  }
  catch (RecognitionException &e) {
    _errHandler->reportError(this, e);
    _localctx->exception = std::current_exception();
    _errHandler->recover(this, _localctx->exception);
  }

  return _localctx;
}

//----------------- ProgramContext ------------------------------------------------------------------

C8086Parser::ProgramContext::ProgramContext(ParserRuleContext *parent, size_t invokingState)
  : ParserRuleContext(parent, invokingState) {
}

C8086Parser::UnitContext* C8086Parser::ProgramContext::unit() {
  return getRuleContext<C8086Parser::UnitContext>(0);
}

C8086Parser::ProgramContext* C8086Parser::ProgramContext::program() {
  return getRuleContext<C8086Parser::ProgramContext>(0);
}


size_t C8086Parser::ProgramContext::getRuleIndex() const {
  return C8086Parser::RuleProgram;
}

void C8086Parser::ProgramContext::enterRule(tree::ParseTreeListener *listener) {
  auto parserListener = dynamic_cast<C8086ParserListener *>(listener);
  if (parserListener != nullptr)
    parserListener->enterProgram(this);
}

void C8086Parser::ProgramContext::exitRule(tree::ParseTreeListener *listener) {
  auto parserListener = dynamic_cast<C8086ParserListener *>(listener);
  if (parserListener != nullptr)
    parserListener->exitProgram(this);
}


C8086Parser::ProgramContext* C8086Parser::program() {
   return program(0);
}

C8086Parser::ProgramContext* C8086Parser::program(int precedence) {
  ParserRuleContext *parentContext = _ctx;
  size_t parentState = getState();
  C8086Parser::ProgramContext *_localctx = _tracker.createInstance<ProgramContext>(_ctx, parentState);
  C8086Parser::ProgramContext *previousContext = _localctx;
  (void)previousContext; // Silence compiler, in case the context is not used by generated code.
  size_t startState = 2;
  enterRecursionRule(_localctx, 2, C8086Parser::RuleProgram, precedence);

    

#if __cplusplus > 201703L
  auto onExit = finally([=, this] {
#else
  auto onExit = finally([=] {
#endif
    unrollRecursionContexts(parentContext);
  });
  try {
    size_t alt;
    enterOuterAlt(_localctx, 1);
    setState(52);
    antlrcpp::downCast<ProgramContext *>(_localctx)->u = unit();

            antlrcpp::downCast<ProgramContext *>(_localctx)->code =  antlrcpp::downCast<ProgramContext *>(_localctx)->u->code;
            writeIntoparserLogFile("Line " + std::to_string((antlrcpp::downCast<ProgramContext *>(_localctx)->u != nullptr ? (antlrcpp::downCast<ProgramContext *>(_localctx)->u->start) : nullptr)->getLine()) + ": program : unit");
            writeIntoparserLogFile("");
            writeIntoparserLogFile(_localctx->code);
            writeIntoparserLogFile("");
        
    _ctx->stop = _input->LT(-1);
    setState(61);
    _errHandler->sync(this);
    alt = getInterpreter<atn::ParserATNSimulator>()->adaptivePredict(_input, 0, _ctx);
    while (alt != 2 && alt != atn::ATN::INVALID_ALT_NUMBER) {
      if (alt == 1) {
        if (!_parseListeners.empty())
          triggerExitRuleEvent();
        previousContext = _localctx;
        _localctx = _tracker.createInstance<ProgramContext>(parentContext, parentState);
        _localctx->p = previousContext;
        pushNewRecursionContext(_localctx, startState, RuleProgram);
        setState(55);

        if (!(precpred(_ctx, 2))) throw FailedPredicateException(this, "precpred(_ctx, 2)");
        setState(56);
        antlrcpp::downCast<ProgramContext *>(_localctx)->u = unit();

                          antlrcpp::downCast<ProgramContext *>(_localctx)->code =  antlrcpp::downCast<ProgramContext *>(_localctx)->p->code + "\n" + antlrcpp::downCast<ProgramContext *>(_localctx)->u->code;
                          writeIntoparserLogFile("Line " + std::to_string((antlrcpp::downCast<ProgramContext *>(_localctx)->u != nullptr ? (antlrcpp::downCast<ProgramContext *>(_localctx)->u->start) : nullptr)->getLine()) + ": program : program unit");
                          writeIntoparserLogFile("");
                          writeIntoparserLogFile(_localctx->code);
                          writeIntoparserLogFile("");
                       
      }
      setState(63);
      _errHandler->sync(this);
      alt = getInterpreter<atn::ParserATNSimulator>()->adaptivePredict(_input, 0, _ctx);
    }
  }
  catch (RecognitionException &e) {
    _errHandler->reportError(this, e);
    _localctx->exception = std::current_exception();
    _errHandler->recover(this, _localctx->exception);
  }
  return _localctx;
}

//----------------- UnitContext ------------------------------------------------------------------

C8086Parser::UnitContext::UnitContext(ParserRuleContext *parent, size_t invokingState)
  : ParserRuleContext(parent, invokingState) {
}

C8086Parser::Var_declarationContext* C8086Parser::UnitContext::var_declaration() {
  return getRuleContext<C8086Parser::Var_declarationContext>(0);
}

C8086Parser::Func_declarationContext* C8086Parser::UnitContext::func_declaration() {
  return getRuleContext<C8086Parser::Func_declarationContext>(0);
}

C8086Parser::Func_definitionContext* C8086Parser::UnitContext::func_definition() {
  return getRuleContext<C8086Parser::Func_definitionContext>(0);
}


size_t C8086Parser::UnitContext::getRuleIndex() const {
  return C8086Parser::RuleUnit;
}

void C8086Parser::UnitContext::enterRule(tree::ParseTreeListener *listener) {
  auto parserListener = dynamic_cast<C8086ParserListener *>(listener);
  if (parserListener != nullptr)
    parserListener->enterUnit(this);
}

void C8086Parser::UnitContext::exitRule(tree::ParseTreeListener *listener) {
  auto parserListener = dynamic_cast<C8086ParserListener *>(listener);
  if (parserListener != nullptr)
    parserListener->exitUnit(this);
}

C8086Parser::UnitContext* C8086Parser::unit() {
  UnitContext *_localctx = _tracker.createInstance<UnitContext>(_ctx, getState());
  enterRule(_localctx, 4, C8086Parser::RuleUnit);

#if __cplusplus > 201703L
  auto onExit = finally([=, this] {
#else
  auto onExit = finally([=] {
#endif
    exitRule();
  });
  try {
    setState(73);
    _errHandler->sync(this);
    switch (getInterpreter<atn::ParserATNSimulator>()->adaptivePredict(_input, 1, _ctx)) {
    case 1: {
      enterOuterAlt(_localctx, 1);
      setState(64);
      antlrcpp::downCast<UnitContext *>(_localctx)->vd = var_declaration();

              antlrcpp::downCast<UnitContext *>(_localctx)->code =  antlrcpp::downCast<UnitContext *>(_localctx)->vd->code;
              antlrcpp::downCast<UnitContext *>(_localctx)->line =  antlrcpp::downCast<UnitContext *>(_localctx)->vd->line;
              writeIntoparserLogFile("Line " + std::to_string(_localctx->line) + ": unit : var_declaration");
              writeIntoparserLogFile("");
              writeIntoparserLogFile(_localctx->code);
              writeIntoparserLogFile("");
          
      break;
    }

    case 2: {
      enterOuterAlt(_localctx, 2);
      setState(67);
      antlrcpp::downCast<UnitContext *>(_localctx)->fd = func_declaration();

              antlrcpp::downCast<UnitContext *>(_localctx)->code =  antlrcpp::downCast<UnitContext *>(_localctx)->fd->code;
              antlrcpp::downCast<UnitContext *>(_localctx)->line =  antlrcpp::downCast<UnitContext *>(_localctx)->fd->line;
              writeIntoparserLogFile("Line " + std::to_string(_localctx->line) + ": unit : func_declaration");
              writeIntoparserLogFile("");
              writeIntoparserLogFile(_localctx->code);
              writeIntoparserLogFile("");
          
      break;
    }

    case 3: {
      enterOuterAlt(_localctx, 3);
      setState(70);
      antlrcpp::downCast<UnitContext *>(_localctx)->fdef = func_definition();

              antlrcpp::downCast<UnitContext *>(_localctx)->code =  antlrcpp::downCast<UnitContext *>(_localctx)->fdef->code; 
              antlrcpp::downCast<UnitContext *>(_localctx)->line =  antlrcpp::downCast<UnitContext *>(_localctx)->fdef->line;
              writeIntoparserLogFile("Line " + std::to_string(_localctx->line) + ": unit : func_definition");
              writeIntoparserLogFile("");
              writeIntoparserLogFile(_localctx->code);
              writeIntoparserLogFile("");
          
      break;
    }

    default:
      break;
    }
   
  }
  catch (RecognitionException &e) {
    _errHandler->reportError(this, e);
    _localctx->exception = std::current_exception();
    _errHandler->recover(this, _localctx->exception);
  }

  return _localctx;
}

//----------------- Func_declarationContext ------------------------------------------------------------------

C8086Parser::Func_declarationContext::Func_declarationContext(ParserRuleContext *parent, size_t invokingState)
  : ParserRuleContext(parent, invokingState) {
}

tree::TerminalNode* C8086Parser::Func_declarationContext::LPAREN() {
  return getToken(C8086Parser::LPAREN, 0);
}

C8086Parser::Parameter_listContext* C8086Parser::Func_declarationContext::parameter_list() {
  return getRuleContext<C8086Parser::Parameter_listContext>(0);
}

tree::TerminalNode* C8086Parser::Func_declarationContext::RPAREN() {
  return getToken(C8086Parser::RPAREN, 0);
}

C8086Parser::Type_specifierContext* C8086Parser::Func_declarationContext::type_specifier() {
  return getRuleContext<C8086Parser::Type_specifierContext>(0);
}

tree::TerminalNode* C8086Parser::Func_declarationContext::ID() {
  return getToken(C8086Parser::ID, 0);
}

tree::TerminalNode* C8086Parser::Func_declarationContext::SEMICOLON() {
  return getToken(C8086Parser::SEMICOLON, 0);
}


size_t C8086Parser::Func_declarationContext::getRuleIndex() const {
  return C8086Parser::RuleFunc_declaration;
}

void C8086Parser::Func_declarationContext::enterRule(tree::ParseTreeListener *listener) {
  auto parserListener = dynamic_cast<C8086ParserListener *>(listener);
  if (parserListener != nullptr)
    parserListener->enterFunc_declaration(this);
}

void C8086Parser::Func_declarationContext::exitRule(tree::ParseTreeListener *listener) {
  auto parserListener = dynamic_cast<C8086ParserListener *>(listener);
  if (parserListener != nullptr)
    parserListener->exitFunc_declaration(this);
}

C8086Parser::Func_declarationContext* C8086Parser::func_declaration() {
  Func_declarationContext *_localctx = _tracker.createInstance<Func_declarationContext>(_ctx, getState());
  enterRule(_localctx, 6, C8086Parser::RuleFunc_declaration);

#if __cplusplus > 201703L
  auto onExit = finally([=, this] {
#else
  auto onExit = finally([=] {
#endif
    exitRule();
  });
  try {
    setState(90);
    _errHandler->sync(this);
    switch (getInterpreter<atn::ParserATNSimulator>()->adaptivePredict(_input, 2, _ctx)) {
    case 1: {
      enterOuterAlt(_localctx, 1);
      setState(75);
      antlrcpp::downCast<Func_declarationContext *>(_localctx)->t = type_specifier();
      setState(76);
      antlrcpp::downCast<Func_declarationContext *>(_localctx)->id = match(C8086Parser::ID);
      setState(77);
      match(C8086Parser::LPAREN);
      setState(78);
      parameter_list(0);
      setState(79);
      match(C8086Parser::RPAREN);
      setState(80);
      antlrcpp::downCast<Func_declarationContext *>(_localctx)->sm = match(C8086Parser::SEMICOLON);

              antlrcpp::downCast<Func_declarationContext *>(_localctx)->line =  antlrcpp::downCast<Func_declarationContext *>(_localctx)->sm->getLine();
              antlrcpp::downCast<Func_declarationContext *>(_localctx)->code =  antlrcpp::downCast<Func_declarationContext *>(_localctx)->t->text + " " + antlrcpp::downCast<Func_declarationContext *>(_localctx)->id->getText() + "();";
              writeIntoparserLogFile("Line " + std::to_string(_localctx->line) + ": func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON");
              writeIntoparserLogFile("");
              writeIntoparserLogFile(_localctx->code);
              writeIntoparserLogFile("");
          
      break;
    }

    case 2: {
      enterOuterAlt(_localctx, 2);
      setState(83);
      antlrcpp::downCast<Func_declarationContext *>(_localctx)->t = type_specifier();
      setState(84);
      antlrcpp::downCast<Func_declarationContext *>(_localctx)->id = match(C8086Parser::ID);
      setState(85);
      match(C8086Parser::LPAREN);
      setState(86);
      match(C8086Parser::RPAREN);
      setState(87);
      antlrcpp::downCast<Func_declarationContext *>(_localctx)->sm = match(C8086Parser::SEMICOLON);

              antlrcpp::downCast<Func_declarationContext *>(_localctx)->line =  antlrcpp::downCast<Func_declarationContext *>(_localctx)->sm->getLine();
              antlrcpp::downCast<Func_declarationContext *>(_localctx)->code =  antlrcpp::downCast<Func_declarationContext *>(_localctx)->t->text + " " + antlrcpp::downCast<Func_declarationContext *>(_localctx)->id->getText() + "();";
              writeIntoparserLogFile("Line " + std::to_string(_localctx->line) + ": func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON");
              writeIntoparserLogFile("");
              writeIntoparserLogFile(_localctx->code);
              writeIntoparserLogFile("");
          
      break;
    }

    default:
      break;
    }
   
  }
  catch (RecognitionException &e) {
    _errHandler->reportError(this, e);
    _localctx->exception = std::current_exception();
    _errHandler->recover(this, _localctx->exception);
  }

  return _localctx;
}

//----------------- Func_definitionContext ------------------------------------------------------------------

C8086Parser::Func_definitionContext::Func_definitionContext(ParserRuleContext *parent, size_t invokingState)
  : ParserRuleContext(parent, invokingState) {
}

tree::TerminalNode* C8086Parser::Func_definitionContext::LPAREN() {
  return getToken(C8086Parser::LPAREN, 0);
}

tree::TerminalNode* C8086Parser::Func_definitionContext::RPAREN() {
  return getToken(C8086Parser::RPAREN, 0);
}

C8086Parser::Type_specifierContext* C8086Parser::Func_definitionContext::type_specifier() {
  return getRuleContext<C8086Parser::Type_specifierContext>(0);
}

tree::TerminalNode* C8086Parser::Func_definitionContext::ID() {
  return getToken(C8086Parser::ID, 0);
}

C8086Parser::Parameter_listContext* C8086Parser::Func_definitionContext::parameter_list() {
  return getRuleContext<C8086Parser::Parameter_listContext>(0);
}

C8086Parser::Compound_statementContext* C8086Parser::Func_definitionContext::compound_statement() {
  return getRuleContext<C8086Parser::Compound_statementContext>(0);
}


size_t C8086Parser::Func_definitionContext::getRuleIndex() const {
  return C8086Parser::RuleFunc_definition;
}

void C8086Parser::Func_definitionContext::enterRule(tree::ParseTreeListener *listener) {
  auto parserListener = dynamic_cast<C8086ParserListener *>(listener);
  if (parserListener != nullptr)
    parserListener->enterFunc_definition(this);
}

void C8086Parser::Func_definitionContext::exitRule(tree::ParseTreeListener *listener) {
  auto parserListener = dynamic_cast<C8086ParserListener *>(listener);
  if (parserListener != nullptr)
    parserListener->exitFunc_definition(this);
}

C8086Parser::Func_definitionContext* C8086Parser::func_definition() {
  Func_definitionContext *_localctx = _tracker.createInstance<Func_definitionContext>(_ctx, getState());
  enterRule(_localctx, 8, C8086Parser::RuleFunc_definition);

#if __cplusplus > 201703L
  auto onExit = finally([=, this] {
#else
  auto onExit = finally([=] {
#endif
    exitRule();
  });
  try {
    setState(107);
    _errHandler->sync(this);
    switch (getInterpreter<atn::ParserATNSimulator>()->adaptivePredict(_input, 3, _ctx)) {
    case 1: {
      enterOuterAlt(_localctx, 1);
      setState(92);
      antlrcpp::downCast<Func_definitionContext *>(_localctx)->t = type_specifier();
      setState(93);
      antlrcpp::downCast<Func_definitionContext *>(_localctx)->id = match(C8086Parser::ID);
      setState(94);
      match(C8086Parser::LPAREN);
      setState(95);
      antlrcpp::downCast<Func_definitionContext *>(_localctx)->pl = parameter_list(0);
      setState(96);
      match(C8086Parser::RPAREN);
      setState(97);
      antlrcpp::downCast<Func_definitionContext *>(_localctx)->cs = compound_statement();

              antlrcpp::downCast<Func_definitionContext *>(_localctx)->line =  antlrcpp::downCast<Func_definitionContext *>(_localctx)->cs->line;
              antlrcpp::downCast<Func_definitionContext *>(_localctx)->code =  antlrcpp::downCast<Func_definitionContext *>(_localctx)->t->text + " " + antlrcpp::downCast<Func_definitionContext *>(_localctx)->id->getText() + "(" + antlrcpp::downCast<Func_definitionContext *>(_localctx)->pl->code + ")" + antlrcpp::downCast<Func_definitionContext *>(_localctx)->cs->code;
              writeIntoparserLogFile("Line " + std::to_string(_localctx->line) + ": func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement");
              writeIntoparserLogFile("");
              writeIntoparserLogFile(_localctx->code);
              writeIntoparserLogFile("");
          
      break;
    }

    case 2: {
      enterOuterAlt(_localctx, 2);
      setState(100);
      antlrcpp::downCast<Func_definitionContext *>(_localctx)->t = type_specifier();
      setState(101);
      antlrcpp::downCast<Func_definitionContext *>(_localctx)->id = match(C8086Parser::ID);
      setState(102);
      match(C8086Parser::LPAREN);
      setState(103);
      match(C8086Parser::RPAREN);
      setState(104);
      antlrcpp::downCast<Func_definitionContext *>(_localctx)->cs = compound_statement();

              antlrcpp::downCast<Func_definitionContext *>(_localctx)->line =  antlrcpp::downCast<Func_definitionContext *>(_localctx)->cs->line;
              antlrcpp::downCast<Func_definitionContext *>(_localctx)->code =  antlrcpp::downCast<Func_definitionContext *>(_localctx)->t->text + " " + antlrcpp::downCast<Func_definitionContext *>(_localctx)->id->getText() + "()" + antlrcpp::downCast<Func_definitionContext *>(_localctx)->cs->code;
              writeIntoparserLogFile("Line " + std::to_string(_localctx->line) + ": func_definition : type_specifier ID LPAREN RPAREN compound_statement");
              writeIntoparserLogFile("");
              writeIntoparserLogFile(_localctx->code);
              writeIntoparserLogFile("");
          
      break;
    }

    default:
      break;
    }
   
  }
  catch (RecognitionException &e) {
    _errHandler->reportError(this, e);
    _localctx->exception = std::current_exception();
    _errHandler->recover(this, _localctx->exception);
  }

  return _localctx;
}

//----------------- Parameter_listContext ------------------------------------------------------------------

C8086Parser::Parameter_listContext::Parameter_listContext(ParserRuleContext *parent, size_t invokingState)
  : ParserRuleContext(parent, invokingState) {
}

C8086Parser::Type_specifierContext* C8086Parser::Parameter_listContext::type_specifier() {
  return getRuleContext<C8086Parser::Type_specifierContext>(0);
}

tree::TerminalNode* C8086Parser::Parameter_listContext::ID() {
  return getToken(C8086Parser::ID, 0);
}

tree::TerminalNode* C8086Parser::Parameter_listContext::COMMA() {
  return getToken(C8086Parser::COMMA, 0);
}

C8086Parser::Parameter_listContext* C8086Parser::Parameter_listContext::parameter_list() {
  return getRuleContext<C8086Parser::Parameter_listContext>(0);
}


size_t C8086Parser::Parameter_listContext::getRuleIndex() const {
  return C8086Parser::RuleParameter_list;
}

void C8086Parser::Parameter_listContext::enterRule(tree::ParseTreeListener *listener) {
  auto parserListener = dynamic_cast<C8086ParserListener *>(listener);
  if (parserListener != nullptr)
    parserListener->enterParameter_list(this);
}

void C8086Parser::Parameter_listContext::exitRule(tree::ParseTreeListener *listener) {
  auto parserListener = dynamic_cast<C8086ParserListener *>(listener);
  if (parserListener != nullptr)
    parserListener->exitParameter_list(this);
}


C8086Parser::Parameter_listContext* C8086Parser::parameter_list() {
   return parameter_list(0);
}

C8086Parser::Parameter_listContext* C8086Parser::parameter_list(int precedence) {
  ParserRuleContext *parentContext = _ctx;
  size_t parentState = getState();
  C8086Parser::Parameter_listContext *_localctx = _tracker.createInstance<Parameter_listContext>(_ctx, parentState);
  C8086Parser::Parameter_listContext *previousContext = _localctx;
  (void)previousContext; // Silence compiler, in case the context is not used by generated code.
  size_t startState = 10;
  enterRecursionRule(_localctx, 10, C8086Parser::RuleParameter_list, precedence);

    

#if __cplusplus > 201703L
  auto onExit = finally([=, this] {
#else
  auto onExit = finally([=] {
#endif
    unrollRecursionContexts(parentContext);
  });
  try {
    size_t alt;
    enterOuterAlt(_localctx, 1);
    setState(117);
    _errHandler->sync(this);
    switch (getInterpreter<atn::ParserATNSimulator>()->adaptivePredict(_input, 4, _ctx)) {
    case 1: {
      setState(110);
      antlrcpp::downCast<Parameter_listContext *>(_localctx)->t = type_specifier();
      setState(111);
      antlrcpp::downCast<Parameter_listContext *>(_localctx)->id = match(C8086Parser::ID);

              antlrcpp::downCast<Parameter_listContext *>(_localctx)->code =  antlrcpp::downCast<Parameter_listContext *>(_localctx)->t->text + " " + antlrcpp::downCast<Parameter_listContext *>(_localctx)->id->getText();
              writeIntoparserLogFile("Line " + std::to_string(antlrcpp::downCast<Parameter_listContext *>(_localctx)->id->getLine()) + ": parameter_list : type_specifier ID");
              writeIntoparserLogFile("");
              writeIntoparserLogFile(_localctx->code);
              writeIntoparserLogFile("");
          
      break;
    }

    case 2: {
      setState(114);
      antlrcpp::downCast<Parameter_listContext *>(_localctx)->t = type_specifier();

              antlrcpp::downCast<Parameter_listContext *>(_localctx)->code =  antlrcpp::downCast<Parameter_listContext *>(_localctx)->t->text;
              writeIntoparserLogFile("Line " + std::to_string(antlrcpp::downCast<Parameter_listContext *>(_localctx)->t->line) + ": parameter_list : type_specifier");
              writeIntoparserLogFile("");
              writeIntoparserLogFile(_localctx->code);
              writeIntoparserLogFile("");
          
      break;
    }

    default:
      break;
    }
    _ctx->stop = _input->LT(-1);
    setState(132);
    _errHandler->sync(this);
    alt = getInterpreter<atn::ParserATNSimulator>()->adaptivePredict(_input, 6, _ctx);
    while (alt != 2 && alt != atn::ATN::INVALID_ALT_NUMBER) {
      if (alt == 1) {
        if (!_parseListeners.empty())
          triggerExitRuleEvent();
        previousContext = _localctx;
        setState(130);
        _errHandler->sync(this);
        switch (getInterpreter<atn::ParserATNSimulator>()->adaptivePredict(_input, 5, _ctx)) {
        case 1: {
          _localctx = _tracker.createInstance<Parameter_listContext>(parentContext, parentState);
          _localctx->pl = previousContext;
          pushNewRecursionContext(_localctx, startState, RuleParameter_list);
          setState(119);

          if (!(precpred(_ctx, 4))) throw FailedPredicateException(this, "precpred(_ctx, 4)");
          setState(120);
          match(C8086Parser::COMMA);
          setState(121);
          antlrcpp::downCast<Parameter_listContext *>(_localctx)->t = type_specifier();
          setState(122);
          antlrcpp::downCast<Parameter_listContext *>(_localctx)->id = match(C8086Parser::ID);

                            antlrcpp::downCast<Parameter_listContext *>(_localctx)->code =  antlrcpp::downCast<Parameter_listContext *>(_localctx)->pl->code + "," + antlrcpp::downCast<Parameter_listContext *>(_localctx)->t->text + " " + antlrcpp::downCast<Parameter_listContext *>(_localctx)->id->getText();
                            writeIntoparserLogFile("Line " + std::to_string(antlrcpp::downCast<Parameter_listContext *>(_localctx)->id->getLine()) + ": parameter_list : parameter_list COMMA type_specifier ID");
                            writeIntoparserLogFile("");
                            writeIntoparserLogFile(_localctx->code);
                            writeIntoparserLogFile("");
                        
          break;
        }

        case 2: {
          _localctx = _tracker.createInstance<Parameter_listContext>(parentContext, parentState);
          _localctx->pl = previousContext;
          pushNewRecursionContext(_localctx, startState, RuleParameter_list);
          setState(125);

          if (!(precpred(_ctx, 3))) throw FailedPredicateException(this, "precpred(_ctx, 3)");
          setState(126);
          match(C8086Parser::COMMA);
          setState(127);
          antlrcpp::downCast<Parameter_listContext *>(_localctx)->t = type_specifier();

                            antlrcpp::downCast<Parameter_listContext *>(_localctx)->code =  antlrcpp::downCast<Parameter_listContext *>(_localctx)->pl->code + "," + antlrcpp::downCast<Parameter_listContext *>(_localctx)->t->text;
                            writeIntoparserLogFile("Line " + std::to_string(antlrcpp::downCast<Parameter_listContext *>(_localctx)->t->line) + ": parameter_list : parameter_list COMMA type_specifier");
                            writeIntoparserLogFile("");
                            writeIntoparserLogFile(_localctx->code);
                            writeIntoparserLogFile("");
                        
          break;
        }

        default:
          break;
        } 
      }
      setState(134);
      _errHandler->sync(this);
      alt = getInterpreter<atn::ParserATNSimulator>()->adaptivePredict(_input, 6, _ctx);
    }
  }
  catch (RecognitionException &e) {
    _errHandler->reportError(this, e);
    _localctx->exception = std::current_exception();
    _errHandler->recover(this, _localctx->exception);
  }
  return _localctx;
}

//----------------- Compound_statementContext ------------------------------------------------------------------

C8086Parser::Compound_statementContext::Compound_statementContext(ParserRuleContext *parent, size_t invokingState)
  : ParserRuleContext(parent, invokingState) {
}

tree::TerminalNode* C8086Parser::Compound_statementContext::LCURL() {
  return getToken(C8086Parser::LCURL, 0);
}

C8086Parser::StatementsContext* C8086Parser::Compound_statementContext::statements() {
  return getRuleContext<C8086Parser::StatementsContext>(0);
}

tree::TerminalNode* C8086Parser::Compound_statementContext::RCURL() {
  return getToken(C8086Parser::RCURL, 0);
}


size_t C8086Parser::Compound_statementContext::getRuleIndex() const {
  return C8086Parser::RuleCompound_statement;
}

void C8086Parser::Compound_statementContext::enterRule(tree::ParseTreeListener *listener) {
  auto parserListener = dynamic_cast<C8086ParserListener *>(listener);
  if (parserListener != nullptr)
    parserListener->enterCompound_statement(this);
}

void C8086Parser::Compound_statementContext::exitRule(tree::ParseTreeListener *listener) {
  auto parserListener = dynamic_cast<C8086ParserListener *>(listener);
  if (parserListener != nullptr)
    parserListener->exitCompound_statement(this);
}

C8086Parser::Compound_statementContext* C8086Parser::compound_statement() {
  Compound_statementContext *_localctx = _tracker.createInstance<Compound_statementContext>(_ctx, getState());
  enterRule(_localctx, 12, C8086Parser::RuleCompound_statement);

#if __cplusplus > 201703L
  auto onExit = finally([=, this] {
#else
  auto onExit = finally([=] {
#endif
    exitRule();
  });
  try {
    setState(143);
    _errHandler->sync(this);
    switch (getInterpreter<atn::ParserATNSimulator>()->adaptivePredict(_input, 7, _ctx)) {
    case 1: {
      enterOuterAlt(_localctx, 1);
      setState(135);
      match(C8086Parser::LCURL);
      setState(136);
      antlrcpp::downCast<Compound_statementContext *>(_localctx)->ss = statements(0);
      setState(137);
      antlrcpp::downCast<Compound_statementContext *>(_localctx)->rc = match(C8086Parser::RCURL);

              antlrcpp::downCast<Compound_statementContext *>(_localctx)->line =  antlrcpp::downCast<Compound_statementContext *>(_localctx)->rc->getLine();
              antlrcpp::downCast<Compound_statementContext *>(_localctx)->code =  "{\n" + antlrcpp::downCast<Compound_statementContext *>(_localctx)->ss->code + "\n}";
              writeIntoparserLogFile("Line " + std::to_string(_localctx->line) + ": compound_statement : LCURL statements RCURL");
              writeIntoparserLogFile("");
              writeIntoparserLogFile(_localctx->code);
              writeIntoparserLogFile("");
          
      break;
    }

    case 2: {
      enterOuterAlt(_localctx, 2);
      setState(140);
      match(C8086Parser::LCURL);
      setState(141);
      antlrcpp::downCast<Compound_statementContext *>(_localctx)->rc = match(C8086Parser::RCURL);

              antlrcpp::downCast<Compound_statementContext *>(_localctx)->line =  antlrcpp::downCast<Compound_statementContext *>(_localctx)->rc->getLine();
              antlrcpp::downCast<Compound_statementContext *>(_localctx)->code =  "{\n}";
              writeIntoparserLogFile("Line " + std::to_string(_localctx->line) + ": compound_statement : LCURL RCURL");
              writeIntoparserLogFile("");
              writeIntoparserLogFile(_localctx->code);
              writeIntoparserLogFile("");
          
      break;
    }

    default:
      break;
    }
   
  }
  catch (RecognitionException &e) {
    _errHandler->reportError(this, e);
    _localctx->exception = std::current_exception();
    _errHandler->recover(this, _localctx->exception);
  }

  return _localctx;
}

//----------------- Var_declarationContext ------------------------------------------------------------------

C8086Parser::Var_declarationContext::Var_declarationContext(ParserRuleContext *parent, size_t invokingState)
  : ParserRuleContext(parent, invokingState) {
}

C8086Parser::Type_specifierContext* C8086Parser::Var_declarationContext::type_specifier() {
  return getRuleContext<C8086Parser::Type_specifierContext>(0);
}

C8086Parser::Declaration_listContext* C8086Parser::Var_declarationContext::declaration_list() {
  return getRuleContext<C8086Parser::Declaration_listContext>(0);
}

tree::TerminalNode* C8086Parser::Var_declarationContext::SEMICOLON() {
  return getToken(C8086Parser::SEMICOLON, 0);
}

C8086Parser::Declaration_list_errContext* C8086Parser::Var_declarationContext::declaration_list_err() {
  return getRuleContext<C8086Parser::Declaration_list_errContext>(0);
}


size_t C8086Parser::Var_declarationContext::getRuleIndex() const {
  return C8086Parser::RuleVar_declaration;
}

void C8086Parser::Var_declarationContext::enterRule(tree::ParseTreeListener *listener) {
  auto parserListener = dynamic_cast<C8086ParserListener *>(listener);
  if (parserListener != nullptr)
    parserListener->enterVar_declaration(this);
}

void C8086Parser::Var_declarationContext::exitRule(tree::ParseTreeListener *listener) {
  auto parserListener = dynamic_cast<C8086ParserListener *>(listener);
  if (parserListener != nullptr)
    parserListener->exitVar_declaration(this);
}

C8086Parser::Var_declarationContext* C8086Parser::var_declaration() {
  Var_declarationContext *_localctx = _tracker.createInstance<Var_declarationContext>(_ctx, getState());
  enterRule(_localctx, 14, C8086Parser::RuleVar_declaration);

#if __cplusplus > 201703L
  auto onExit = finally([=, this] {
#else
  auto onExit = finally([=] {
#endif
    exitRule();
  });
  try {
    setState(155);
    _errHandler->sync(this);
    switch (getInterpreter<atn::ParserATNSimulator>()->adaptivePredict(_input, 8, _ctx)) {
    case 1: {
      enterOuterAlt(_localctx, 1);
      setState(145);
      antlrcpp::downCast<Var_declarationContext *>(_localctx)->t = type_specifier();
      setState(146);
      antlrcpp::downCast<Var_declarationContext *>(_localctx)->dl = declaration_list(0);
      setState(147);
      antlrcpp::downCast<Var_declarationContext *>(_localctx)->sm = match(C8086Parser::SEMICOLON);

              antlrcpp::downCast<Var_declarationContext *>(_localctx)->line =  antlrcpp::downCast<Var_declarationContext *>(_localctx)->sm->getLine();
              antlrcpp::downCast<Var_declarationContext *>(_localctx)->code =  antlrcpp::downCast<Var_declarationContext *>(_localctx)->t->text + " " + antlrcpp::downCast<Var_declarationContext *>(_localctx)->dl->names + ";";
              writeIntoparserLogFile("Line " + std::to_string(_localctx->line) + ": var_declaration : type_specifier declaration_list SEMICOLON");
              writeIntoparserLogFile("");
              writeIntoparserLogFile(_localctx->code);
              writeIntoparserLogFile("");
          
      break;
    }

    case 2: {
      enterOuterAlt(_localctx, 2);
      setState(150);
      antlrcpp::downCast<Var_declarationContext *>(_localctx)->t = type_specifier();
      setState(151);
      antlrcpp::downCast<Var_declarationContext *>(_localctx)->de = declaration_list_err();
      setState(152);
      antlrcpp::downCast<Var_declarationContext *>(_localctx)->sm = match(C8086Parser::SEMICOLON);

              writeIntoErrorFile(
                  std::string("Line# ") + std::to_string(antlrcpp::downCast<Var_declarationContext *>(_localctx)->sm->getLine()) +
                  " with error name: " + antlrcpp::downCast<Var_declarationContext *>(_localctx)->de->error_name +
                  " - Syntax error at declaration list of variable declaration"
              );
              syntaxErrorCount++;
          
      break;
    }

    default:
      break;
    }
   
  }
  catch (RecognitionException &e) {
    _errHandler->reportError(this, e);
    _localctx->exception = std::current_exception();
    _errHandler->recover(this, _localctx->exception);
  }

  return _localctx;
}

//----------------- Declaration_list_errContext ------------------------------------------------------------------

C8086Parser::Declaration_list_errContext::Declaration_list_errContext(ParserRuleContext *parent, size_t invokingState)
  : ParserRuleContext(parent, invokingState) {
}


size_t C8086Parser::Declaration_list_errContext::getRuleIndex() const {
  return C8086Parser::RuleDeclaration_list_err;
}

void C8086Parser::Declaration_list_errContext::enterRule(tree::ParseTreeListener *listener) {
  auto parserListener = dynamic_cast<C8086ParserListener *>(listener);
  if (parserListener != nullptr)
    parserListener->enterDeclaration_list_err(this);
}

void C8086Parser::Declaration_list_errContext::exitRule(tree::ParseTreeListener *listener) {
  auto parserListener = dynamic_cast<C8086ParserListener *>(listener);
  if (parserListener != nullptr)
    parserListener->exitDeclaration_list_err(this);
}

C8086Parser::Declaration_list_errContext* C8086Parser::declaration_list_err() {
  Declaration_list_errContext *_localctx = _tracker.createInstance<Declaration_list_errContext>(_ctx, getState());
  enterRule(_localctx, 16, C8086Parser::RuleDeclaration_list_err);

#if __cplusplus > 201703L
  auto onExit = finally([=, this] {
#else
  auto onExit = finally([=] {
#endif
    exitRule();
  });
  try {
    enterOuterAlt(_localctx, 1);

            antlrcpp::downCast<Declaration_list_errContext *>(_localctx)->error_name =  "Error in declaration list";
        
   
  }
  catch (RecognitionException &e) {
    _errHandler->reportError(this, e);
    _localctx->exception = std::current_exception();
    _errHandler->recover(this, _localctx->exception);
  }

  return _localctx;
}

//----------------- Type_specifierContext ------------------------------------------------------------------

C8086Parser::Type_specifierContext::Type_specifierContext(ParserRuleContext *parent, size_t invokingState)
  : ParserRuleContext(parent, invokingState) {
}

tree::TerminalNode* C8086Parser::Type_specifierContext::INT() {
  return getToken(C8086Parser::INT, 0);
}

tree::TerminalNode* C8086Parser::Type_specifierContext::FLOAT() {
  return getToken(C8086Parser::FLOAT, 0);
}

tree::TerminalNode* C8086Parser::Type_specifierContext::VOID() {
  return getToken(C8086Parser::VOID, 0);
}


size_t C8086Parser::Type_specifierContext::getRuleIndex() const {
  return C8086Parser::RuleType_specifier;
}

void C8086Parser::Type_specifierContext::enterRule(tree::ParseTreeListener *listener) {
  auto parserListener = dynamic_cast<C8086ParserListener *>(listener);
  if (parserListener != nullptr)
    parserListener->enterType_specifier(this);
}

void C8086Parser::Type_specifierContext::exitRule(tree::ParseTreeListener *listener) {
  auto parserListener = dynamic_cast<C8086ParserListener *>(listener);
  if (parserListener != nullptr)
    parserListener->exitType_specifier(this);
}

C8086Parser::Type_specifierContext* C8086Parser::type_specifier() {
  Type_specifierContext *_localctx = _tracker.createInstance<Type_specifierContext>(_ctx, getState());
  enterRule(_localctx, 18, C8086Parser::RuleType_specifier);

#if __cplusplus > 201703L
  auto onExit = finally([=, this] {
#else
  auto onExit = finally([=] {
#endif
    exitRule();
  });
  try {
    setState(165);
    _errHandler->sync(this);
    switch (_input->LA(1)) {
      case C8086Parser::INT: {
        enterOuterAlt(_localctx, 1);
        setState(159);
        antlrcpp::downCast<Type_specifierContext *>(_localctx)->intToken = match(C8086Parser::INT);

                antlrcpp::downCast<Type_specifierContext *>(_localctx)->line =  antlrcpp::downCast<Type_specifierContext *>(_localctx)->intToken->getLine();
                antlrcpp::downCast<Type_specifierContext *>(_localctx)->name_line =  "type: INT at line" + std::to_string(_localctx->line);
                antlrcpp::downCast<Type_specifierContext *>(_localctx)->typeKeyword =  antlrcpp::downCast<Type_specifierContext *>(_localctx)->intToken->getText();
                antlrcpp::downCast<Type_specifierContext *>(_localctx)->text =  antlrcpp::downCast<Type_specifierContext *>(_localctx)->intToken->getText();
                writeIntoparserLogFile("Line " + std::to_string(_localctx->line) + ": type_specifier : INT");
                writeIntoparserLogFile(""); 
                writeIntoparserLogFile(_localctx->text);
                writeIntoparserLogFile(""); 
            
        break;
      }

      case C8086Parser::FLOAT: {
        enterOuterAlt(_localctx, 2);
        setState(161);
        antlrcpp::downCast<Type_specifierContext *>(_localctx)->floatToken = match(C8086Parser::FLOAT);

                antlrcpp::downCast<Type_specifierContext *>(_localctx)->line =  antlrcpp::downCast<Type_specifierContext *>(_localctx)->floatToken->getLine();
                antlrcpp::downCast<Type_specifierContext *>(_localctx)->name_line =  "type: FLOAT at line" + std::to_string(_localctx->line);
                antlrcpp::downCast<Type_specifierContext *>(_localctx)->typeKeyword =  antlrcpp::downCast<Type_specifierContext *>(_localctx)->floatToken->getText();
                antlrcpp::downCast<Type_specifierContext *>(_localctx)->text =  antlrcpp::downCast<Type_specifierContext *>(_localctx)->floatToken->getText();
                writeIntoparserLogFile("Line " + std::to_string(_localctx->line) + ": type_specifier : FLOAT");
                writeIntoparserLogFile(""); 
                writeIntoparserLogFile(_localctx->text);
                writeIntoparserLogFile(""); 
            
        break;
      }

      case C8086Parser::VOID: {
        enterOuterAlt(_localctx, 3);
        setState(163);
        antlrcpp::downCast<Type_specifierContext *>(_localctx)->voidToken = match(C8086Parser::VOID);

                antlrcpp::downCast<Type_specifierContext *>(_localctx)->line =  antlrcpp::downCast<Type_specifierContext *>(_localctx)->voidToken->getLine();
                antlrcpp::downCast<Type_specifierContext *>(_localctx)->name_line =  "type: VOID at line" + std::to_string(_localctx->line);
                antlrcpp::downCast<Type_specifierContext *>(_localctx)->typeKeyword =  antlrcpp::downCast<Type_specifierContext *>(_localctx)->voidToken->getText();
                antlrcpp::downCast<Type_specifierContext *>(_localctx)->text =  antlrcpp::downCast<Type_specifierContext *>(_localctx)->voidToken->getText();
                writeIntoparserLogFile("Line " + std::to_string(_localctx->line) + ": type_specifier : VOID");
                writeIntoparserLogFile(""); 
                writeIntoparserLogFile(_localctx->text);
                writeIntoparserLogFile(""); 
            
        break;
      }

    default:
      throw NoViableAltException(this);
    }
   
  }
  catch (RecognitionException &e) {
    _errHandler->reportError(this, e);
    _localctx->exception = std::current_exception();
    _errHandler->recover(this, _localctx->exception);
  }

  return _localctx;
}

//----------------- Declaration_listContext ------------------------------------------------------------------

C8086Parser::Declaration_listContext::Declaration_listContext(ParserRuleContext *parent, size_t invokingState)
  : ParserRuleContext(parent, invokingState) {
}

tree::TerminalNode* C8086Parser::Declaration_listContext::ID() {
  return getToken(C8086Parser::ID, 0);
}

tree::TerminalNode* C8086Parser::Declaration_listContext::LTHIRD() {
  return getToken(C8086Parser::LTHIRD, 0);
}

tree::TerminalNode* C8086Parser::Declaration_listContext::RTHIRD() {
  return getToken(C8086Parser::RTHIRD, 0);
}

tree::TerminalNode* C8086Parser::Declaration_listContext::CONST_INT() {
  return getToken(C8086Parser::CONST_INT, 0);
}

tree::TerminalNode* C8086Parser::Declaration_listContext::COMMA() {
  return getToken(C8086Parser::COMMA, 0);
}

C8086Parser::Declaration_listContext* C8086Parser::Declaration_listContext::declaration_list() {
  return getRuleContext<C8086Parser::Declaration_listContext>(0);
}


size_t C8086Parser::Declaration_listContext::getRuleIndex() const {
  return C8086Parser::RuleDeclaration_list;
}

void C8086Parser::Declaration_listContext::enterRule(tree::ParseTreeListener *listener) {
  auto parserListener = dynamic_cast<C8086ParserListener *>(listener);
  if (parserListener != nullptr)
    parserListener->enterDeclaration_list(this);
}

void C8086Parser::Declaration_listContext::exitRule(tree::ParseTreeListener *listener) {
  auto parserListener = dynamic_cast<C8086ParserListener *>(listener);
  if (parserListener != nullptr)
    parserListener->exitDeclaration_list(this);
}


C8086Parser::Declaration_listContext* C8086Parser::declaration_list() {
   return declaration_list(0);
}

C8086Parser::Declaration_listContext* C8086Parser::declaration_list(int precedence) {
  ParserRuleContext *parentContext = _ctx;
  size_t parentState = getState();
  C8086Parser::Declaration_listContext *_localctx = _tracker.createInstance<Declaration_listContext>(_ctx, parentState);
  C8086Parser::Declaration_listContext *previousContext = _localctx;
  (void)previousContext; // Silence compiler, in case the context is not used by generated code.
  size_t startState = 20;
  enterRecursionRule(_localctx, 20, C8086Parser::RuleDeclaration_list, precedence);

    

#if __cplusplus > 201703L
  auto onExit = finally([=, this] {
#else
  auto onExit = finally([=] {
#endif
    unrollRecursionContexts(parentContext);
  });
  try {
    size_t alt;
    enterOuterAlt(_localctx, 1);
    setState(175);
    _errHandler->sync(this);
    switch (getInterpreter<atn::ParserATNSimulator>()->adaptivePredict(_input, 10, _ctx)) {
    case 1: {
      setState(168);
      antlrcpp::downCast<Declaration_listContext *>(_localctx)->id1 = match(C8086Parser::ID);

              antlrcpp::downCast<Declaration_listContext *>(_localctx)->names =  antlrcpp::downCast<Declaration_listContext *>(_localctx)->id1->getText();
              writeIntoparserLogFile("Line " + std::to_string(antlrcpp::downCast<Declaration_listContext *>(_localctx)->id1->getLine()) + ": declaration_list : ID");
              writeIntoparserLogFile("");
              writeIntoparserLogFile(_localctx->names);
              writeIntoparserLogFile(""); 
          
      break;
    }

    case 2: {
      setState(170);
      antlrcpp::downCast<Declaration_listContext *>(_localctx)->id = match(C8086Parser::ID);
      setState(171);
      match(C8086Parser::LTHIRD);
      setState(172);
      antlrcpp::downCast<Declaration_listContext *>(_localctx)->ci = match(C8086Parser::CONST_INT);
      setState(173);
      match(C8086Parser::RTHIRD);

              antlrcpp::downCast<Declaration_listContext *>(_localctx)->names =  antlrcpp::downCast<Declaration_listContext *>(_localctx)->id->getText() + "[" + antlrcpp::downCast<Declaration_listContext *>(_localctx)->ci->getText() + "]";
              writeIntoparserLogFile("Line " + std::to_string(antlrcpp::downCast<Declaration_listContext *>(_localctx)->id->getLine()) + ": declaration_list : ID LTHIRD CONST_INT RTHIRD");
              writeIntoparserLogFile("");
              writeIntoparserLogFile(_localctx->names);
              writeIntoparserLogFile("");
          
      break;
    }

    default:
      break;
    }
    _ctx->stop = _input->LT(-1);
    setState(190);
    _errHandler->sync(this);
    alt = getInterpreter<atn::ParserATNSimulator>()->adaptivePredict(_input, 12, _ctx);
    while (alt != 2 && alt != atn::ATN::INVALID_ALT_NUMBER) {
      if (alt == 1) {
        if (!_parseListeners.empty())
          triggerExitRuleEvent();
        previousContext = _localctx;
        setState(188);
        _errHandler->sync(this);
        switch (getInterpreter<atn::ParserATNSimulator>()->adaptivePredict(_input, 11, _ctx)) {
        case 1: {
          _localctx = _tracker.createInstance<Declaration_listContext>(parentContext, parentState);
          _localctx->d = previousContext;
          pushNewRecursionContext(_localctx, startState, RuleDeclaration_list);
          setState(177);

          if (!(precpred(_ctx, 3))) throw FailedPredicateException(this, "precpred(_ctx, 3)");
          setState(178);
          match(C8086Parser::COMMA);
          setState(179);
          antlrcpp::downCast<Declaration_listContext *>(_localctx)->id2 = match(C8086Parser::ID);

                            antlrcpp::downCast<Declaration_listContext *>(_localctx)->names =  antlrcpp::downCast<Declaration_listContext *>(_localctx)->d->names + "," + antlrcpp::downCast<Declaration_listContext *>(_localctx)->id2->getText();
                            writeIntoparserLogFile("Line " + std::to_string(antlrcpp::downCast<Declaration_listContext *>(_localctx)->id2->getLine()) + ": declaration_list : declaration_list COMMA ID");
                            writeIntoparserLogFile("");
                            writeIntoparserLogFile(_localctx->names);
                            writeIntoparserLogFile(""); 
                        
          break;
        }

        case 2: {
          _localctx = _tracker.createInstance<Declaration_listContext>(parentContext, parentState);
          _localctx->dl = previousContext;
          pushNewRecursionContext(_localctx, startState, RuleDeclaration_list);
          setState(181);

          if (!(precpred(_ctx, 1))) throw FailedPredicateException(this, "precpred(_ctx, 1)");
          setState(182);
          match(C8086Parser::COMMA);
          setState(183);
          antlrcpp::downCast<Declaration_listContext *>(_localctx)->id = match(C8086Parser::ID);
          setState(184);
          match(C8086Parser::LTHIRD);
          setState(185);
          antlrcpp::downCast<Declaration_listContext *>(_localctx)->ci = match(C8086Parser::CONST_INT);
          setState(186);
          match(C8086Parser::RTHIRD);

                            antlrcpp::downCast<Declaration_listContext *>(_localctx)->names =  antlrcpp::downCast<Declaration_listContext *>(_localctx)->dl->names + "," + antlrcpp::downCast<Declaration_listContext *>(_localctx)->id->getText() + "[" + antlrcpp::downCast<Declaration_listContext *>(_localctx)->ci->getText() + "]";
                            writeIntoparserLogFile("Line " + std::to_string(antlrcpp::downCast<Declaration_listContext *>(_localctx)->id->getLine()) + ": declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD");
                            writeIntoparserLogFile("");
                            writeIntoparserLogFile(_localctx->names);
                            writeIntoparserLogFile("");
                        
          break;
        }

        default:
          break;
        } 
      }
      setState(192);
      _errHandler->sync(this);
      alt = getInterpreter<atn::ParserATNSimulator>()->adaptivePredict(_input, 12, _ctx);
    }
  }
  catch (RecognitionException &e) {
    _errHandler->reportError(this, e);
    _localctx->exception = std::current_exception();
    _errHandler->recover(this, _localctx->exception);
  }
  return _localctx;
}

//----------------- StatementsContext ------------------------------------------------------------------

C8086Parser::StatementsContext::StatementsContext(ParserRuleContext *parent, size_t invokingState)
  : ParserRuleContext(parent, invokingState) {
}

C8086Parser::StatementContext* C8086Parser::StatementsContext::statement() {
  return getRuleContext<C8086Parser::StatementContext>(0);
}

C8086Parser::StatementsContext* C8086Parser::StatementsContext::statements() {
  return getRuleContext<C8086Parser::StatementsContext>(0);
}


size_t C8086Parser::StatementsContext::getRuleIndex() const {
  return C8086Parser::RuleStatements;
}

void C8086Parser::StatementsContext::enterRule(tree::ParseTreeListener *listener) {
  auto parserListener = dynamic_cast<C8086ParserListener *>(listener);
  if (parserListener != nullptr)
    parserListener->enterStatements(this);
}

void C8086Parser::StatementsContext::exitRule(tree::ParseTreeListener *listener) {
  auto parserListener = dynamic_cast<C8086ParserListener *>(listener);
  if (parserListener != nullptr)
    parserListener->exitStatements(this);
}


C8086Parser::StatementsContext* C8086Parser::statements() {
   return statements(0);
}

C8086Parser::StatementsContext* C8086Parser::statements(int precedence) {
  ParserRuleContext *parentContext = _ctx;
  size_t parentState = getState();
  C8086Parser::StatementsContext *_localctx = _tracker.createInstance<StatementsContext>(_ctx, parentState);
  C8086Parser::StatementsContext *previousContext = _localctx;
  (void)previousContext; // Silence compiler, in case the context is not used by generated code.
  size_t startState = 22;
  enterRecursionRule(_localctx, 22, C8086Parser::RuleStatements, precedence);

    

#if __cplusplus > 201703L
  auto onExit = finally([=, this] {
#else
  auto onExit = finally([=] {
#endif
    unrollRecursionContexts(parentContext);
  });
  try {
    size_t alt;
    enterOuterAlt(_localctx, 1);
    setState(194);
    antlrcpp::downCast<StatementsContext *>(_localctx)->s = statement();

            antlrcpp::downCast<StatementsContext *>(_localctx)->code =  antlrcpp::downCast<StatementsContext *>(_localctx)->s->code;
            writeIntoparserLogFile("Line " + std::to_string(antlrcpp::downCast<StatementsContext *>(_localctx)->s->line) + ": statements : statement");
            writeIntoparserLogFile("");
            writeIntoparserLogFile(_localctx->code);
            writeIntoparserLogFile("");
        
    _ctx->stop = _input->LT(-1);
    setState(203);
    _errHandler->sync(this);
    alt = getInterpreter<atn::ParserATNSimulator>()->adaptivePredict(_input, 13, _ctx);
    while (alt != 2 && alt != atn::ATN::INVALID_ALT_NUMBER) {
      if (alt == 1) {
        if (!_parseListeners.empty())
          triggerExitRuleEvent();
        previousContext = _localctx;
        _localctx = _tracker.createInstance<StatementsContext>(parentContext, parentState);
        _localctx->ss = previousContext;
        pushNewRecursionContext(_localctx, startState, RuleStatements);
        setState(197);

        if (!(precpred(_ctx, 1))) throw FailedPredicateException(this, "precpred(_ctx, 1)");
        setState(198);
        antlrcpp::downCast<StatementsContext *>(_localctx)->s = statement();

                          antlrcpp::downCast<StatementsContext *>(_localctx)->code =  antlrcpp::downCast<StatementsContext *>(_localctx)->ss->code + "\n" + antlrcpp::downCast<StatementsContext *>(_localctx)->s->code;
                          writeIntoparserLogFile("Line " + std::to_string(antlrcpp::downCast<StatementsContext *>(_localctx)->s->line) + ": statements : statements statement");
                          writeIntoparserLogFile("");
                          writeIntoparserLogFile(_localctx->code);
                          writeIntoparserLogFile("");
                       
      }
      setState(205);
      _errHandler->sync(this);
      alt = getInterpreter<atn::ParserATNSimulator>()->adaptivePredict(_input, 13, _ctx);
    }
  }
  catch (RecognitionException &e) {
    _errHandler->reportError(this, e);
    _localctx->exception = std::current_exception();
    _errHandler->recover(this, _localctx->exception);
  }
  return _localctx;
}

//----------------- StatementContext ------------------------------------------------------------------

C8086Parser::StatementContext::StatementContext(ParserRuleContext *parent, size_t invokingState)
  : ParserRuleContext(parent, invokingState) {
}

C8086Parser::Var_declarationContext* C8086Parser::StatementContext::var_declaration() {
  return getRuleContext<C8086Parser::Var_declarationContext>(0);
}

std::vector<C8086Parser::Expression_statementContext *> C8086Parser::StatementContext::expression_statement() {
  return getRuleContexts<C8086Parser::Expression_statementContext>();
}

C8086Parser::Expression_statementContext* C8086Parser::StatementContext::expression_statement(size_t i) {
  return getRuleContext<C8086Parser::Expression_statementContext>(i);
}

C8086Parser::Compound_statementContext* C8086Parser::StatementContext::compound_statement() {
  return getRuleContext<C8086Parser::Compound_statementContext>(0);
}

tree::TerminalNode* C8086Parser::StatementContext::FOR() {
  return getToken(C8086Parser::FOR, 0);
}

tree::TerminalNode* C8086Parser::StatementContext::LPAREN() {
  return getToken(C8086Parser::LPAREN, 0);
}

tree::TerminalNode* C8086Parser::StatementContext::RPAREN() {
  return getToken(C8086Parser::RPAREN, 0);
}

C8086Parser::ExpressionContext* C8086Parser::StatementContext::expression() {
  return getRuleContext<C8086Parser::ExpressionContext>(0);
}

std::vector<C8086Parser::StatementContext *> C8086Parser::StatementContext::statement() {
  return getRuleContexts<C8086Parser::StatementContext>();
}

C8086Parser::StatementContext* C8086Parser::StatementContext::statement(size_t i) {
  return getRuleContext<C8086Parser::StatementContext>(i);
}

tree::TerminalNode* C8086Parser::StatementContext::IF() {
  return getToken(C8086Parser::IF, 0);
}

tree::TerminalNode* C8086Parser::StatementContext::ELSE() {
  return getToken(C8086Parser::ELSE, 0);
}

tree::TerminalNode* C8086Parser::StatementContext::WHILE() {
  return getToken(C8086Parser::WHILE, 0);
}

tree::TerminalNode* C8086Parser::StatementContext::PRINTLN() {
  return getToken(C8086Parser::PRINTLN, 0);
}

tree::TerminalNode* C8086Parser::StatementContext::ID() {
  return getToken(C8086Parser::ID, 0);
}

tree::TerminalNode* C8086Parser::StatementContext::SEMICOLON() {
  return getToken(C8086Parser::SEMICOLON, 0);
}

tree::TerminalNode* C8086Parser::StatementContext::RETURN() {
  return getToken(C8086Parser::RETURN, 0);
}


size_t C8086Parser::StatementContext::getRuleIndex() const {
  return C8086Parser::RuleStatement;
}

void C8086Parser::StatementContext::enterRule(tree::ParseTreeListener *listener) {
  auto parserListener = dynamic_cast<C8086ParserListener *>(listener);
  if (parserListener != nullptr)
    parserListener->enterStatement(this);
}

void C8086Parser::StatementContext::exitRule(tree::ParseTreeListener *listener) {
  auto parserListener = dynamic_cast<C8086ParserListener *>(listener);
  if (parserListener != nullptr)
    parserListener->exitStatement(this);
}

C8086Parser::StatementContext* C8086Parser::statement() {
  StatementContext *_localctx = _tracker.createInstance<StatementContext>(_ctx, getState());
  enterRule(_localctx, 24, C8086Parser::RuleStatement);

#if __cplusplus > 201703L
  auto onExit = finally([=, this] {
#else
  auto onExit = finally([=] {
#endif
    exitRule();
  });
  try {
    setState(258);
    _errHandler->sync(this);
    switch (getInterpreter<atn::ParserATNSimulator>()->adaptivePredict(_input, 14, _ctx)) {
    case 1: {
      enterOuterAlt(_localctx, 1);
      setState(206);
      antlrcpp::downCast<StatementContext *>(_localctx)->vd = var_declaration();

              antlrcpp::downCast<StatementContext *>(_localctx)->code =  antlrcpp::downCast<StatementContext *>(_localctx)->vd->code;
              antlrcpp::downCast<StatementContext *>(_localctx)->line =  antlrcpp::downCast<StatementContext *>(_localctx)->vd->line;
              writeIntoparserLogFile("Line " + std::to_string(_localctx->line) + ": statement : var_declaration");
              writeIntoparserLogFile("");
              writeIntoparserLogFile(_localctx->code);
              writeIntoparserLogFile("");
          
      break;
    }

    case 2: {
      enterOuterAlt(_localctx, 2);
      setState(209);
      antlrcpp::downCast<StatementContext *>(_localctx)->es = expression_statement();

              antlrcpp::downCast<StatementContext *>(_localctx)->code =  antlrcpp::downCast<StatementContext *>(_localctx)->es->code;
              antlrcpp::downCast<StatementContext *>(_localctx)->line =  antlrcpp::downCast<StatementContext *>(_localctx)->es->line;
              writeIntoparserLogFile("Line " + std::to_string(_localctx->line) + ": statement : expression_statement");
              writeIntoparserLogFile("");
              writeIntoparserLogFile(_localctx->code);
              writeIntoparserLogFile("");
          
      break;
    }

    case 3: {
      enterOuterAlt(_localctx, 3);
      setState(212);
      antlrcpp::downCast<StatementContext *>(_localctx)->cs = compound_statement();

              antlrcpp::downCast<StatementContext *>(_localctx)->code =  antlrcpp::downCast<StatementContext *>(_localctx)->cs->code;
              antlrcpp::downCast<StatementContext *>(_localctx)->line =  antlrcpp::downCast<StatementContext *>(_localctx)->cs->line;
              writeIntoparserLogFile("Line " + std::to_string(_localctx->line) + ": statement : compound_statement");
              writeIntoparserLogFile("");
              writeIntoparserLogFile(_localctx->code);
              writeIntoparserLogFile("");
          
      break;
    }

    case 4: {
      enterOuterAlt(_localctx, 4);
      setState(215);
      antlrcpp::downCast<StatementContext *>(_localctx)->forToken = match(C8086Parser::FOR);
      setState(216);
      match(C8086Parser::LPAREN);
      setState(217);
      antlrcpp::downCast<StatementContext *>(_localctx)->es1 = expression_statement();
      setState(218);
      antlrcpp::downCast<StatementContext *>(_localctx)->es2 = expression_statement();
      setState(219);
      antlrcpp::downCast<StatementContext *>(_localctx)->e = expression();
      setState(220);
      match(C8086Parser::RPAREN);
      setState(221);
      antlrcpp::downCast<StatementContext *>(_localctx)->s = statement();

              antlrcpp::downCast<StatementContext *>(_localctx)->line =  antlrcpp::downCast<StatementContext *>(_localctx)->forToken->getLine();
              antlrcpp::downCast<StatementContext *>(_localctx)->code =  "for(" + antlrcpp::downCast<StatementContext *>(_localctx)->es1->code + antlrcpp::downCast<StatementContext *>(_localctx)->es2->code + antlrcpp::downCast<StatementContext *>(_localctx)->e->code + ")" + antlrcpp::downCast<StatementContext *>(_localctx)->s->code;
              writeIntoparserLogFile("Line " + std::to_string(_localctx->line) + ": statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement");
              writeIntoparserLogFile("");
              writeIntoparserLogFile(_localctx->code);
              writeIntoparserLogFile("");
          
      break;
    }

    case 5: {
      enterOuterAlt(_localctx, 5);
      setState(224);
      antlrcpp::downCast<StatementContext *>(_localctx)->ifToken = match(C8086Parser::IF);
      setState(225);
      match(C8086Parser::LPAREN);
      setState(226);
      antlrcpp::downCast<StatementContext *>(_localctx)->e = expression();
      setState(227);
      match(C8086Parser::RPAREN);
      setState(228);
      antlrcpp::downCast<StatementContext *>(_localctx)->s = statement();

              antlrcpp::downCast<StatementContext *>(_localctx)->line =  antlrcpp::downCast<StatementContext *>(_localctx)->ifToken->getLine();
              antlrcpp::downCast<StatementContext *>(_localctx)->code =  "if(" + antlrcpp::downCast<StatementContext *>(_localctx)->e->code + ")" + antlrcpp::downCast<StatementContext *>(_localctx)->s->code;
              writeIntoparserLogFile("Line " + std::to_string(_localctx->line) + ": statement : IF LPAREN expression RPAREN statement");
              writeIntoparserLogFile("");
              writeIntoparserLogFile(_localctx->code);
              writeIntoparserLogFile("");
          
      break;
    }

    case 6: {
      enterOuterAlt(_localctx, 6);
      setState(231);
      antlrcpp::downCast<StatementContext *>(_localctx)->ifToken = match(C8086Parser::IF);
      setState(232);
      match(C8086Parser::LPAREN);
      setState(233);
      antlrcpp::downCast<StatementContext *>(_localctx)->e = expression();
      setState(234);
      match(C8086Parser::RPAREN);
      setState(235);
      antlrcpp::downCast<StatementContext *>(_localctx)->s1 = statement();
      setState(236);
      match(C8086Parser::ELSE);
      setState(237);
      antlrcpp::downCast<StatementContext *>(_localctx)->s2 = statement();

              antlrcpp::downCast<StatementContext *>(_localctx)->line =  antlrcpp::downCast<StatementContext *>(_localctx)->ifToken->getLine();
              antlrcpp::downCast<StatementContext *>(_localctx)->code =  "if(" + antlrcpp::downCast<StatementContext *>(_localctx)->e->code + ")" + antlrcpp::downCast<StatementContext *>(_localctx)->s1->code + "else" + antlrcpp::downCast<StatementContext *>(_localctx)->s2->code;
              writeIntoparserLogFile("Line " + std::to_string(_localctx->line) + ": statement : IF LPAREN expression RPAREN statement ELSE statement");
              writeIntoparserLogFile("");
              writeIntoparserLogFile(_localctx->code);
              writeIntoparserLogFile("");
          
      break;
    }

    case 7: {
      enterOuterAlt(_localctx, 7);
      setState(240);
      antlrcpp::downCast<StatementContext *>(_localctx)->whileToken = match(C8086Parser::WHILE);
      setState(241);
      match(C8086Parser::LPAREN);
      setState(242);
      antlrcpp::downCast<StatementContext *>(_localctx)->e = expression();
      setState(243);
      match(C8086Parser::RPAREN);
      setState(244);
      antlrcpp::downCast<StatementContext *>(_localctx)->s = statement();

              antlrcpp::downCast<StatementContext *>(_localctx)->line =  antlrcpp::downCast<StatementContext *>(_localctx)->whileToken->getLine();
              antlrcpp::downCast<StatementContext *>(_localctx)->code =  "while(" + antlrcpp::downCast<StatementContext *>(_localctx)->e->code + ")" + antlrcpp::downCast<StatementContext *>(_localctx)->s->code;
              writeIntoparserLogFile("Line " + std::to_string(_localctx->line) + ": statement : WHILE LPAREN expression RPAREN statement");
              writeIntoparserLogFile("");
              writeIntoparserLogFile(_localctx->code);
              writeIntoparserLogFile("");
          
      break;
    }

    case 8: {
      enterOuterAlt(_localctx, 8);
      setState(247);
      match(C8086Parser::PRINTLN);
      setState(248);
      match(C8086Parser::LPAREN);
      setState(249);
      antlrcpp::downCast<StatementContext *>(_localctx)->id = match(C8086Parser::ID);
      setState(250);
      match(C8086Parser::RPAREN);
      setState(251);
      antlrcpp::downCast<StatementContext *>(_localctx)->sm = match(C8086Parser::SEMICOLON);

              antlrcpp::downCast<StatementContext *>(_localctx)->line =  antlrcpp::downCast<StatementContext *>(_localctx)->sm->getLine();
              antlrcpp::downCast<StatementContext *>(_localctx)->code =  "println(" + antlrcpp::downCast<StatementContext *>(_localctx)->id->getText() + ");";
              writeIntoparserLogFile("Line " + std::to_string(_localctx->line) + ": statement : PRINTLN LPAREN ID RPAREN SEMICOLON");
              writeIntoparserLogFile("");
              writeIntoparserLogFile(_localctx->code);
              writeIntoparserLogFile("");
          
      break;
    }

    case 9: {
      enterOuterAlt(_localctx, 9);
      setState(253);
      match(C8086Parser::RETURN);
      setState(254);
      antlrcpp::downCast<StatementContext *>(_localctx)->e = expression();
      setState(255);
      antlrcpp::downCast<StatementContext *>(_localctx)->sm = match(C8086Parser::SEMICOLON);

              antlrcpp::downCast<StatementContext *>(_localctx)->line =  antlrcpp::downCast<StatementContext *>(_localctx)->sm->getLine();
              antlrcpp::downCast<StatementContext *>(_localctx)->code =  "return " + antlrcpp::downCast<StatementContext *>(_localctx)->e->code + ";";
              writeIntoparserLogFile("Line " + std::to_string(_localctx->line) + ": statement : RETURN expression SEMICOLON");
              writeIntoparserLogFile("");
              writeIntoparserLogFile(_localctx->code);
              writeIntoparserLogFile("");
          
      break;
    }

    default:
      break;
    }
   
  }
  catch (RecognitionException &e) {
    _errHandler->reportError(this, e);
    _localctx->exception = std::current_exception();
    _errHandler->recover(this, _localctx->exception);
  }

  return _localctx;
}

//----------------- Expression_statementContext ------------------------------------------------------------------

C8086Parser::Expression_statementContext::Expression_statementContext(ParserRuleContext *parent, size_t invokingState)
  : ParserRuleContext(parent, invokingState) {
}

tree::TerminalNode* C8086Parser::Expression_statementContext::SEMICOLON() {
  return getToken(C8086Parser::SEMICOLON, 0);
}

C8086Parser::ExpressionContext* C8086Parser::Expression_statementContext::expression() {
  return getRuleContext<C8086Parser::ExpressionContext>(0);
}


size_t C8086Parser::Expression_statementContext::getRuleIndex() const {
  return C8086Parser::RuleExpression_statement;
}

void C8086Parser::Expression_statementContext::enterRule(tree::ParseTreeListener *listener) {
  auto parserListener = dynamic_cast<C8086ParserListener *>(listener);
  if (parserListener != nullptr)
    parserListener->enterExpression_statement(this);
}

void C8086Parser::Expression_statementContext::exitRule(tree::ParseTreeListener *listener) {
  auto parserListener = dynamic_cast<C8086ParserListener *>(listener);
  if (parserListener != nullptr)
    parserListener->exitExpression_statement(this);
}

C8086Parser::Expression_statementContext* C8086Parser::expression_statement() {
  Expression_statementContext *_localctx = _tracker.createInstance<Expression_statementContext>(_ctx, getState());
  enterRule(_localctx, 26, C8086Parser::RuleExpression_statement);

#if __cplusplus > 201703L
  auto onExit = finally([=, this] {
#else
  auto onExit = finally([=] {
#endif
    exitRule();
  });
  try {
    setState(266);
    _errHandler->sync(this);
    switch (_input->LA(1)) {
      case C8086Parser::SEMICOLON: {
        enterOuterAlt(_localctx, 1);
        setState(260);
        antlrcpp::downCast<Expression_statementContext *>(_localctx)->sm = match(C8086Parser::SEMICOLON);

                antlrcpp::downCast<Expression_statementContext *>(_localctx)->line =  antlrcpp::downCast<Expression_statementContext *>(_localctx)->sm->getLine();
                antlrcpp::downCast<Expression_statementContext *>(_localctx)->code =  ";";
                writeIntoparserLogFile("Line " + std::to_string(_localctx->line) + ": expression_statement : SEMICOLON");
                writeIntoparserLogFile("");
                writeIntoparserLogFile(_localctx->code);
                writeIntoparserLogFile("");
            
        break;
      }

      case C8086Parser::LPAREN:
      case C8086Parser::ADDOP:
      case C8086Parser::NOT:
      case C8086Parser::ID:
      case C8086Parser::CONST_INT:
      case C8086Parser::CONST_FLOAT: {
        enterOuterAlt(_localctx, 2);
        setState(262);
        antlrcpp::downCast<Expression_statementContext *>(_localctx)->e = expression();
        setState(263);
        antlrcpp::downCast<Expression_statementContext *>(_localctx)->sm = match(C8086Parser::SEMICOLON);

                antlrcpp::downCast<Expression_statementContext *>(_localctx)->line =  antlrcpp::downCast<Expression_statementContext *>(_localctx)->sm->getLine();
                antlrcpp::downCast<Expression_statementContext *>(_localctx)->code =  antlrcpp::downCast<Expression_statementContext *>(_localctx)->e->code + ";";
                writeIntoparserLogFile("Line " + std::to_string(_localctx->line) + ": expression_statement : expression SEMICOLON");
                writeIntoparserLogFile("");
                writeIntoparserLogFile(_localctx->code);
                writeIntoparserLogFile("");
            
        break;
      }

    default:
      throw NoViableAltException(this);
    }
   
  }
  catch (RecognitionException &e) {
    _errHandler->reportError(this, e);
    _localctx->exception = std::current_exception();
    _errHandler->recover(this, _localctx->exception);
  }

  return _localctx;
}

//----------------- VariableContext ------------------------------------------------------------------

C8086Parser::VariableContext::VariableContext(ParserRuleContext *parent, size_t invokingState)
  : ParserRuleContext(parent, invokingState) {
}

tree::TerminalNode* C8086Parser::VariableContext::ID() {
  return getToken(C8086Parser::ID, 0);
}

tree::TerminalNode* C8086Parser::VariableContext::LTHIRD() {
  return getToken(C8086Parser::LTHIRD, 0);
}

tree::TerminalNode* C8086Parser::VariableContext::RTHIRD() {
  return getToken(C8086Parser::RTHIRD, 0);
}

C8086Parser::ExpressionContext* C8086Parser::VariableContext::expression() {
  return getRuleContext<C8086Parser::ExpressionContext>(0);
}


size_t C8086Parser::VariableContext::getRuleIndex() const {
  return C8086Parser::RuleVariable;
}

void C8086Parser::VariableContext::enterRule(tree::ParseTreeListener *listener) {
  auto parserListener = dynamic_cast<C8086ParserListener *>(listener);
  if (parserListener != nullptr)
    parserListener->enterVariable(this);
}

void C8086Parser::VariableContext::exitRule(tree::ParseTreeListener *listener) {
  auto parserListener = dynamic_cast<C8086ParserListener *>(listener);
  if (parserListener != nullptr)
    parserListener->exitVariable(this);
}

C8086Parser::VariableContext* C8086Parser::variable() {
  VariableContext *_localctx = _tracker.createInstance<VariableContext>(_ctx, getState());
  enterRule(_localctx, 28, C8086Parser::RuleVariable);

#if __cplusplus > 201703L
  auto onExit = finally([=, this] {
#else
  auto onExit = finally([=] {
#endif
    exitRule();
  });
  try {
    setState(276);
    _errHandler->sync(this);
    switch (getInterpreter<atn::ParserATNSimulator>()->adaptivePredict(_input, 16, _ctx)) {
    case 1: {
      enterOuterAlt(_localctx, 1);
      setState(268);
      antlrcpp::downCast<VariableContext *>(_localctx)->id = match(C8086Parser::ID);

              antlrcpp::downCast<VariableContext *>(_localctx)->line =  antlrcpp::downCast<VariableContext *>(_localctx)->id->getLine();
              antlrcpp::downCast<VariableContext *>(_localctx)->code =  antlrcpp::downCast<VariableContext *>(_localctx)->id->getText();
              writeIntoparserLogFile("Line " + std::to_string(_localctx->line) + ": variable : ID");
              writeIntoparserLogFile("");
              writeIntoparserLogFile(_localctx->code);
              writeIntoparserLogFile("");
          
      break;
    }

    case 2: {
      enterOuterAlt(_localctx, 2);
      setState(270);
      antlrcpp::downCast<VariableContext *>(_localctx)->id = match(C8086Parser::ID);
      setState(271);
      match(C8086Parser::LTHIRD);
      setState(272);
      antlrcpp::downCast<VariableContext *>(_localctx)->e = expression();
      setState(273);
      match(C8086Parser::RTHIRD);

              antlrcpp::downCast<VariableContext *>(_localctx)->line =  antlrcpp::downCast<VariableContext *>(_localctx)->id->getLine();
              antlrcpp::downCast<VariableContext *>(_localctx)->code =  antlrcpp::downCast<VariableContext *>(_localctx)->id->getText() + "[" + antlrcpp::downCast<VariableContext *>(_localctx)->e->code + "]";
              writeIntoparserLogFile("Line " + std::to_string(_localctx->line) + ": variable : ID LTHIRD expression RTHIRD");
              writeIntoparserLogFile("");
              writeIntoparserLogFile(_localctx->code);
              writeIntoparserLogFile("");
          
      break;
    }

    default:
      break;
    }
   
  }
  catch (RecognitionException &e) {
    _errHandler->reportError(this, e);
    _localctx->exception = std::current_exception();
    _errHandler->recover(this, _localctx->exception);
  }

  return _localctx;
}

//----------------- ExpressionContext ------------------------------------------------------------------

C8086Parser::ExpressionContext::ExpressionContext(ParserRuleContext *parent, size_t invokingState)
  : ParserRuleContext(parent, invokingState) {
}

C8086Parser::Logic_expressionContext* C8086Parser::ExpressionContext::logic_expression() {
  return getRuleContext<C8086Parser::Logic_expressionContext>(0);
}

tree::TerminalNode* C8086Parser::ExpressionContext::ASSIGNOP() {
  return getToken(C8086Parser::ASSIGNOP, 0);
}

C8086Parser::VariableContext* C8086Parser::ExpressionContext::variable() {
  return getRuleContext<C8086Parser::VariableContext>(0);
}


size_t C8086Parser::ExpressionContext::getRuleIndex() const {
  return C8086Parser::RuleExpression;
}

void C8086Parser::ExpressionContext::enterRule(tree::ParseTreeListener *listener) {
  auto parserListener = dynamic_cast<C8086ParserListener *>(listener);
  if (parserListener != nullptr)
    parserListener->enterExpression(this);
}

void C8086Parser::ExpressionContext::exitRule(tree::ParseTreeListener *listener) {
  auto parserListener = dynamic_cast<C8086ParserListener *>(listener);
  if (parserListener != nullptr)
    parserListener->exitExpression(this);
}

C8086Parser::ExpressionContext* C8086Parser::expression() {
  ExpressionContext *_localctx = _tracker.createInstance<ExpressionContext>(_ctx, getState());
  enterRule(_localctx, 30, C8086Parser::RuleExpression);

#if __cplusplus > 201703L
  auto onExit = finally([=, this] {
#else
  auto onExit = finally([=] {
#endif
    exitRule();
  });
  try {
    setState(286);
    _errHandler->sync(this);
    switch (getInterpreter<atn::ParserATNSimulator>()->adaptivePredict(_input, 17, _ctx)) {
    case 1: {
      enterOuterAlt(_localctx, 1);
      setState(278);
      antlrcpp::downCast<ExpressionContext *>(_localctx)->le = logic_expression();

              antlrcpp::downCast<ExpressionContext *>(_localctx)->code =  antlrcpp::downCast<ExpressionContext *>(_localctx)->le->code; 
              antlrcpp::downCast<ExpressionContext *>(_localctx)->line =  antlrcpp::downCast<ExpressionContext *>(_localctx)->le->line;
              writeIntoparserLogFile("Line " + std::to_string(_localctx->line) + ": expression : logic_expression");
              writeIntoparserLogFile("");
              writeIntoparserLogFile(_localctx->code);
              writeIntoparserLogFile("");
          
      break;
    }

    case 2: {
      enterOuterAlt(_localctx, 2);
      setState(281);
      antlrcpp::downCast<ExpressionContext *>(_localctx)->v = variable();
      setState(282);
      match(C8086Parser::ASSIGNOP);
      setState(283);
      antlrcpp::downCast<ExpressionContext *>(_localctx)->le = logic_expression();

              antlrcpp::downCast<ExpressionContext *>(_localctx)->line =  antlrcpp::downCast<ExpressionContext *>(_localctx)->v->line;
              antlrcpp::downCast<ExpressionContext *>(_localctx)->code =  antlrcpp::downCast<ExpressionContext *>(_localctx)->v->code + "=" + antlrcpp::downCast<ExpressionContext *>(_localctx)->le->code;
              writeIntoparserLogFile("Line " + std::to_string(_localctx->line) + ": expression : variable ASSIGNOP logic_expression");
              writeIntoparserLogFile("");
              writeIntoparserLogFile(_localctx->code);
              writeIntoparserLogFile("");
          
      break;
    }

    default:
      break;
    }
   
  }
  catch (RecognitionException &e) {
    _errHandler->reportError(this, e);
    _localctx->exception = std::current_exception();
    _errHandler->recover(this, _localctx->exception);
  }

  return _localctx;
}

//----------------- Logic_expressionContext ------------------------------------------------------------------

C8086Parser::Logic_expressionContext::Logic_expressionContext(ParserRuleContext *parent, size_t invokingState)
  : ParserRuleContext(parent, invokingState) {
}

std::vector<C8086Parser::Rel_expressionContext *> C8086Parser::Logic_expressionContext::rel_expression() {
  return getRuleContexts<C8086Parser::Rel_expressionContext>();
}

C8086Parser::Rel_expressionContext* C8086Parser::Logic_expressionContext::rel_expression(size_t i) {
  return getRuleContext<C8086Parser::Rel_expressionContext>(i);
}

tree::TerminalNode* C8086Parser::Logic_expressionContext::LOGICOP() {
  return getToken(C8086Parser::LOGICOP, 0);
}


size_t C8086Parser::Logic_expressionContext::getRuleIndex() const {
  return C8086Parser::RuleLogic_expression;
}

void C8086Parser::Logic_expressionContext::enterRule(tree::ParseTreeListener *listener) {
  auto parserListener = dynamic_cast<C8086ParserListener *>(listener);
  if (parserListener != nullptr)
    parserListener->enterLogic_expression(this);
}

void C8086Parser::Logic_expressionContext::exitRule(tree::ParseTreeListener *listener) {
  auto parserListener = dynamic_cast<C8086ParserListener *>(listener);
  if (parserListener != nullptr)
    parserListener->exitLogic_expression(this);
}

C8086Parser::Logic_expressionContext* C8086Parser::logic_expression() {
  Logic_expressionContext *_localctx = _tracker.createInstance<Logic_expressionContext>(_ctx, getState());
  enterRule(_localctx, 32, C8086Parser::RuleLogic_expression);

#if __cplusplus > 201703L
  auto onExit = finally([=, this] {
#else
  auto onExit = finally([=] {
#endif
    exitRule();
  });
  try {
    setState(296);
    _errHandler->sync(this);
    switch (getInterpreter<atn::ParserATNSimulator>()->adaptivePredict(_input, 18, _ctx)) {
    case 1: {
      enterOuterAlt(_localctx, 1);
      setState(288);
      antlrcpp::downCast<Logic_expressionContext *>(_localctx)->re = rel_expression();

              antlrcpp::downCast<Logic_expressionContext *>(_localctx)->code =  antlrcpp::downCast<Logic_expressionContext *>(_localctx)->re->code;
              antlrcpp::downCast<Logic_expressionContext *>(_localctx)->line =  antlrcpp::downCast<Logic_expressionContext *>(_localctx)->re->line;
              writeIntoparserLogFile("Line " + std::to_string(_localctx->line) + ": logic_expression : rel_expression");
              writeIntoparserLogFile("");
              writeIntoparserLogFile(_localctx->code);
              writeIntoparserLogFile("");
          
      break;
    }

    case 2: {
      enterOuterAlt(_localctx, 2);
      setState(291);
      antlrcpp::downCast<Logic_expressionContext *>(_localctx)->re1 = rel_expression();
      setState(292);
      antlrcpp::downCast<Logic_expressionContext *>(_localctx)->op = match(C8086Parser::LOGICOP);
      setState(293);
      antlrcpp::downCast<Logic_expressionContext *>(_localctx)->re2 = rel_expression();

              antlrcpp::downCast<Logic_expressionContext *>(_localctx)->line =  antlrcpp::downCast<Logic_expressionContext *>(_localctx)->re1->line;
              antlrcpp::downCast<Logic_expressionContext *>(_localctx)->code =  antlrcpp::downCast<Logic_expressionContext *>(_localctx)->re1->code + antlrcpp::downCast<Logic_expressionContext *>(_localctx)->op->getText() + antlrcpp::downCast<Logic_expressionContext *>(_localctx)->re2->code;
              writeIntoparserLogFile("Line " + std::to_string(_localctx->line) + ": logic_expression : rel_expression LOGICOP rel_expression");
              writeIntoparserLogFile("");
              writeIntoparserLogFile(_localctx->code);
              writeIntoparserLogFile("");
          
      break;
    }

    default:
      break;
    }
   
  }
  catch (RecognitionException &e) {
    _errHandler->reportError(this, e);
    _localctx->exception = std::current_exception();
    _errHandler->recover(this, _localctx->exception);
  }

  return _localctx;
}

//----------------- Rel_expressionContext ------------------------------------------------------------------

C8086Parser::Rel_expressionContext::Rel_expressionContext(ParserRuleContext *parent, size_t invokingState)
  : ParserRuleContext(parent, invokingState) {
}

std::vector<C8086Parser::Simple_expressionContext *> C8086Parser::Rel_expressionContext::simple_expression() {
  return getRuleContexts<C8086Parser::Simple_expressionContext>();
}

C8086Parser::Simple_expressionContext* C8086Parser::Rel_expressionContext::simple_expression(size_t i) {
  return getRuleContext<C8086Parser::Simple_expressionContext>(i);
}

tree::TerminalNode* C8086Parser::Rel_expressionContext::RELOP() {
  return getToken(C8086Parser::RELOP, 0);
}


size_t C8086Parser::Rel_expressionContext::getRuleIndex() const {
  return C8086Parser::RuleRel_expression;
}

void C8086Parser::Rel_expressionContext::enterRule(tree::ParseTreeListener *listener) {
  auto parserListener = dynamic_cast<C8086ParserListener *>(listener);
  if (parserListener != nullptr)
    parserListener->enterRel_expression(this);
}

void C8086Parser::Rel_expressionContext::exitRule(tree::ParseTreeListener *listener) {
  auto parserListener = dynamic_cast<C8086ParserListener *>(listener);
  if (parserListener != nullptr)
    parserListener->exitRel_expression(this);
}

C8086Parser::Rel_expressionContext* C8086Parser::rel_expression() {
  Rel_expressionContext *_localctx = _tracker.createInstance<Rel_expressionContext>(_ctx, getState());
  enterRule(_localctx, 34, C8086Parser::RuleRel_expression);

#if __cplusplus > 201703L
  auto onExit = finally([=, this] {
#else
  auto onExit = finally([=] {
#endif
    exitRule();
  });
  try {
    setState(306);
    _errHandler->sync(this);
    switch (getInterpreter<atn::ParserATNSimulator>()->adaptivePredict(_input, 19, _ctx)) {
    case 1: {
      enterOuterAlt(_localctx, 1);
      setState(298);
      antlrcpp::downCast<Rel_expressionContext *>(_localctx)->se = simple_expression(0);

              antlrcpp::downCast<Rel_expressionContext *>(_localctx)->code =  antlrcpp::downCast<Rel_expressionContext *>(_localctx)->se->code;
              antlrcpp::downCast<Rel_expressionContext *>(_localctx)->line =  antlrcpp::downCast<Rel_expressionContext *>(_localctx)->se->line;
              writeIntoparserLogFile("Line " + std::to_string(_localctx->line) + ": rel_expression : simple_expression");
              writeIntoparserLogFile("");
              writeIntoparserLogFile(_localctx->code);
              writeIntoparserLogFile("");
          
      break;
    }

    case 2: {
      enterOuterAlt(_localctx, 2);
      setState(301);
      antlrcpp::downCast<Rel_expressionContext *>(_localctx)->se1 = simple_expression(0);
      setState(302);
      antlrcpp::downCast<Rel_expressionContext *>(_localctx)->op = match(C8086Parser::RELOP);
      setState(303);
      antlrcpp::downCast<Rel_expressionContext *>(_localctx)->se2 = simple_expression(0);

              antlrcpp::downCast<Rel_expressionContext *>(_localctx)->line =  antlrcpp::downCast<Rel_expressionContext *>(_localctx)->se1->line;
              antlrcpp::downCast<Rel_expressionContext *>(_localctx)->code =  antlrcpp::downCast<Rel_expressionContext *>(_localctx)->se1->code + antlrcpp::downCast<Rel_expressionContext *>(_localctx)->op->getText() + antlrcpp::downCast<Rel_expressionContext *>(_localctx)->se2->code;
              writeIntoparserLogFile("Line " + std::to_string(_localctx->line) + ": rel_expression : simple_expression RELOP simple_expression");
              writeIntoparserLogFile("");
              writeIntoparserLogFile(_localctx->code);
              writeIntoparserLogFile("");
          
      break;
    }

    default:
      break;
    }
   
  }
  catch (RecognitionException &e) {
    _errHandler->reportError(this, e);
    _localctx->exception = std::current_exception();
    _errHandler->recover(this, _localctx->exception);
  }

  return _localctx;
}

//----------------- Simple_expressionContext ------------------------------------------------------------------

C8086Parser::Simple_expressionContext::Simple_expressionContext(ParserRuleContext *parent, size_t invokingState)
  : ParserRuleContext(parent, invokingState) {
}

C8086Parser::TermContext* C8086Parser::Simple_expressionContext::term() {
  return getRuleContext<C8086Parser::TermContext>(0);
}

C8086Parser::Simple_expressionContext* C8086Parser::Simple_expressionContext::simple_expression() {
  return getRuleContext<C8086Parser::Simple_expressionContext>(0);
}

tree::TerminalNode* C8086Parser::Simple_expressionContext::ADDOP() {
  return getToken(C8086Parser::ADDOP, 0);
}


size_t C8086Parser::Simple_expressionContext::getRuleIndex() const {
  return C8086Parser::RuleSimple_expression;
}

void C8086Parser::Simple_expressionContext::enterRule(tree::ParseTreeListener *listener) {
  auto parserListener = dynamic_cast<C8086ParserListener *>(listener);
  if (parserListener != nullptr)
    parserListener->enterSimple_expression(this);
}

void C8086Parser::Simple_expressionContext::exitRule(tree::ParseTreeListener *listener) {
  auto parserListener = dynamic_cast<C8086ParserListener *>(listener);
  if (parserListener != nullptr)
    parserListener->exitSimple_expression(this);
}


C8086Parser::Simple_expressionContext* C8086Parser::simple_expression() {
   return simple_expression(0);
}

C8086Parser::Simple_expressionContext* C8086Parser::simple_expression(int precedence) {
  ParserRuleContext *parentContext = _ctx;
  size_t parentState = getState();
  C8086Parser::Simple_expressionContext *_localctx = _tracker.createInstance<Simple_expressionContext>(_ctx, parentState);
  C8086Parser::Simple_expressionContext *previousContext = _localctx;
  (void)previousContext; // Silence compiler, in case the context is not used by generated code.
  size_t startState = 36;
  enterRecursionRule(_localctx, 36, C8086Parser::RuleSimple_expression, precedence);

    

#if __cplusplus > 201703L
  auto onExit = finally([=, this] {
#else
  auto onExit = finally([=] {
#endif
    unrollRecursionContexts(parentContext);
  });
  try {
    size_t alt;
    enterOuterAlt(_localctx, 1);
    setState(309);
    antlrcpp::downCast<Simple_expressionContext *>(_localctx)->t = term(0);

            antlrcpp::downCast<Simple_expressionContext *>(_localctx)->code =  antlrcpp::downCast<Simple_expressionContext *>(_localctx)->t->code;
            antlrcpp::downCast<Simple_expressionContext *>(_localctx)->line =  antlrcpp::downCast<Simple_expressionContext *>(_localctx)->t->line;
            writeIntoparserLogFile("Line " + std::to_string(_localctx->line) + ": simple_expression : term");
            writeIntoparserLogFile("");
            writeIntoparserLogFile(_localctx->code);
            writeIntoparserLogFile("");
        
    _ctx->stop = _input->LT(-1);
    setState(319);
    _errHandler->sync(this);
    alt = getInterpreter<atn::ParserATNSimulator>()->adaptivePredict(_input, 20, _ctx);
    while (alt != 2 && alt != atn::ATN::INVALID_ALT_NUMBER) {
      if (alt == 1) {
        if (!_parseListeners.empty())
          triggerExitRuleEvent();
        previousContext = _localctx;
        _localctx = _tracker.createInstance<Simple_expressionContext>(parentContext, parentState);
        _localctx->se = previousContext;
        pushNewRecursionContext(_localctx, startState, RuleSimple_expression);
        setState(312);

        if (!(precpred(_ctx, 1))) throw FailedPredicateException(this, "precpred(_ctx, 1)");
        setState(313);
        antlrcpp::downCast<Simple_expressionContext *>(_localctx)->op = match(C8086Parser::ADDOP);
        setState(314);
        antlrcpp::downCast<Simple_expressionContext *>(_localctx)->t = term(0);

                          antlrcpp::downCast<Simple_expressionContext *>(_localctx)->line =  antlrcpp::downCast<Simple_expressionContext *>(_localctx)->se->line;
                          antlrcpp::downCast<Simple_expressionContext *>(_localctx)->code =  antlrcpp::downCast<Simple_expressionContext *>(_localctx)->se->code + antlrcpp::downCast<Simple_expressionContext *>(_localctx)->op->getText() + antlrcpp::downCast<Simple_expressionContext *>(_localctx)->t->code;
                          writeIntoparserLogFile("Line " + std::to_string(_localctx->line) + ": simple_expression : simple_expression ADDOP term");
                          writeIntoparserLogFile("");
                          writeIntoparserLogFile(_localctx->code);
                          writeIntoparserLogFile("");
                       
      }
      setState(321);
      _errHandler->sync(this);
      alt = getInterpreter<atn::ParserATNSimulator>()->adaptivePredict(_input, 20, _ctx);
    }
  }
  catch (RecognitionException &e) {
    _errHandler->reportError(this, e);
    _localctx->exception = std::current_exception();
    _errHandler->recover(this, _localctx->exception);
  }
  return _localctx;
}

//----------------- TermContext ------------------------------------------------------------------

C8086Parser::TermContext::TermContext(ParserRuleContext *parent, size_t invokingState)
  : ParserRuleContext(parent, invokingState) {
}

C8086Parser::Unary_expressionContext* C8086Parser::TermContext::unary_expression() {
  return getRuleContext<C8086Parser::Unary_expressionContext>(0);
}

C8086Parser::TermContext* C8086Parser::TermContext::term() {
  return getRuleContext<C8086Parser::TermContext>(0);
}

tree::TerminalNode* C8086Parser::TermContext::MULOP() {
  return getToken(C8086Parser::MULOP, 0);
}


size_t C8086Parser::TermContext::getRuleIndex() const {
  return C8086Parser::RuleTerm;
}

void C8086Parser::TermContext::enterRule(tree::ParseTreeListener *listener) {
  auto parserListener = dynamic_cast<C8086ParserListener *>(listener);
  if (parserListener != nullptr)
    parserListener->enterTerm(this);
}

void C8086Parser::TermContext::exitRule(tree::ParseTreeListener *listener) {
  auto parserListener = dynamic_cast<C8086ParserListener *>(listener);
  if (parserListener != nullptr)
    parserListener->exitTerm(this);
}


C8086Parser::TermContext* C8086Parser::term() {
   return term(0);
}

C8086Parser::TermContext* C8086Parser::term(int precedence) {
  ParserRuleContext *parentContext = _ctx;
  size_t parentState = getState();
  C8086Parser::TermContext *_localctx = _tracker.createInstance<TermContext>(_ctx, parentState);
  C8086Parser::TermContext *previousContext = _localctx;
  (void)previousContext; // Silence compiler, in case the context is not used by generated code.
  size_t startState = 38;
  enterRecursionRule(_localctx, 38, C8086Parser::RuleTerm, precedence);

    

#if __cplusplus > 201703L
  auto onExit = finally([=, this] {
#else
  auto onExit = finally([=] {
#endif
    unrollRecursionContexts(parentContext);
  });
  try {
    size_t alt;
    enterOuterAlt(_localctx, 1);
    setState(323);
    antlrcpp::downCast<TermContext *>(_localctx)->ue = unary_expression();

            antlrcpp::downCast<TermContext *>(_localctx)->code =  antlrcpp::downCast<TermContext *>(_localctx)->ue->code;
            antlrcpp::downCast<TermContext *>(_localctx)->line =  antlrcpp::downCast<TermContext *>(_localctx)->ue->line;
            writeIntoparserLogFile("Line " + std::to_string(_localctx->line) + ": term : unary_expression");
            writeIntoparserLogFile("");
            writeIntoparserLogFile(_localctx->code);
            writeIntoparserLogFile("");
        
    _ctx->stop = _input->LT(-1);
    setState(333);
    _errHandler->sync(this);
    alt = getInterpreter<atn::ParserATNSimulator>()->adaptivePredict(_input, 21, _ctx);
    while (alt != 2 && alt != atn::ATN::INVALID_ALT_NUMBER) {
      if (alt == 1) {
        if (!_parseListeners.empty())
          triggerExitRuleEvent();
        previousContext = _localctx;
        _localctx = _tracker.createInstance<TermContext>(parentContext, parentState);
        _localctx->t = previousContext;
        pushNewRecursionContext(_localctx, startState, RuleTerm);
        setState(326);

        if (!(precpred(_ctx, 1))) throw FailedPredicateException(this, "precpred(_ctx, 1)");
        setState(327);
        antlrcpp::downCast<TermContext *>(_localctx)->op = match(C8086Parser::MULOP);
        setState(328);
        antlrcpp::downCast<TermContext *>(_localctx)->ue = unary_expression();

                          antlrcpp::downCast<TermContext *>(_localctx)->line =  antlrcpp::downCast<TermContext *>(_localctx)->t->line;
                          antlrcpp::downCast<TermContext *>(_localctx)->code =  antlrcpp::downCast<TermContext *>(_localctx)->t->code + antlrcpp::downCast<TermContext *>(_localctx)->op->getText() + antlrcpp::downCast<TermContext *>(_localctx)->ue->code;
                          writeIntoparserLogFile("Line " + std::to_string(_localctx->line) + ": term : term MULOP unary_expression");
                          writeIntoparserLogFile("");
                          writeIntoparserLogFile(_localctx->code);
                          writeIntoparserLogFile("");
                       
      }
      setState(335);
      _errHandler->sync(this);
      alt = getInterpreter<atn::ParserATNSimulator>()->adaptivePredict(_input, 21, _ctx);
    }
  }
  catch (RecognitionException &e) {
    _errHandler->reportError(this, e);
    _localctx->exception = std::current_exception();
    _errHandler->recover(this, _localctx->exception);
  }
  return _localctx;
}

//----------------- Unary_expressionContext ------------------------------------------------------------------

C8086Parser::Unary_expressionContext::Unary_expressionContext(ParserRuleContext *parent, size_t invokingState)
  : ParserRuleContext(parent, invokingState) {
}

tree::TerminalNode* C8086Parser::Unary_expressionContext::ADDOP() {
  return getToken(C8086Parser::ADDOP, 0);
}

C8086Parser::Unary_expressionContext* C8086Parser::Unary_expressionContext::unary_expression() {
  return getRuleContext<C8086Parser::Unary_expressionContext>(0);
}

tree::TerminalNode* C8086Parser::Unary_expressionContext::NOT() {
  return getToken(C8086Parser::NOT, 0);
}

C8086Parser::FactorContext* C8086Parser::Unary_expressionContext::factor() {
  return getRuleContext<C8086Parser::FactorContext>(0);
}


size_t C8086Parser::Unary_expressionContext::getRuleIndex() const {
  return C8086Parser::RuleUnary_expression;
}

void C8086Parser::Unary_expressionContext::enterRule(tree::ParseTreeListener *listener) {
  auto parserListener = dynamic_cast<C8086ParserListener *>(listener);
  if (parserListener != nullptr)
    parserListener->enterUnary_expression(this);
}

void C8086Parser::Unary_expressionContext::exitRule(tree::ParseTreeListener *listener) {
  auto parserListener = dynamic_cast<C8086ParserListener *>(listener);
  if (parserListener != nullptr)
    parserListener->exitUnary_expression(this);
}

C8086Parser::Unary_expressionContext* C8086Parser::unary_expression() {
  Unary_expressionContext *_localctx = _tracker.createInstance<Unary_expressionContext>(_ctx, getState());
  enterRule(_localctx, 40, C8086Parser::RuleUnary_expression);

#if __cplusplus > 201703L
  auto onExit = finally([=, this] {
#else
  auto onExit = finally([=] {
#endif
    exitRule();
  });
  try {
    setState(347);
    _errHandler->sync(this);
    switch (_input->LA(1)) {
      case C8086Parser::ADDOP: {
        enterOuterAlt(_localctx, 1);
        setState(336);
        antlrcpp::downCast<Unary_expressionContext *>(_localctx)->op = match(C8086Parser::ADDOP);
        setState(337);
        antlrcpp::downCast<Unary_expressionContext *>(_localctx)->ue = unary_expression();

                antlrcpp::downCast<Unary_expressionContext *>(_localctx)->line =  antlrcpp::downCast<Unary_expressionContext *>(_localctx)->op->getLine();
                antlrcpp::downCast<Unary_expressionContext *>(_localctx)->code =  antlrcpp::downCast<Unary_expressionContext *>(_localctx)->op->getText() + antlrcpp::downCast<Unary_expressionContext *>(_localctx)->ue->code;
                writeIntoparserLogFile("Line " + std::to_string(_localctx->line) + ": unary_expression : ADDOP unary_expression");
                writeIntoparserLogFile("");
                writeIntoparserLogFile(_localctx->code);
                writeIntoparserLogFile("");
            
        break;
      }

      case C8086Parser::NOT: {
        enterOuterAlt(_localctx, 2);
        setState(340);
        antlrcpp::downCast<Unary_expressionContext *>(_localctx)->notToken = match(C8086Parser::NOT);
        setState(341);
        antlrcpp::downCast<Unary_expressionContext *>(_localctx)->ue = unary_expression();

                antlrcpp::downCast<Unary_expressionContext *>(_localctx)->line =  antlrcpp::downCast<Unary_expressionContext *>(_localctx)->notToken->getLine();
                antlrcpp::downCast<Unary_expressionContext *>(_localctx)->code =  "!" + antlrcpp::downCast<Unary_expressionContext *>(_localctx)->ue->code;
                writeIntoparserLogFile("Line " + std::to_string(_localctx->line) + ": unary_expression : NOT unary_expression");
                writeIntoparserLogFile("");
                writeIntoparserLogFile(_localctx->code);
                writeIntoparserLogFile("");
            
        break;
      }

      case C8086Parser::LPAREN:
      case C8086Parser::ID:
      case C8086Parser::CONST_INT:
      case C8086Parser::CONST_FLOAT: {
        enterOuterAlt(_localctx, 3);
        setState(344);
        antlrcpp::downCast<Unary_expressionContext *>(_localctx)->f = factor();

                antlrcpp::downCast<Unary_expressionContext *>(_localctx)->code =  antlrcpp::downCast<Unary_expressionContext *>(_localctx)->f->code;
                antlrcpp::downCast<Unary_expressionContext *>(_localctx)->line =  antlrcpp::downCast<Unary_expressionContext *>(_localctx)->f->line;
                writeIntoparserLogFile("Line " + std::to_string(_localctx->line) + ": unary_expression : factor");
                writeIntoparserLogFile("");
                writeIntoparserLogFile(_localctx->code);
                writeIntoparserLogFile("");
            
        break;
      }

    default:
      throw NoViableAltException(this);
    }
   
  }
  catch (RecognitionException &e) {
    _errHandler->reportError(this, e);
    _localctx->exception = std::current_exception();
    _errHandler->recover(this, _localctx->exception);
  }

  return _localctx;
}

//----------------- FactorContext ------------------------------------------------------------------

C8086Parser::FactorContext::FactorContext(ParserRuleContext *parent, size_t invokingState)
  : ParserRuleContext(parent, invokingState) {
}

C8086Parser::VariableContext* C8086Parser::FactorContext::variable() {
  return getRuleContext<C8086Parser::VariableContext>(0);
}

tree::TerminalNode* C8086Parser::FactorContext::LPAREN() {
  return getToken(C8086Parser::LPAREN, 0);
}

tree::TerminalNode* C8086Parser::FactorContext::RPAREN() {
  return getToken(C8086Parser::RPAREN, 0);
}

tree::TerminalNode* C8086Parser::FactorContext::ID() {
  return getToken(C8086Parser::ID, 0);
}

C8086Parser::Argument_listContext* C8086Parser::FactorContext::argument_list() {
  return getRuleContext<C8086Parser::Argument_listContext>(0);
}

C8086Parser::ExpressionContext* C8086Parser::FactorContext::expression() {
  return getRuleContext<C8086Parser::ExpressionContext>(0);
}

tree::TerminalNode* C8086Parser::FactorContext::CONST_INT() {
  return getToken(C8086Parser::CONST_INT, 0);
}

tree::TerminalNode* C8086Parser::FactorContext::CONST_FLOAT() {
  return getToken(C8086Parser::CONST_FLOAT, 0);
}

tree::TerminalNode* C8086Parser::FactorContext::INCOP() {
  return getToken(C8086Parser::INCOP, 0);
}

tree::TerminalNode* C8086Parser::FactorContext::DECOP() {
  return getToken(C8086Parser::DECOP, 0);
}


size_t C8086Parser::FactorContext::getRuleIndex() const {
  return C8086Parser::RuleFactor;
}

void C8086Parser::FactorContext::enterRule(tree::ParseTreeListener *listener) {
  auto parserListener = dynamic_cast<C8086ParserListener *>(listener);
  if (parserListener != nullptr)
    parserListener->enterFactor(this);
}

void C8086Parser::FactorContext::exitRule(tree::ParseTreeListener *listener) {
  auto parserListener = dynamic_cast<C8086ParserListener *>(listener);
  if (parserListener != nullptr)
    parserListener->exitFactor(this);
}

C8086Parser::FactorContext* C8086Parser::factor() {
  FactorContext *_localctx = _tracker.createInstance<FactorContext>(_ctx, getState());
  enterRule(_localctx, 42, C8086Parser::RuleFactor);

#if __cplusplus > 201703L
  auto onExit = finally([=, this] {
#else
  auto onExit = finally([=] {
#endif
    exitRule();
  });
  try {
    setState(375);
    _errHandler->sync(this);
    switch (getInterpreter<atn::ParserATNSimulator>()->adaptivePredict(_input, 23, _ctx)) {
    case 1: {
      enterOuterAlt(_localctx, 1);
      setState(349);
      antlrcpp::downCast<FactorContext *>(_localctx)->v = variable();

              antlrcpp::downCast<FactorContext *>(_localctx)->code =  antlrcpp::downCast<FactorContext *>(_localctx)->v->code;
              antlrcpp::downCast<FactorContext *>(_localctx)->line =  antlrcpp::downCast<FactorContext *>(_localctx)->v->line;
              writeIntoparserLogFile("Line " + std::to_string(_localctx->line) + ": factor : variable");
              writeIntoparserLogFile("");
              writeIntoparserLogFile(_localctx->code);
              writeIntoparserLogFile("");
          
      break;
    }

    case 2: {
      enterOuterAlt(_localctx, 2);
      setState(352);
      antlrcpp::downCast<FactorContext *>(_localctx)->id = match(C8086Parser::ID);
      setState(353);
      match(C8086Parser::LPAREN);
      setState(354);
      antlrcpp::downCast<FactorContext *>(_localctx)->al = argument_list();
      setState(355);
      match(C8086Parser::RPAREN);

              antlrcpp::downCast<FactorContext *>(_localctx)->line =  antlrcpp::downCast<FactorContext *>(_localctx)->id->getLine();
              antlrcpp::downCast<FactorContext *>(_localctx)->code =  antlrcpp::downCast<FactorContext *>(_localctx)->id->getText() + "(" + antlrcpp::downCast<FactorContext *>(_localctx)->al->code + ")";
              writeIntoparserLogFile("Line " + std::to_string(_localctx->line) + ": factor : ID LPAREN argument_list RPAREN");
              writeIntoparserLogFile("");
              writeIntoparserLogFile(_localctx->code);
              writeIntoparserLogFile("");
          
      break;
    }

    case 3: {
      enterOuterAlt(_localctx, 3);
      setState(358);
      antlrcpp::downCast<FactorContext *>(_localctx)->lparenToken = match(C8086Parser::LPAREN);
      setState(359);
      antlrcpp::downCast<FactorContext *>(_localctx)->e = expression();
      setState(360);
      match(C8086Parser::RPAREN);

              antlrcpp::downCast<FactorContext *>(_localctx)->line =  antlrcpp::downCast<FactorContext *>(_localctx)->lparenToken->getLine();
              antlrcpp::downCast<FactorContext *>(_localctx)->code =  "(" + antlrcpp::downCast<FactorContext *>(_localctx)->e->code + ")";
              writeIntoparserLogFile("Line " + std::to_string(_localctx->line) + ": factor : LPAREN expression RPAREN");
              writeIntoparserLogFile("");
              writeIntoparserLogFile(_localctx->code);
              writeIntoparserLogFile("");
          
      break;
    }

    case 4: {
      enterOuterAlt(_localctx, 4);
      setState(363);
      antlrcpp::downCast<FactorContext *>(_localctx)->ci = match(C8086Parser::CONST_INT);

              antlrcpp::downCast<FactorContext *>(_localctx)->line =  antlrcpp::downCast<FactorContext *>(_localctx)->ci->getLine();
              antlrcpp::downCast<FactorContext *>(_localctx)->code =  antlrcpp::downCast<FactorContext *>(_localctx)->ci->getText();
              writeIntoparserLogFile("Line " + std::to_string(_localctx->line) + ": factor : CONST_INT");
              writeIntoparserLogFile("");
              writeIntoparserLogFile(_localctx->code);
              writeIntoparserLogFile("");
          
      break;
    }

    case 5: {
      enterOuterAlt(_localctx, 5);
      setState(365);
      antlrcpp::downCast<FactorContext *>(_localctx)->cf = match(C8086Parser::CONST_FLOAT);

              antlrcpp::downCast<FactorContext *>(_localctx)->line =  antlrcpp::downCast<FactorContext *>(_localctx)->cf->getLine();
              antlrcpp::downCast<FactorContext *>(_localctx)->code =  antlrcpp::downCast<FactorContext *>(_localctx)->cf->getText();
              writeIntoparserLogFile("Line " + std::to_string(_localctx->line) + ": factor : CONST_FLOAT");
              writeIntoparserLogFile("");
              writeIntoparserLogFile(_localctx->code);
              writeIntoparserLogFile("");
          
      break;
    }

    case 6: {
      enterOuterAlt(_localctx, 6);
      setState(367);
      antlrcpp::downCast<FactorContext *>(_localctx)->v = variable();
      setState(368);
      match(C8086Parser::INCOP);

              antlrcpp::downCast<FactorContext *>(_localctx)->line =  antlrcpp::downCast<FactorContext *>(_localctx)->v->line;
              antlrcpp::downCast<FactorContext *>(_localctx)->code =  antlrcpp::downCast<FactorContext *>(_localctx)->v->code + "++";
              writeIntoparserLogFile("Line " + std::to_string(_localctx->line) + ": factor : variable INCOP");
              writeIntoparserLogFile("");
              writeIntoparserLogFile(_localctx->code);
              writeIntoparserLogFile("");
          
      break;
    }

    case 7: {
      enterOuterAlt(_localctx, 7);
      setState(371);
      antlrcpp::downCast<FactorContext *>(_localctx)->v = variable();
      setState(372);
      match(C8086Parser::DECOP);

              antlrcpp::downCast<FactorContext *>(_localctx)->line =  antlrcpp::downCast<FactorContext *>(_localctx)->v->line;
              antlrcpp::downCast<FactorContext *>(_localctx)->code =  antlrcpp::downCast<FactorContext *>(_localctx)->v->code + "--";
              writeIntoparserLogFile("Line " + std::to_string(_localctx->line) + ": factor : variable DECOP");
              writeIntoparserLogFile("");
              writeIntoparserLogFile(_localctx->code);
              writeIntoparserLogFile("");
          
      break;
    }

    default:
      break;
    }
   
  }
  catch (RecognitionException &e) {
    _errHandler->reportError(this, e);
    _localctx->exception = std::current_exception();
    _errHandler->recover(this, _localctx->exception);
  }

  return _localctx;
}

//----------------- Argument_listContext ------------------------------------------------------------------

C8086Parser::Argument_listContext::Argument_listContext(ParserRuleContext *parent, size_t invokingState)
  : ParserRuleContext(parent, invokingState) {
}

C8086Parser::ArgumentsContext* C8086Parser::Argument_listContext::arguments() {
  return getRuleContext<C8086Parser::ArgumentsContext>(0);
}


size_t C8086Parser::Argument_listContext::getRuleIndex() const {
  return C8086Parser::RuleArgument_list;
}

void C8086Parser::Argument_listContext::enterRule(tree::ParseTreeListener *listener) {
  auto parserListener = dynamic_cast<C8086ParserListener *>(listener);
  if (parserListener != nullptr)
    parserListener->enterArgument_list(this);
}

void C8086Parser::Argument_listContext::exitRule(tree::ParseTreeListener *listener) {
  auto parserListener = dynamic_cast<C8086ParserListener *>(listener);
  if (parserListener != nullptr)
    parserListener->exitArgument_list(this);
}

C8086Parser::Argument_listContext* C8086Parser::argument_list() {
  Argument_listContext *_localctx = _tracker.createInstance<Argument_listContext>(_ctx, getState());
  enterRule(_localctx, 44, C8086Parser::RuleArgument_list);

#if __cplusplus > 201703L
  auto onExit = finally([=, this] {
#else
  auto onExit = finally([=] {
#endif
    exitRule();
  });
  try {
    setState(381);
    _errHandler->sync(this);
    switch (_input->LA(1)) {
      case C8086Parser::LPAREN:
      case C8086Parser::ADDOP:
      case C8086Parser::NOT:
      case C8086Parser::ID:
      case C8086Parser::CONST_INT:
      case C8086Parser::CONST_FLOAT: {
        enterOuterAlt(_localctx, 1);
        setState(377);
        antlrcpp::downCast<Argument_listContext *>(_localctx)->a = arguments(0);

                antlrcpp::downCast<Argument_listContext *>(_localctx)->code =  antlrcpp::downCast<Argument_listContext *>(_localctx)->a->code;
                writeIntoparserLogFile("Line " + std::to_string(antlrcpp::downCast<Argument_listContext *>(_localctx)->a->line) + ": argument_list : arguments");
                writeIntoparserLogFile("");
                writeIntoparserLogFile(_localctx->code);
                writeIntoparserLogFile("");
            
        break;
      }

      case C8086Parser::RPAREN: {
        enterOuterAlt(_localctx, 2);

                antlrcpp::downCast<Argument_listContext *>(_localctx)->code =  "";
                // No logging for empty argument list
            
        break;
      }

    default:
      throw NoViableAltException(this);
    }
   
  }
  catch (RecognitionException &e) {
    _errHandler->reportError(this, e);
    _localctx->exception = std::current_exception();
    _errHandler->recover(this, _localctx->exception);
  }

  return _localctx;
}

//----------------- ArgumentsContext ------------------------------------------------------------------

C8086Parser::ArgumentsContext::ArgumentsContext(ParserRuleContext *parent, size_t invokingState)
  : ParserRuleContext(parent, invokingState) {
}

C8086Parser::Logic_expressionContext* C8086Parser::ArgumentsContext::logic_expression() {
  return getRuleContext<C8086Parser::Logic_expressionContext>(0);
}

tree::TerminalNode* C8086Parser::ArgumentsContext::COMMA() {
  return getToken(C8086Parser::COMMA, 0);
}

C8086Parser::ArgumentsContext* C8086Parser::ArgumentsContext::arguments() {
  return getRuleContext<C8086Parser::ArgumentsContext>(0);
}


size_t C8086Parser::ArgumentsContext::getRuleIndex() const {
  return C8086Parser::RuleArguments;
}

void C8086Parser::ArgumentsContext::enterRule(tree::ParseTreeListener *listener) {
  auto parserListener = dynamic_cast<C8086ParserListener *>(listener);
  if (parserListener != nullptr)
    parserListener->enterArguments(this);
}

void C8086Parser::ArgumentsContext::exitRule(tree::ParseTreeListener *listener) {
  auto parserListener = dynamic_cast<C8086ParserListener *>(listener);
  if (parserListener != nullptr)
    parserListener->exitArguments(this);
}


C8086Parser::ArgumentsContext* C8086Parser::arguments() {
   return arguments(0);
}

C8086Parser::ArgumentsContext* C8086Parser::arguments(int precedence) {
  ParserRuleContext *parentContext = _ctx;
  size_t parentState = getState();
  C8086Parser::ArgumentsContext *_localctx = _tracker.createInstance<ArgumentsContext>(_ctx, parentState);
  C8086Parser::ArgumentsContext *previousContext = _localctx;
  (void)previousContext; // Silence compiler, in case the context is not used by generated code.
  size_t startState = 46;
  enterRecursionRule(_localctx, 46, C8086Parser::RuleArguments, precedence);

    

#if __cplusplus > 201703L
  auto onExit = finally([=, this] {
#else
  auto onExit = finally([=] {
#endif
    unrollRecursionContexts(parentContext);
  });
  try {
    size_t alt;
    enterOuterAlt(_localctx, 1);
    setState(384);
    antlrcpp::downCast<ArgumentsContext *>(_localctx)->le = logic_expression();

            antlrcpp::downCast<ArgumentsContext *>(_localctx)->line =  antlrcpp::downCast<ArgumentsContext *>(_localctx)->le->line;
            antlrcpp::downCast<ArgumentsContext *>(_localctx)->code =  antlrcpp::downCast<ArgumentsContext *>(_localctx)->le->code;
            writeIntoparserLogFile("Line " + std::to_string(_localctx->line) + ": arguments : logic_expression");
            writeIntoparserLogFile("");
            writeIntoparserLogFile(_localctx->code);
            writeIntoparserLogFile("");
        
    _ctx->stop = _input->LT(-1);
    setState(394);
    _errHandler->sync(this);
    alt = getInterpreter<atn::ParserATNSimulator>()->adaptivePredict(_input, 25, _ctx);
    while (alt != 2 && alt != atn::ATN::INVALID_ALT_NUMBER) {
      if (alt == 1) {
        if (!_parseListeners.empty())
          triggerExitRuleEvent();
        previousContext = _localctx;
        _localctx = _tracker.createInstance<ArgumentsContext>(parentContext, parentState);
        _localctx->a = previousContext;
        pushNewRecursionContext(_localctx, startState, RuleArguments);
        setState(387);

        if (!(precpred(_ctx, 2))) throw FailedPredicateException(this, "precpred(_ctx, 2)");
        setState(388);
        match(C8086Parser::COMMA);
        setState(389);
        antlrcpp::downCast<ArgumentsContext *>(_localctx)->le = logic_expression();

                          antlrcpp::downCast<ArgumentsContext *>(_localctx)->line =  antlrcpp::downCast<ArgumentsContext *>(_localctx)->a->line;
                          antlrcpp::downCast<ArgumentsContext *>(_localctx)->code =  antlrcpp::downCast<ArgumentsContext *>(_localctx)->a->code + "," + antlrcpp::downCast<ArgumentsContext *>(_localctx)->le->code;
                          writeIntoparserLogFile("Line " + std::to_string(_localctx->line) + ": arguments : arguments COMMA logic_expression");
                          writeIntoparserLogFile("");
                          writeIntoparserLogFile(_localctx->code);
                          writeIntoparserLogFile("");
                       
      }
      setState(396);
      _errHandler->sync(this);
      alt = getInterpreter<atn::ParserATNSimulator>()->adaptivePredict(_input, 25, _ctx);
    }
  }
  catch (RecognitionException &e) {
    _errHandler->reportError(this, e);
    _localctx->exception = std::current_exception();
    _errHandler->recover(this, _localctx->exception);
  }
  return _localctx;
}

bool C8086Parser::sempred(RuleContext *context, size_t ruleIndex, size_t predicateIndex) {
  switch (ruleIndex) {
    case 1: return programSempred(antlrcpp::downCast<ProgramContext *>(context), predicateIndex);
    case 5: return parameter_listSempred(antlrcpp::downCast<Parameter_listContext *>(context), predicateIndex);
    case 10: return declaration_listSempred(antlrcpp::downCast<Declaration_listContext *>(context), predicateIndex);
    case 11: return statementsSempred(antlrcpp::downCast<StatementsContext *>(context), predicateIndex);
    case 18: return simple_expressionSempred(antlrcpp::downCast<Simple_expressionContext *>(context), predicateIndex);
    case 19: return termSempred(antlrcpp::downCast<TermContext *>(context), predicateIndex);
    case 23: return argumentsSempred(antlrcpp::downCast<ArgumentsContext *>(context), predicateIndex);

  default:
    break;
  }
  return true;
}

bool C8086Parser::programSempred(ProgramContext *_localctx, size_t predicateIndex) {
  switch (predicateIndex) {
    case 0: return precpred(_ctx, 2);

  default:
    break;
  }
  return true;
}

bool C8086Parser::parameter_listSempred(Parameter_listContext *_localctx, size_t predicateIndex) {
  switch (predicateIndex) {
    case 1: return precpred(_ctx, 4);
    case 2: return precpred(_ctx, 3);

  default:
    break;
  }
  return true;
}

bool C8086Parser::declaration_listSempred(Declaration_listContext *_localctx, size_t predicateIndex) {
  switch (predicateIndex) {
    case 3: return precpred(_ctx, 3);
    case 4: return precpred(_ctx, 1);

  default:
    break;
  }
  return true;
}

bool C8086Parser::statementsSempred(StatementsContext *_localctx, size_t predicateIndex) {
  switch (predicateIndex) {
    case 5: return precpred(_ctx, 1);

  default:
    break;
  }
  return true;
}

bool C8086Parser::simple_expressionSempred(Simple_expressionContext *_localctx, size_t predicateIndex) {
  switch (predicateIndex) {
    case 6: return precpred(_ctx, 1);

  default:
    break;
  }
  return true;
}

bool C8086Parser::termSempred(TermContext *_localctx, size_t predicateIndex) {
  switch (predicateIndex) {
    case 7: return precpred(_ctx, 1);

  default:
    break;
  }
  return true;
}

bool C8086Parser::argumentsSempred(ArgumentsContext *_localctx, size_t predicateIndex) {
  switch (predicateIndex) {
    case 8: return precpred(_ctx, 2);

  default:
    break;
  }
  return true;
}

void C8086Parser::initialize() {
#if ANTLR4_USE_THREAD_LOCAL_CACHE
  c8086parserParserInitialize();
#else
  ::antlr4::internal::call_once(c8086parserParserOnceFlag, c8086parserParserInitialize);
#endif
}
