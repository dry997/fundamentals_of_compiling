#include "stdio.h"
#include "stdlib.h"
#include "string.h"
#include "def.h"
#include "parser.tab.h"
int Enter = 0;
void printf_(int indent) {
	if (Enter == 1) {
		printf("\n");
	}
	else {
		Enter = 1;
	}
	if (indent != 0) {
		printf("%*c", indent, ' ');
	}
}
void display(struct ASTNode *T,int indent)
{
  int i=1;
  struct ASTNode *T0;
  if (T)
	{
	switch (T->kind) {
	case SentenceList_: 
		display(T->Sentence, indent);
		display(T->SentenceList, indent);
		break;
	case Sentence_:
		printf_(indent);
		printf("表达式语句：");
		display(T->Exp1, indent + 4);
		break;
	case ID:
		printf_(indent);
		printf("变量：%s",T->type_id);
		break;
	case INT:
		printf_(indent);
		printf("整型常量：%d",T->type_int);
		break;
	case FLOAT:
		printf_(indent);
		printf("浮点常量：%.6f",T->type_float);
		break;
	case ASSIGNOP:
	case AND:
	case OR:
	case RELOP:
	case PLUS:
	case MINUS:
	case STAR:
	case DIV:
		printf_(indent);
        printf("%s",T->type_id);
        display(T->Exp1,indent+4);
        display(T->Exp2,indent+4);
        break;
	case UMINUS:
		printf_(indent);
		printf("单目%s", T->type_id);
		display(T->Exp1, indent + 4);
		break;
	case SCAN:
		printf_(indent);
		printf("输入变量：%s", T->type_id);
		break;
	case PRINT:
		printf_(indent);
		printf("输出表达式:");
		display(T->ID, indent + 4);
		break;
	case IF_ELSE:
		printf_(indent);
		printf("条件语句(if_then_else)：");
		printf_(indent+4);
		printf("条件：");
		display(T->Exp1, indent + 8);
		printf_(indent+4);
		printf("if子句：");
		display(T->SentenceIF, indent + 8);
		printf_(indent+4);
		printf("else子句：");
		display(T->SentenceElse, indent + 8);
		break;
	case WHILE:
		printf_(indent);
		printf("循环语句：");
		printf_(indent + 4);
		printf("条件：");
		display(T->Exp1, indent + 8);
		printf_(indent + 4);
		printf("循环体：");
		display(T->SentenceListWhile, indent + 8);
		break;
	}
  }
}
