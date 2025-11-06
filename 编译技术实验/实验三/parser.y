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
int yylex();
%}
%union {
    int type_int;
    float type_float;
    char type_id[32];
    struct node *ptr;
}
%token <type_int> INT
%token <type_float> FLOAT
%token <type_id> ID
%token SCAN PRINT IF ELSE WHILE
%token ASSIGNOP PLUS MINUS STAR DIV
%token EQ NE GT GE LT LE
%token LP RP LC RC SEMI
%type <ptr> Program StmList Stmt CompSt Exp
%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE
%right ASSIGNOP
%left EQ NE GT GE LT LE
%left PLUS MINUS
%left STAR DIV
%nonassoc UMINUS
%%
Program: StmList {
    syntax_tree_root = make_node(PROGRAM);
    add_child_node(syntax_tree_root, $1);
    $$ = syntax_tree_root;
}
;
StmList: {
    $$ = make_node(STMT_LIST);
}
| Stmt StmList {
    $$ = make_node(STMT_LIST);
    add_child_node($$, $1);
    add_child_node($$, $2);
}
;
CompSt: LC StmList RC {
    $$ = make_node(COMPOUND_STMT);
    add_child_node($$, $2);
}
;
Stmt: Exp SEMI {
    $$ = make_node(STMT);
    add_child_node($$, $1);
}
| CompSt {
    $$ = $1;
}
| SCAN ID SEMI {
    $$ = make_node(SCAN_STMT);
    add_child_node($$, make_id_node($2));
}
| PRINT Exp SEMI {
    $$ = make_node(PRINT_STMT);
    add_child_node($$, $2);
}
| IF LP Exp RP Stmt %prec LOWER_THAN_ELSE {
    $$ = make_node(IF_STMT);
    add_child_node($$, $3);
    add_child_node($$, $5);
}
| IF LP Exp RP Stmt ELSE Stmt {
    $$ = make_node(IF_STMT);
    add_child_node($$, $3);
    add_child_node($$, $5);
    add_child_node($$, $7);
}
| WHILE LP Exp RP Stmt {
    $$ = make_node(WHILE_STMT);
    add_child_node($$, $3);
    add_child_node($$, $5);
}
;
Exp: INT {
    $$ = make_int_node($1);
}
| FLOAT {
    $$ = make_float_node($1);
}
| ID {
    $$ = make_id_node($1);
}
| Exp ASSIGNOP Exp {
    $$ = make_node(ASSIGN_OP);
    add_child_node($$, $1);
    add_child_node($$, $3);
}
| Exp PLUS Exp {
    $$ = make_node(PLUS_OP);
    add_child_node($$, $1);
    add_child_node($$, $3);
}
| Exp MINUS Exp {
    $$ = make_node(MINUS_OP);
    add_child_node($$, $1);
    add_child_node($$, $3);
}
| Exp STAR Exp {
    $$ = make_node(STAR_OP);
    add_child_node($$, $1);
    add_child_node($$, $3);
}
| Exp DIV Exp {
    $$ = make_node(DIV_OP);
    add_child_node($$, $1);
    add_child_node($$, $3);
}
| Exp EQ Exp {
    $$ = make_node(EQ_OP);
    add_child_node($$, $1);
    add_child_node($$, $3);
}
| Exp NE Exp {
    $$ = make_node(NE_OP);
    add_child_node($$, $1);
    add_child_node($$, $3);
}
| Exp GT Exp {
    $$ = make_node(GT_OP);
    add_child_node($$, $1);
    add_child_node($$, $3);
}
| Exp GE Exp {
    $$ = make_node(GE_OP);
    add_child_node($$, $1);
    add_child_node($$, $3);
}
| Exp LT Exp {
    $$ = make_node(LT_OP);
    add_child_node($$, $1);
    add_child_node($$, $3);
}
| Exp LE Exp {
    $$ = make_node(LE_OP);
    add_child_node($$, $1);
    add_child_node($$, $3);
}
| MINUS Exp %prec UMINUS {
    $$ = make_node(UMINUS_OP);
    add_child_node($$, $2);
}
| LP Exp RP {
    $$ = $2;
}
;
%%
void yyerror(const char* fmt, ...) {
}
int main(int argc, char **argv) {
    if (argc > 1) {
        if (!(yyin = fopen(argv[1], "r"))) {
            perror(argv[1]);
            return 1;
        }
    }
    yyparse();
    if (syntax_tree_root) {
        execute_tree(syntax_tree_root);
    }
    return 0;
}