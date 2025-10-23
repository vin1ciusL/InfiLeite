#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast.h"

/* extern runtime functions */
extern void ordenhar_run(void);
extern void vender_run(long);
extern void comprar_vaca_run(void);
extern void comprar_fazenda_run(void);
extern void tomar_leite_run(void);
extern void acasalar_run(void);
extern void cassino_run(void);
extern void maquina_run(long);
extern void comprar_ate_run(long);
extern void tomar_tudo_run(void);
extern void criar_vicio_run(void);
extern void resultado_run(void);
extern long get_var(const char *);
extern void set_var(const char *, long);
extern long aleatorio_run(long,long);
extern void push_scope(void);
extern void pop_scope(void);
extern void clear_all_scopes(void);

/* evaluate expressions */
static long eval_expr(Expr *e) {
    if (!e) return 0;
    switch (e->kind) {
        case EXPR_NUM: return e->u.num;
        case EXPR_VAR: return get_var(e->u.name);
        case EXPR_BINOP: {
            long l = eval_expr(e->u.binop.left);
            long r = eval_expr(e->u.binop.right);
            switch (e->u.binop.op) {
                case '+': return l + r;
                case '-': return l - r;
                case '*': return l * r;
                case '/': return r==0?0:(l / r);
                case '%': return r==0?0:(l % r);
                default: return 0;
            }
        }
        case EXPR_CALL: {
            if (strcmp(e->u.call.name, "aleatorio")==0 && e->u.call.nargs==2) {
                long a = eval_expr(e->u.call.args[0]);
                long b = eval_expr(e->u.call.args[1]);
                return aleatorio_run(a,b);
            }
            return 0;
        }
    }
    return 0;
}

static void exec_stmt(Stmt *s);

static void exec_block(Stmt *block) {
    if (!block) return;
    if (block->kind != ST_BLOCK) return;
    push_scope();
    for (int i=0;i<block->u.block.n;i++) exec_stmt(block->u.block.stmts[i]);
    pop_scope();
}


static void exec_stmt(Stmt *s) {
    if (!s) return;
    switch (s->kind) {
        case ST_ASSIGN: {
            long v = eval_expr(s->u.assign.value);
            set_var(s->u.assign.name, v);
            break;
        }
        case ST_EXPR: {
            Expr *e = s->u.expr.expr;
            if (!e) break;
            if (e->kind == EXPR_CALL) {
                char *name = e->u.call.name;
                int n = e->u.call.nargs;
                if (strcmp(name,"ordenhar")==0) ordenhar_run();
                else if (strcmp(name,"vender")==0 && n==1) { long q = eval_expr(e->u.call.args[0]); vender_run(q); }
                else if (strcmp(name,"comprar_vaca")==0) comprar_vaca_run();
                else if (strcmp(name,"comprar_fazenda")==0) comprar_fazenda_run();
                else if (strcmp(name,"tomar_leite")==0) tomar_leite_run();
                else if (strcmp(name,"acasalar")==0) acasalar_run();
                else if (strcmp(name,"cassino")==0) cassino_run();
                else if (strcmp(name,"maquina")==0 && n==1) { long opt = eval_expr(e->u.call.args[0]); maquina_run(opt); }
                else if (strcmp(name,"comprar_ate")==0 && n==1) { long t=eval_expr(e->u.call.args[0]); comprar_ate_run(t); }
                else if (strcmp(name,"tomar_tudo")==0) tomar_tudo_run();
                else if (strcmp(name,"criar_vicio")==0) criar_vicio_run();
                else if (strcmp(name,"resultado")==0) resultado_run();
            } else {
                (void)eval_expr(e);
            }
            break;
        }
        case ST_IF: {
            long cond = eval_expr(s->u.ifs.cond);
            if (cond) exec_stmt(s->u.ifs.then_branch);
            else if (s->u.ifs.else_branch) exec_stmt(s->u.ifs.else_branch);
            break;
        }
        case ST_WHILE: {
            while (eval_expr(s->u.wh.cond)) {
                exec_stmt(s->u.wh.body);
            }
            break;
        }
        case ST_BLOCK: {
            exec_block(s);
            break;
        }
    }
}

void exec_stmt_list(Stmt *root) {
    if (!root) return;
    if (root->kind == ST_BLOCK) exec_block(root);
    else exec_stmt(root);
}
