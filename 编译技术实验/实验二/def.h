#include "stdio.h"
#include "stdlib.h"
#include "string.h"
#include "stdarg.h"
#include "parser.tab.h"
typedef struct ASTNode {
	int kind;
	union {
		 char type_id[33];
		 int type_int;
		 float type_float;
	};
    union {
        struct ASTNode *Sentence;
	 	struct ASTNode *Exp1;
        struct ASTNode *ID;
    };
    union {
        struct ASTNode *SentenceList;
        struct ASTNode *Exp2;
        struct ASTNode *SentenceIF;
        struct ASTNode *SentenceListWhile;
    };
    union {
        struct ASTNode* SentenceElse;
    };
    int type;
    int pos;
} ASTNode;


