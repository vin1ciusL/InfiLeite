#ifndef AST_H
#define AST_H

typedef enum { EXPR_NUM, EXPR_VAR, EXPR_BINOP, EXPR_CALL } ExprKind;
typedef enum { ST_ASSIGN, ST_EXPR, ST_IF, ST_WHILE, ST_BLOCK } StmtKind;

typedef struct Expr {
    ExprKind kind;
    union {
        long num;                /* EXPR_NUM */
        char *name;              /* EXPR_VAR */
        struct {                  /* EXPR_BINOP */
            char op;
            struct Expr *left;
            struct Expr *right;
        } binop;
        struct {                  /* EXPR_CALL */
            char *name;
            struct Expr **args;
            int nargs;
        } call;
    } u;
} Expr;

typedef struct Stmt {
    StmtKind kind;
    union {
        struct { char *name; Expr *value; } assign; /* ST_ASSIGN */
        struct { Expr *expr; } expr;                /* ST_EXPR (calls, print) */
        struct { Expr *cond; struct Stmt *then_branch; struct Stmt *else_branch; } ifs; /* ST_IF */
        struct { Expr *cond; struct Stmt *body; } wh; /* ST_WHILE */
        struct { struct Stmt **stmts; int n; } block; /* ST_BLOCK (sequence) */
    } u;
} Stmt;

/* helpers */
Expr *new_num(long v);
Expr *new_var(char *name);
Expr *new_binop(char op, Expr *l, Expr *r);
Expr *new_call(char *name, Expr **args, int nargs);

Stmt *new_assign(char *name, Expr *val);
Stmt *new_expr_stmt(Expr *e);
Stmt *new_if(Expr *cond, Stmt *thenb, Stmt *elseb);
Stmt *new_while(Expr *cond, Stmt *body);
Stmt *new_block(Stmt **stmts, int n);

void free_expr(Expr *e);
void free_stmt(Stmt *s);

/* root program filled by parser.y */
extern Stmt *root_program;

typedef struct ExprList {
    struct Expr **arr;
    int n;
} ExprList;

#endif
