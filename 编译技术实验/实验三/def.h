#include <stdio.h>
#include <stdlib.h>
#include <string.h>
typedef enum {
    PROGRAM, STMT_LIST, STMT, COMPOUND_STMT, EXPR,
    INT_NODE, FLOAT_NODE, ID_NODE,
    SCAN_STMT, PRINT_STMT, IF_STMT, WHILE_STMT,
    ASSIGN_OP, PLUS_OP, MINUS_OP, STAR_OP, DIV_OP,
    EQ_OP, NE_OP, GT_OP, GE_OP, LT_OP, LE_OP, UMINUS_OP
} NodeType;
typedef struct node {
    NodeType type;
    union {
        int int_val;
        float float_val;
        char id_name[32];
    };
    struct node *children[10];
    int child_count;
} Node;
typedef enum { INT_TYPE, FLOAT_TYPE } ValueType;
typedef union {
    int int_value;
    float float_value;
} Value;
typedef struct {
    ValueType type;
    Value val;
} Result;
typedef struct {
    char name[32];
    ValueType type;
    Value val;
} Symbol;
extern Symbol symbol_table[1000];
extern int symbol_count;
extern Node *syntax_tree_root;
Node* make_node(NodeType type);
Node* make_int_node(int value);
Node* make_float_node(float value);
Node* make_id_node(char *name);
void add_child_node(Node *parent, Node *child);
void execute_tree(Node *node);
Result eval_expression(Node *node);
Symbol* find_symbol(char *name);
void set_symbol(char *name, ValueType type, Value val);
int is_true_result(Result res);