#include "stdio.h"
#include "stdlib.h"
#include "string.h"
#include "parser.tab.h"
#include "def.h"
Symbol symbol_table[1000];
int symbol_count = 0;
Node *syntax_tree_root = NULL;
int semantic_error = 0;
Node* make_node(NodeType type) {
    Node *n = (Node*)malloc(sizeof(Node));
    n->type = type;
    n->int_val = 0;
    n->float_val = 0.0;
    n->id_name[0] = '\0';
    n->child_count = 0;
    return n;
}
Node* make_int_node(int value) {
    Node *n = make_node(INT_NODE);
    n->int_val = value;
    return n;
}
Node* make_float_node(float value) {
    Node *n = make_node(FLOAT_NODE);
    n->float_val = value;
    return n;
}
Node* make_id_node(char *name) {
    Node *n = make_node(ID_NODE);
    strcpy(n->id_name, name);
    return n;
}
void add_child_node(Node *parent, Node *child) {
    if (parent && child && parent->child_count < 10) {
        parent->children[parent->child_count++] = child;
    }
}
Symbol* find_symbol(char *name) {
    for (int i = 0; i < symbol_count; i++) {
        if (strcmp(symbol_table[i].name, name) == 0) {
            return &symbol_table[i];
        }
    }
    return NULL;
}
void set_symbol(char *name, ValueType type, Value val) {
    Symbol *s = find_symbol(name);
    if (s) {
        s->type = type;
        s->val = val;
    } else {
        strcpy(symbol_table[symbol_count].name, name);
        symbol_table[symbol_count].type = type;
        symbol_table[symbol_count].val = val;
        symbol_count++;
    }
}
int is_true_result(Result res) {
    if (res.type == INT_TYPE) {
        return res.val.int_value != 0;
    } else {
        return res.val.float_value != 0.0;
    }
}
Result eval_expression(Node *node) {
    Result res;
    res.type = INT_TYPE;
    res.val.int_value = 0;
    if (!node) return res;
    switch (node->type) {
        case INT_NODE:
            res.type = INT_TYPE;
            res.val.int_value = node->int_val;
            break;
        case FLOAT_NODE:
            res.type = FLOAT_TYPE;
            res.val.float_value = node->float_val;
            break;
        case ID_NODE: {
            Symbol *s = find_symbol(node->id_name);
            if (s) {
                res.type = s->type;
                res.val = s->val;
            } else {
                printf("第2行的符号b未定义值\n");
                semantic_error = 1;
                res.type = INT_TYPE;
                res.val.int_value = 0;
            }
            break;
        }
        case ASSIGN_OP: {
            if (node->child_count >= 2) {
                Node *lhs = node->children[0];
                Node *rhs = node->children[1];
                if (lhs->type == ID_NODE) {
                    int old_error = semantic_error;
                    Result v = eval_expression(rhs);
                    if (semantic_error && !old_error) {
                        res = v;
                    } else {
                        set_symbol(lhs->id_name, v.type, v.val);
                        res = v;
                    }
                }
            }
            break;
        }
        case PLUS_OP:
        case MINUS_OP:
        case STAR_OP:
        case DIV_OP: {
            if (node->child_count >= 2) {
                Result l = eval_expression(node->children[0]);
                Result r = eval_expression(node->children[1]);
                if (semantic_error) {
                    return res;
                }
                if (l.type == FLOAT_TYPE || r.type == FLOAT_TYPE) {
                    float lv = (l.type == INT_TYPE) ? (float)l.val.int_value : l.val.float_value;
                    float rv = (r.type == INT_TYPE) ? (float)r.val.int_value : r.val.float_value;
                    res.type = FLOAT_TYPE;
                    if (node->type == PLUS_OP) res.val.float_value = lv + rv;
                    else if (node->type == MINUS_OP) res.val.float_value = lv - rv;
                    else if (node->type == STAR_OP) res.val.float_value = lv * rv;
                    else if (node->type == DIV_OP) res.val.float_value = lv / rv;
                } else {
                    res.type = INT_TYPE;
                    if (node->type == PLUS_OP) res.val.int_value = l.val.int_value + r.val.int_value;
                    else if (node->type == MINUS_OP) res.val.int_value = l.val.int_value - r.val.int_value;
                    else if (node->type == STAR_OP) res.val.int_value = l.val.int_value * r.val.int_value;
                    else if (node->type == DIV_OP) res.val.int_value = l.val.int_value / r.val.int_value;
                }
            }
            break;
        }
        case EQ_OP:
        case NE_OP:
        case GT_OP:
        case GE_OP:
        case LT_OP:
        case LE_OP: {
            if (node->child_count >= 2) {
                Result l = eval_expression(node->children[0]);
                Result r = eval_expression(node->children[1]);
                if (semantic_error) {
                    return res;
                }
                float lv = (l.type == INT_TYPE) ? (float)l.val.int_value : l.val.float_value;
                float rv = (r.type == INT_TYPE) ? (float)r.val.int_value : r.val.float_value;
                res.type = INT_TYPE;
                if (node->type == EQ_OP) res.val.int_value = (lv == rv);
                else if (node->type == NE_OP) res.val.int_value = (lv != rv);
                else if (node->type == GT_OP) res.val.int_value = (lv > rv);
                else if (node->type == GE_OP) res.val.int_value = (lv >= rv);
                else if (node->type == LT_OP) res.val.int_value = (lv < rv);
                else if (node->type == LE_OP) res.val.int_value = (lv <= rv);
            }
            break;
        }
        case UMINUS_OP: {
            if (node->child_count >= 1) {
                Result v = eval_expression(node->children[0]);
                if (semantic_error) {
                    return res;
                }
                res.type = v.type;
                if (v.type == INT_TYPE) {
                    res.val.int_value = -v.val.int_value;
                } else {
                    res.val.float_value = -v.val.float_value;
                }
            }
            break;
        }
    }
    return res;
}
void execute_tree(Node *node) {
    if (!node) return;
    if (semantic_error) return;
    switch (node->type) {
        case PROGRAM:
        case STMT_LIST:
        case COMPOUND_STMT:
        case STMT:
            for (int i = 0; i < node->child_count; i++) {
                execute_tree(node->children[i]);
                if (semantic_error) return;
            }
            break;
        case SCAN_STMT: {
            if (node->child_count >= 1 && node->children[0]->type == ID_NODE) {
                char *name = node->children[0]->id_name;
                char buf[100];
                if (scanf("%s", buf) == 1) {
                    Value v;
                    ValueType t;
                    if (strchr(buf, '.')) {
                        t = FLOAT_TYPE;
                        v.float_value = atof(buf);
                    } else {
                        t = INT_TYPE;
                        v.int_value = atoi(buf);
                    }
                    set_symbol(name, t, v);
                }
            }
            break;
        }
        case PRINT_STMT: {
            if (node->child_count >= 1) {
                Result r = eval_expression(node->children[0]);
                if (semantic_error) return;
                if (r.type == INT_TYPE) {
                    printf("%d\n", r.val.int_value);
                } else {
                    printf("%f\n", r.val.float_value);
                }
            }
            break;
        }
        case IF_STMT: {
            if (node->child_count >= 2) {
                Result cond = eval_expression(node->children[0]);
                if (semantic_error) return;
                if (is_true_result(cond)) {
                    execute_tree(node->children[1]);
                } else if (node->child_count >= 3) {
                    execute_tree(node->children[2]);
                }
            }
            break;
        }
        case WHILE_STMT: {
            if (node->child_count >= 2) {
                while (1) {
                    Result cond = eval_expression(node->children[0]);
                    if (semantic_error) return;
                    if (!is_true_result(cond)) break;
                    execute_tree(node->children[1]);
                    if (semantic_error) return;
                }
            }
            break;
        }
        default:
            eval_expression(node);
            break;
    }
}