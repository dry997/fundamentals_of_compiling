%option  yylineno
/**************以下为定义段******************/
%{
#include "stdio.h"
#include "string.h"
int statue;
char name[20];

int val_int=0;
%}

id   [A-Za-z][A-Za-z0-9]*  
intconst    [0-9]+

/**************下面为需要填写的规则段******************/
%%
"int"         {printf("(1,-) ");}
"while"		  {printf("(2,-) ");}
"if"		  {printf("(3,-) ");}
"else"		  {printf("(4,-) ");}
"return"	  {printf("(5,-) ");}
{intconst}	  {printf("(51,%s) ",yytext);}
{id}			  {printf("(50,\"%s\") ",yytext);}
"+"			  {printf("(60,-) ");}
"-"			  {printf("(61,-) ");}
"*"			  {printf("(62,-) ");}
"/"			  {printf("(63,-) ");}
"="			  {printf("(64,-) ");}
"<"			  {printf("(65,-) ");}
"<="		  {printf("(66,-) ");}
">"			  {printf("(67,-) ");}
">="		  {printf("(68,-) ");}
"=="		  {printf("(69,-) ");}
"!="		  {printf("(70,-) ");}
"{"			  {printf("(71,-) ");}
"}"			  {printf("(72,-) ");}
"("			  {printf("(73,-) ");}
")"			  {printf("(74,-) ");}
","			  {printf("(75,-) ");}
";"			  {printf("(76,-) ");}
[ \r\t\n]     {}
.		      {printf("\n<error character \'%s\' in line %d> ",yytext,yylineno);}
%%

/**************以下为用户子程序段******************/
int main(int argc,char *argv[])
{
yylineno=1;      //行序号变量，每次遇到\n后会自动加1
yyin=fopen(argv[1],"r");
if (!yyin) return 0;
while (yylex());
return 0;
}
int yywrap() { return 1;}

