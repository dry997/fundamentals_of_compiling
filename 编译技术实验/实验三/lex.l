%option yylineno
%{
#include "parser.tab.h"
#include "string.h"
#include "def.h"
int yycolumn=1;
#define YY_USER_ACTION    \
	yylloc.first_line=yylloc.last_line=yylineno; \
	yylloc.first_column=yycolumn;\
	yylloc.last_column=yycolumn+yyleng-1;\
	yycolumn+=yyleng;
typedef union {
	int type_int;
	float type_float;
	char type_id[32];
} YYLVAL;
#define YYSTYPE YYLVAL
%}
delim [ \t\r\n]
ws {delim}+
letter [A-Za-z]
digit [0-9]
id {letter}({letter}|{digit})*
integer {digit}+
float ({digit}+\.{digit}*)|({digit}*\.{digit}+)
%%
{ws} { ; }
"scan" { return SCAN; }
"print" { return PRINT; }
"if" { return IF; }
"else" { return ELSE; }
"while" { return WHILE; }
{float} { yylval.type_float = atof(yytext); return FLOAT; }
{integer} { yylval.type_int = atoi(yytext); return INT; }
{id} { strcpy(yylval.type_id, yytext); return ID; }
"=" { return ASSIGNOP; }
"+" { return PLUS; }
"-" { return MINUS; }
"*" { return STAR; }
"/" { return DIV; }
"==" { return EQ; }
"!=" { return NE; }
">" { return GT; }
">=" { return GE; }
"<" { return LT; }
"<=" { return LE; }
"(" { return LP; }
")" { return RP; }
"{" { return LC; }
"}" { return RC; }
";" { return SEMI; }
%%
int yywrap() {
    return 1;
}