%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include "ast.h"

extern int yylex(void);
extern FILE *yyin;
extern int yylineno;
void yyerror(const char *s);

/* helper: root_program constructed by parser */
Stmt *root_program = NULL;

/* ExprList helper type for passing arg lists in bison actions */
typedef struct { Expr **arr; int n; } ExprList;

ExprList *elist_new(void) {
    ExprList *l = malloc(sizeof(*l));
    l->arr = NULL;
    l->n = 0;
    return l;
}
void elist_push(ExprList *l, Expr *e) {
    l->arr = realloc(l->arr, sizeof(Expr*) * (l->n + 1));
    l->arr[l->n++] = e;
}
Expr **elist_to_array(ExprList *l) {
    if (!l) return NULL;
    return l->arr;
}

/* node constructors (simple implementations) */
Expr *new_num(long v);
Expr *new_var(char *name);
Expr *new_binop(char op, Expr *l, Expr *r);
Expr *new_call(char *name, Expr **args, int nargs);

Stmt *new_assign(char *name, Expr *val);
Stmt *new_expr_stmt(Expr *e);
Stmt *new_if(Expr *cond, Stmt *thenb, Stmt *elseb);
Stmt *new_while(Expr *cond, Stmt *body);
Stmt *new_block(Stmt **stmts, int n);

/* implementations (quick and small) */
Expr *new_num(long v) {
    Expr *e = calloc(1,sizeof(Expr));
    e->kind = EXPR_NUM;
    e->u.num = v;
    return e;
}
Expr *new_var(char *name) {
    Expr *e = calloc(1,sizeof(Expr));
    e->kind = EXPR_VAR;
    e->u.name = strdup(name);
    return e;
}
Expr *new_binop(char op, Expr *l, Expr *r) {
    Expr *e = calloc(1,sizeof(Expr));
    e->kind = EXPR_BINOP;
    e->u.binop.op = op;
    e->u.binop.left = l;
    e->u.binop.right = r;
    return e;
}
Expr *new_call(char *name, Expr **args, int nargs) {
    Expr *e = calloc(1,sizeof(Expr));
    e->kind = EXPR_CALL;
    e->u.call.name = strdup(name);
    e->u.call.args = args;
    e->u.call.nargs = nargs;
    return e;
}

Stmt *new_assign(char *name, Expr *val) {
    Stmt *s = calloc(1,sizeof(Stmt));
    s->kind = ST_ASSIGN;
    s->u.assign.name = strdup(name);
    s->u.assign.value = val;
    return s;
}
Stmt *new_expr_stmt(Expr *e) {
    Stmt *s = calloc(1,sizeof(Stmt));
    s->kind = ST_EXPR;
    s->u.expr.expr = e;
    return s;
}
Stmt *new_if(Expr *cond, Stmt *thenb, Stmt *elseb) {
    Stmt *s = calloc(1,sizeof(Stmt));
    s->kind = ST_IF;
    s->u.ifs.cond = cond;
    s->u.ifs.then_branch = thenb;
    s->u.ifs.else_branch = elseb;
    return s;
}
Stmt *new_while(Expr *cond, Stmt *body) {
    Stmt *s = calloc(1,sizeof(Stmt));
    s->kind = ST_WHILE;
    s->u.wh.cond = cond;
    s->u.wh.body = body;
    return s;
}
Stmt *new_block(Stmt **stmts, int n) {
    Stmt *s = calloc(1,sizeof(Stmt));
    s->kind = ST_BLOCK;
    s->u.block.stmts = stmts;
    s->u.block.n = n;
    return s;
}

/* helper to append a statement into a block (realloc array) */
Stmt **append_stmt_array(Stmt **arr, int *n, Stmt *s) {
    arr = realloc(arr, sizeof(Stmt*) * (*n + 1));
    arr[*n] = s;
    (*n)++;
    return arr;
}

%}

%union {
    long num;
    char *str;
    Expr *expr;
    Stmt *stmt;
    ExprList *elist;
    struct { Stmt **arr; int n; } stmtarr;
}

%token <str> IDENT
%token <num> NUMBER
%token WHILE IF ELSE PRINT THEN
%token EQ NEQ GTE LTE GT LT ASSIGN

/* declare types for non-terminals used with $n / $$ */
%type <expr> expression term factor
%type <stmt> statement assignment function_call print_statement while_statement if_statement
%type <stmtarr> program_block
%type <elist> func_args

%left '+' '-'
%left '*' '/' '%'

%%

program:
    program_block { root_program = new_block($1.arr, $1.n); }
    ;

program_block:
      /* empty */ { $$.arr = NULL; $$.n = 0; }
    | program_block statement {
        $$.arr = $1.arr; $$.n = $1.n;
        $$.arr = append_stmt_array($$.arr, &$$.n, $2);
    }
    ;

statement:
      assignment                { $$ = $1; }
    | function_call             { $$ = $1; }
    | print_statement           { $$ = $1; }
    | while_statement           { $$ = $1; }
    | if_statement              { $$ = $1; }
    | IF '(' expression ')' THEN IDENT '(' ')' ';' {
            /* short form: if (expr) ident() ; */
            Expr *cond = $3;
            Expr *call = new_call($6, NULL, 0);
            Stmt *callst = new_expr_stmt(call);
            $$ = new_if(cond, callst, NULL);
            free($6);
        }
    | IF '(' expression ')' THEN IDENT '(' expression ')' ';' {
            Expr *cond = $3;
            Expr *arg = $8;
            Expr **args = malloc(sizeof(Expr*));
            args[0] = arg;
            Expr *call = new_call($6, args, 1);
            Stmt *callst = new_expr_stmt(call);
            $$ = new_if(cond, callst, NULL);
            free($6);
        }
    | ';'                      { $$ = NULL; }
    ;

assignment:
    IDENT ASSIGN expression ';' {
        $$ = new_assign($1, $3);
        free($1);
    }
    ;

function_call:
    IDENT '(' ')' ';' {
        Expr *call = new_call($1, NULL, 0);
        $$ = new_expr_stmt(call);
        free($1);
    }
  | IDENT '(' func_args ')' ';' {
        int nargs = $3 ? $3->n : 0;
        Expr **args = nargs ? $3->arr : NULL;
        Expr *call = new_call($1, args, nargs);
        $$ = new_expr_stmt(call);
        free($1);
        if ($3) free($3);
    }
    ;

print_statement:
    PRINT '(' expression ')' ';' {
        /* cria uma chamada print(expr) como statement */
        Expr **pa = malloc(sizeof(Expr*));
        pa[0] = $3;
        Expr *call = new_call("print", pa, 1);
        $$ = new_expr_stmt(call);
    }
    ;

while_statement:
    WHILE '(' expression ')' '{' program_block '}' {
        Stmt *body = new_block($6.arr, $6.n);
        $$ = new_while($3, body);
    }
    ;

if_statement:
    IF '(' expression ')' '{' program_block '}' {
        Stmt *thenb = new_block($6.arr, $6.n);
        $$ = new_if($3, thenb, NULL);
    }
  | IF '(' expression ')' '{' program_block '}' ELSE '{' program_block '}' {
        Stmt *thenb = new_block($6.arr, $6.n);
        Stmt *elseb = new_block($10.arr, $10.n);
        $$ = new_if($3, thenb, elseb);
    }
  ;

func_args:
      /* single */ expression {
          ExprList *l = elist_new();
          elist_push(l, $1);
          $$ = l;
      }
    | expression ',' expression {
          ExprList *l = elist_new();
          elist_push(l, $1);
          elist_push(l, $3);
          $$ = l;
      }
    ;

expression:
      term { $$ = $1; }
    | expression '+' term { $$ = new_binop('+', $1, $3); }
    | expression '-' term { $$ = new_binop('-', $1, $3); }
    ;

term:
      factor { $$ = $1; }
    | term '*' factor { $$ = new_binop('*', $1, $3); }
    | term '/' factor { $$ = new_binop('/', $1, $3); }
    | term '%' factor { $$ = new_binop('%', $1, $3); }
    ;

factor:
      NUMBER { $$ = new_num($1); }
    | IDENT {
        $$ = new_var($1);
        free($1);
    }
    | IDENT '(' func_args ')' {
        int nargs = $3 ? $3->n : 0;
        Expr **args = nargs ? $3->arr : NULL;
        $$ = new_call($1, args, nargs);
        free($1);
        if ($3) free($3);
    }
    | '(' expression ')' { $$ = $2; }
    ;
%%

/* minimal error handler */
void yyerror(const char *s) {
    fprintf(stderr, "Erro sintático: %s (linha %d)\n", s, yylineno);
}
