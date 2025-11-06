%error-verbose
%locations
%{
#include "stdio.h"
#include "math.h"
#include "string.h"
#include "def.h"
extern int yylineno;
extern char *yytext;
extern FILE *yyin;
void yyerror(const char* fmt, ...);
void display(struct ASTNode *,int);
int yylex();
%}
%union {
	int    type_int;
	float  type_float;
	char   type_id[32];
	struct ASTNode *ptr;
};
%type  <ptr>  program SentenceList Sentence Exp  
%token <type_int> INT
%token <type_id> ID  RELOP TYPE
%token <type_float> FLOAT
%token DPLUS  LP RP  LC RC SEMI  COMMA
%token SCAN PRINT PLUS MINUS STAR DIV  ASSIGNOP AND OR NOT IF ELSE WHILE RETURN STRUCT FOR SWITCH CASE COLON DEFAULT 
%token SentenceList_ Sentence_  IF_ELSE UMINUS 
%left ASSIGNOP
%left OR
%left AND
%left RELOP
%left PLUS MINUS
%left STAR DIV
%right UMINUS NOT DPLUS
%nonassoc ELSE
%%
program: SentenceList { display($1,0);};
SentenceList:	{$$=NULL;} 
	|	Sentence SentenceList {
			$$=(ASTNode *)malloc(sizeof(ASTNode));
			$$->kind = SentenceList_;
			$$->pos=yylineno;
			$$->Sentence=$1;
			$$->SentenceList=$2;
		}
	;
Sentence:	Exp  SEMI{
			$$=(ASTNode *)malloc(sizeof(ASTNode));
			$$->kind = Sentence_;
			$$->pos=yylineno;
			$$->Exp1=$1;
		}
	|	SCAN ID SEMI{
			$$=(ASTNode *)malloc(sizeof(ASTNode));
			$$->kind = SCAN;
			$$->pos=yylineno;
			strcpy($$->type_id,$2);
		}
	|	PRINT Exp SEMI{
			$$=(ASTNode *)malloc(sizeof(ASTNode));
			$$->kind = PRINT;
			$$->pos=yylineno;
			$$->ID = $2;
		}
	|	IF LP Exp RP Sentence ELSE Sentence{
			$$=(ASTNode *)malloc(sizeof(ASTNode));
			$$->kind = IF_ELSE;
			$$->pos=yylineno;
			$$->Exp1 = $3;
			$$->SentenceIF = $5;
			$$->SentenceElse = $7;
		}
	|	WHILE LP Exp RP LC SentenceList RC{
			$$=(ASTNode *)malloc(sizeof(ASTNode));
			$$->kind = WHILE;
			$$->pos=yylineno;
			$$->Exp1 = $3;
			$$->SentenceListWhile= $6;
		}
	;
Exp  :		Exp ASSIGNOP Exp{
			$$=(ASTNode *)malloc(sizeof(ASTNode));
			$$->kind = ASSIGNOP;
			$$->pos=yylineno;
			$$->Exp1=$1;
			$$->Exp2=$3;
			strcpy($$->type_id,"=");
		}
	|	MINUS Exp %prec UMINUS{
			$$=(ASTNode *)malloc(sizeof(ASTNode));
			$$->kind = UMINUS;
			$$->pos=yylineno;
			$$->Exp1=$2;
			strcpy($$->type_id,"-");
		}
	|	LP Exp RP{
			$$=$2;
		}
	|	Exp RELOP Exp{
			$$=(ASTNode *)malloc(sizeof(ASTNode));
			$$->kind = RELOP;
			$$->pos=yylineno;
			$$->Exp1=$1;
			$$->Exp2=$3;
			strcpy($$->type_id,$2);
		}
	|	Exp MINUS Exp{
			$$=(ASTNode *)malloc(sizeof(ASTNode));
			$$->kind = MINUS; 
			$$->pos=yylineno;
			$$->Exp1=$1;
			$$->Exp2=$3;
			strcpy($$->type_id,"-");
		}
	|	Exp PLUS Exp{
			$$=(ASTNode *)malloc(sizeof(ASTNode));
			$$->kind = PLUS; 
			$$->pos=yylineno;
			$$->Exp1=$1;
			$$->Exp2=$3;
			strcpy($$->type_id,"+");
		}
	|	Exp STAR Exp{
			$$=(ASTNode *)malloc(sizeof(ASTNode));
			$$->kind = STAR; 
			$$->pos=yylineno;
			$$->Exp1=$1;
			$$->Exp2=$3;
			strcpy($$->type_id,"*");
		}
	|	Exp DIV Exp{
			$$=(ASTNode *)malloc(sizeof(ASTNode));
			$$->kind = DIV; 
			$$->pos=yylineno;
			$$->Exp1=$1;
			$$->Exp2=$3;
			strcpy($$->type_id,"/");
		}
	|	ID{
			$$=(ASTNode *)malloc(sizeof(ASTNode)); 
			$$->kind=ID;
                               		$$->pos=yylineno;  
			strcpy($$->type_id,$1);
		}
	|	FLOAT{
			$$=(ASTNode *)malloc(sizeof(ASTNode)); 
			$$->kind=FLOAT;
                               		$$->pos=yylineno; 
			$$->type=FLOAT; 
			$$->type_float=$1;
		}
	|	INT{
			$$=(ASTNode *)malloc(sizeof(ASTNode)); 
			$$->kind=INT;
                               		$$->pos=yylineno; 
			$$->type=INT; 
			$$->type_int=$1;
		}
	;
%%
int main(int argc, char *argv[]){
	yyin=fopen(argv[1],"r");
	if (!yyin) return 0;
	yylineno=1;
	yyparse();
	return 0;
	}
#include<stdarg.h>
void yyerror(const char* fmt, ...)
{
    va_list ap;
    va_start(ap, fmt);
    fprintf(stderr, "Grammar Error at Line %d Column %d: ", yylloc.first_line,yylloc.first_column);
    vfprintf(stderr, fmt, ap);
    fprintf(stderr, ".\n");
}
