/* SECTION 1: DEFINITIONS */
%{
#include <stdio.h>
#include <string.h> // Required for strdup()

/* * This struct is the "package" of information we will pass from the lexer
 * to the parser for each token. It contains everything the parser needs:
 * the token's text, and its precise location for error reporting.
 */
typedef struct {
    char *token_text;
    int line_num;
    int col_num;
} YYSTYPE;

/* This is the special global variable that holds our package. */
YYSTYPE yylval;

/* Token type definitions, including the new 'T_WHERE' from the second lexer. */
typedef enum {
    T_INT = 258, T_FLOAT, T_CHAR, T_STRING, T_DOUBLE, T_BOOL, T_TRUE, T_FALSE,
    T_IF, T_ELIF, T_ELSE, T_FOR, T_WHILE, T_BREAK, T_CONTINUE, T_VECTOR,
    T_STRUCT, T_VERTEX_SET, T_EDGE_SET, T_GRAPH, T_FUNK, T_CONST, T_VAR,
    T_NEW, T_RETURN, T_IN, T_RANGE, T_WHERE, /* MERGED: Added T_WHERE */
    T_IDENTIFIER, T_BUILT_IN, T_INTEGER_LITERAL, T_FLOAT_LITERAL, T_STRING_LITERAL,
    T_GREATER_EQUAL, T_LESS_EQUAL, T_EQUAL_EQUAL, T_NOT_EQUAL, T_AND, T_OR,
    T_METRIC_CLOSURE, T_TRANSITIVE_CLOSURE, T_TRANSPOSE, T_COMPLEMENT,
    T_CONNECTED_COMP, T_POWER,T_AMPERSAND, T_INTERSECTION, T_TENSOR_PRODUCT, T_DOT,T_UNKNOWN
} TokenType;

/* Global variable to manually track the column number. */
int column = 1;

/* * Helper macro to reduce boilerplate. It fills our yylval struct with
 * the token's text and location, and updates the column counter.
 */
#define TOKEN_ACTION \
    yylval.token_text = strdup(yytext); \
    yylval.line_num = yylineno; \
    yylval.col_num = column; \
    column += yyleng;


/* EDITED: Added a helper function to convert token enums to strings for readable output. */
const char* token_type_to_string(int token_type) {
    switch (token_type) {
        /* Keywords */
        case T_IF: return "KEYWORD_IF";
        case T_ELIF: return "KEYWORD_ELIF";
        case T_ELSE: return "KEYWORD_ELSE";
        case T_FOR: return "KEYWORD_FOR";
        case T_WHILE: return "KEYWORD_WHILE";
        case T_FUNK: return "KEYWORD_FUNK";
        case T_RETURN: return "KEYWORD_RETURN";
        case T_CONST: return "KEYWORD_CONST";
        case T_VAR: return "KEYWORD_VAR";
        case T_NEW: return "KEYWORD_NEW";
        case T_IN: return "KEYWORD_IN";
        case T_RANGE: return "KEYWORD_RANGE";
        case T_WHERE: return "KEYWORD_WHERE";
        case T_BREAK: return "KEYWORD_BREAK";
        case T_CONTINUE: return "KEYWORD_CONTINUE";

        /* Data Types */
        case T_INT: return "TYPE_INT";
        case T_FLOAT: return "TYPE_FLOAT";
        case T_CHAR: return "TYPE_CHAR";
        case T_STRING: return "TYPE_STRING";
        case T_DOUBLE: return "TYPE_DOUBLE";
        case T_BOOL: return "TYPE_BOOL";
        case T_VECTOR: return "TYPE_VECTOR";
        case T_STRUCT: return "TYPE_STRUCT";
        case T_VERTEX_SET: return "TYPE_VERTEX_SET";
        case T_EDGE_SET: return "TYPE_EDGE_SET";
        case T_GRAPH: return "TYPE_GRAPH";

        /* Literals */
        case T_TRUE: return "LITERAL_TRUE";
        case T_FALSE: return "LITERAL_FALSE";
        case T_INTEGER_LITERAL: return "LITERAL_INTEGER";
        case T_FLOAT_LITERAL: return "LITERAL_FLOAT";
        case T_STRING_LITERAL: return "LITERAL_STRING";

        /* Identifiers */
        case T_IDENTIFIER: return "IDENTIFIER";
        case T_BUILT_IN: return "IDENTIFIER_BUILT_IN";

        /* Operators */
        case T_GREATER_EQUAL: return "OPERATOR_GE";
        case T_LESS_EQUAL: return "OPERATOR_LE";
        case T_EQUAL_EQUAL: return "OPERATOR_EQ";
        case T_NOT_EQUAL: return "OPERATOR_NE";
        case T_AND: return "OPERATOR_AND";
        case T_OR: return "OPERATOR_OR";
        case T_METRIC_CLOSURE: return "OPERATOR_METRIC_CLOSURE";
        case T_TRANSITIVE_CLOSURE: return "OPERATOR_TRANSITIVE_CLOSURE";
        case T_TRANSPOSE: return "OPERATOR_TRANSPOSE";
        case T_POWER: return "OPERATOR_POWER";
        case T_COMPLEMENT: return "OPERATOR_COMPLEMENT";
        case T_CONNECTED_COMP: return "OPERATOR_CONNECTED_COMP";
        case T_AMPERSAND: return "OPERATOR_AMPERSAND";
        case T_TENSOR_PRODUCT: return "OPERATOR_TENSOR_PRODUCT";
        case T_DOT: return "PUNCTUATION_DOT";
        
        /* Single characters are their own representation */
        default: return "PUNCTUATION";
    }
}


%}




/* Regular Expression Definitions */
DIGIT       [0-9]
LETTER      [a-zA-Z_]
IDENTIFIER  {LETTER}({LETTER}|{DIGIT})*
INTEGER     {DIGIT}+
FLOAT       ({DIGIT}+\.{DIGIT}*|{DIGIT}*\.{DIGIT}+)([eE][-+]?{DIGIT}+)?
STRING      \"(\\.|[^"\\])*\"

%%



"//".* { /* Ignore single-line comments. */ }
\/\*([^*]|\*+[^/])*\*+\/ {
    for(char *p=yytext;*p;p++)
    {
        if(*p=='\n') yylineno++;
    }
}



[ \t]+        { column += yyleng; /* For spaces/tabs, just advance the column */ }
\n            { yylineno++; column = 1; /* For newlines, increment line and reset column */ }


"if"            { TOKEN_ACTION; return T_IF; }
"elif"          { TOKEN_ACTION; return T_ELIF; }
"else"          { TOKEN_ACTION; return T_ELSE; }
"for"           { TOKEN_ACTION; return T_FOR; }
"in"            { TOKEN_ACTION; return T_IN; }
"range"         { TOKEN_ACTION; return T_RANGE; }
"while"         { TOKEN_ACTION; return T_WHILE; }
"funk"          { TOKEN_ACTION; return T_FUNK; }
"return"        { TOKEN_ACTION; return T_RETURN; }
"where"         { TOKEN_ACTION; return T_WHERE; } /* MERGED: Added 'where' keyword */
"int"           { TOKEN_ACTION; return T_INT; }
"float"         { TOKEN_ACTION; return T_FLOAT; }
"char"          { TOKEN_ACTION; return T_CHAR; }
"string"        { TOKEN_ACTION; return T_STRING; }
"double"        { TOKEN_ACTION; return T_DOUBLE; }
"bool"          { TOKEN_ACTION; return T_BOOL; }
"true"          { TOKEN_ACTION; return T_TRUE; }
"false"         { TOKEN_ACTION; return T_FALSE; }
"break"         { TOKEN_ACTION; return T_BREAK; }
"continue"      { TOKEN_ACTION; return T_CONTINUE; }
"vector"        { TOKEN_ACTION; return T_VECTOR; }
"struct"        { TOKEN_ACTION; return T_STRUCT; }
"vertex_set"    { TOKEN_ACTION; return T_VERTEX_SET; }
"edge_set"      { TOKEN_ACTION; return T_EDGE_SET; }
"graph"         { TOKEN_ACTION; return T_GRAPH; }
"const"         { TOKEN_ACTION; return T_CONST; }
"var"           { TOKEN_ACTION; return T_VAR; }
"new"           { TOKEN_ACTION; return T_NEW; }


{INTEGER}       { TOKEN_ACTION; return T_INTEGER_LITERAL; }
{FLOAT}         { TOKEN_ACTION; return T_FLOAT_LITERAL; }
{STRING}        { TOKEN_ACTION; return T_STRING_LITERAL; }


"bfs"                   {TOKEN_ACTION; return T_BUILT_IN;}
"dfs"                   {TOKEN_ACTION; return T_BUILT_IN;}
"add_edge"              {TOKEN_ACTION; return T_BUILT_IN;}
"remove_edge"           {TOKEN_ACTION; return T_BUILT_IN;}
"add_vertex"            {TOKEN_ACTION; return T_BUILT_IN;}
"remove_vertex"         {TOKEN_ACTION; return T_BUILT_IN;}
"update_edge"           {TOKEN_ACTION; return T_BUILT_IN;}
"get_vertices"          {TOKEN_ACTION; return T_BUILT_IN;}
"get_edges"             {TOKEN_ACTION; return T_BUILT_IN;}
"is_edge"               {TOKEN_ACTION; return T_BUILT_IN;}
"get_outdegree"         {TOKEN_ACTION; return T_BUILT_IN;}
"get_indegree"          {TOKEN_ACTION; return T_BUILT_IN;}
"get_degree"            {TOKEN_ACTION; return T_BUILT_IN;}
"transpose"             {TOKEN_ACTION; return T_BUILT_IN;}
"get_neighbours"        {TOKEN_ACTION; return T_BUILT_IN;}
"get_inneighbours"      {TOKEN_ACTION; return T_BUILT_IN;}
"get_outneighbours"     {TOKEN_ACTION; return T_BUILT_IN;}
"sssp"                  {TOKEN_ACTION; return T_BUILT_IN;}
"dij"                   {TOKEN_ACTION; return T_BUILT_IN;}
"mst"                   {TOKEN_ACTION; return T_BUILT_IN;}
"blfr"                  {TOKEN_ACTION; return T_BUILT_IN;}
"diam"                  {TOKEN_ACTION; return T_BUILT_IN;}
"topo"                  {TOKEN_ACTION; return T_BUILT_IN;}
"bridges"               {TOKEN_ACTION; return T_BUILT_IN;}
"atp"                   {TOKEN_ACTION; return T_BUILT_IN;}
"cg"                    {TOKEN_ACTION; return T_BUILT_IN;}
"epen"                  {TOKEN_ACTION; return T_BUILT_IN;}
"is_cycle"              {TOKEN_ACTION; return T_BUILT_IN;}
"bpm"                   {TOKEN_ACTION; return T_BUILT_IN;}
"vc"                    {TOKEN_ACTION; return T_BUILT_IN;}
"load"                  {TOKEN_ACTION; return T_BUILT_IN;}
"print"                 {TOKEN_ACTION; return T_BUILT_IN;}

{IDENTIFIER}    { 
    /* Note: We tokenize all identifiers (including bfs, dfs, etc.) here. The parser will distinguish them. */
    TOKEN_ACTION; return T_IDENTIFIER;
     }


">="            { TOKEN_ACTION; return T_GREATER_EQUAL; }
"<="            { TOKEN_ACTION; return T_LESS_EQUAL; }
"=="            { TOKEN_ACTION; return T_EQUAL_EQUAL; }
"!="            { TOKEN_ACTION; return T_NOT_EQUAL; }
"&&"            { TOKEN_ACTION; return T_AND; }
"||"            { TOKEN_ACTION; return T_OR; }
"~@"            { TOKEN_ACTION; return T_METRIC_CLOSURE; }
"~*"            { TOKEN_ACTION; return T_TRANSITIVE_CLOSURE; }
"~T"            { TOKEN_ACTION; return T_TRANSPOSE; }
"**"            { TOKEN_ACTION; return T_POWER; }
"~"             { TOKEN_ACTION; return T_COMPLEMENT; }
"#"             { TOKEN_ACTION; return T_CONNECTED_COMP; }
"&"             { TOKEN_ACTION; return T_AMPERSAND; }
"@"             { TOKEN_ACTION; return T_TENSOR_PRODUCT; }
"."             { TOKEN_ACTION; return T_DOT; }
[(){},:;=<>+*/-] { TOKEN_ACTION; return yytext[0]; }


.               { TOKEN_ACTION; printf("Error: Unknown character '%s' at line %d, column %d\n", yylval.token_text, yylval.line_num, yylval.col_num); return T_UNKNOWN; }

%%
/* SECTION 3: USER CODE */
int main(int argc, char **argv) {
    if (argc > 1) {
        yyin = fopen(argv[1], "r");
        if (!yyin) {
            perror(argv[1]);
            return 1;
        }
    }

    int token;
    while ((token = yylex())) {
        if (token == T_UNKNOWN) continue;

        /* EDITED: Updated the printf to use our new helper function for clearer output. */
        if (token < 258) { // Single-character tokens
             printf("Token: %-20s ('%s')\t\t at Line: %d, Col: %d\n",
                   "PUNCTUATION", yylval.token_text, yylval.line_num, yylval.col_num);
        } else {
            printf("Token: %-20s ('%s')\t\t at Line: %d, Col: %d\n",
                   token_type_to_string(token), yylval.token_text, yylval.line_num, yylval.col_num);
        }
    }
    return 0;
}

int yywrap() { return 1; }