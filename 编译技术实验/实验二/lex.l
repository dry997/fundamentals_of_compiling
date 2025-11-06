%option  yylineno
%{
#include "parser.tab.h"
#include "string.h"
#include "def.h"
int yycolumn=1;
int lastToken;
%}
id   [A-Za-z][A-Za-z0-9]*  
intconst    [0-9]+
floatconst  [0-9]*\.?[0-9]*([eE][-+]?[0-9]+)?
%%
"int"       {strcpy(yylval.type_id,  yytext);return TYPE;}
"float"     {strcpy(yylval.type_id,  yytext);return TYPE;}
"return"   {return RETURN;}
"if"        	{return IF;}
"else"      	{return ELSE;}
"while"   	{return WHILE;}
"for"       	{return FOR;}
"scan"	{return SCAN;}
"print"	{return PRINT;}
{id}        {strcpy(yylval.type_id,  yytext); return ID;}
";"		  {return SEMI;}
","		  {return COMMA;}
">"|"<"|">="|"<="|"=="|"!=" {strcpy(yylval.type_id, yytext);return RELOP;}
"="			{strcpy(yylval.type_id, yytext);return ASSIGNOP;}
"++"			{strcpy(yylval.type_id, yytext);return DPLUS;}
"+"			{strcpy(yylval.type_id, yytext);return PLUS;}
"-"			{strcpy(yylval.type_id, yytext);return MINUS;}
"*"			{strcpy(yylval.type_id, yytext);return STAR;}
"/"			{strcpy(yylval.type_id, yytext);return DIV;}
"&&"         {return AND;}
"||"           {return OR;}
"!"			{return NOT;}
"("			{return LP;}
")"			{return RP;}
"{"			{return LC;}
"}"			{return RC;}
{intconst}      {yylval.type_int=atoi(yytext); return INT;}
{floatconst}     {yylval.type_float=atof(yytext);     return FLOAT;}
[ \r\t]     {}   
[\n]            {yycolumn=1;}   
.			{printf("Error type A :Mysterious character \"%s\"\n\t at Line %d\n",yytext,yylineno);}
%%
int yywrap()
{
return 1;
}
