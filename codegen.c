/* codegen.c  -- gera assembly textual para uma ToyVM */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast.h"

static FILE *out;
static int label_counter = 0;

static char *new_label(const char *prefix) {
    char buf[64];
    snprintf(buf, sizeof(buf), "%s_%d", prefix, label_counter++);
    return strdup(buf);
}

static void emit(const char *fmt, ...) {
    va_list ap;
    va_start(ap, fmt);
    vfprintf(out, fmt, ap);
    fprintf(out, "\n");
    va_end(ap);
}

void generate_expr(Expr *e);

void generate_binop(Expr *e) {
    /* generate left then right, then op uses stack */
    generate_expr(e->u.binop.left);
    generate_expr(e->u.binop.right);
    char op = e->u.binop.op;
    switch (op) {
        case '+': emit("ADD"); break;
        case '-': emit("SUB"); break;
        case '*': emit("MUL"); break;
        case '/': emit("DIV"); break;
        case '%': emit("MOD"); break;
        case '<': emit("LT"); break;
        case '>': emit("GT"); break;
        case '=': emit("EQ"); break;
        case '!': emit("NEQ"); break;
        default: emit("NOP"); break;
    }
}

void generate_call(Expr *e) {
    /* only implement aleatorio(a,b) as example that returns value via runtime call
       We'll encode a CALL <name> <nargs> and VM interpreter must know builtin names */
    for (int i=0;i<e->u.call.nargs;i++) generate_expr(e->u.call.args[i]);
    emit("CALL %s %d", e->u.call.name, e->u.call.nargs);
}

void generate_expr(Expr *e) {
    if (!e) return;
    switch (e->kind) {
        case EXPR_NUM:
            emit("PUSH_CONST %ld", e->u.num);
            break;
        case EXPR_VAR:
            emit("LOAD %s", e->u.name);
            break;
        case EXPR_BINOP:
            generate_binop(e);
            break;
        case EXPR_CALL:
            generate_call(e);
            break;
        default:
            break;
    }
}

void generate_stmt(Stmt *s);

void generate_block(Stmt *b) {
    if (!b) return;
    for (int i=0;i<b->u.block.n;i++) generate_stmt(b->u.block.stmts[i]);
}

void generate_stmt(Stmt *s) {
    if (!s) return;
    switch (s->kind) {
        case ST_ASSIGN:
            generate_expr(s->u.assign.value);
            emit("STORE %s", s->u.assign.name);
            break;
        case ST_EXPR:
            generate_expr(s->u.expr.expr);
            emit("POP"); /* drop value if any */
            break;
        case ST_IF: {
            char *L_else = new_label("Lelse");
            char *L_end = new_label("Lend");
            generate_expr(s->u.ifs.cond);
            emit("JZ %s", L_else);
            generate_stmt(s->u.ifs.thenb);
            emit("JMP %s", L_end);
            emit("%s:", L_else);
            if (s->u.ifs.elseb) generate_stmt(s->u.ifs.elseb);
            emit("%s:", L_end);
            free(L_else); free(L_end);
            break;
        }
        case ST_WHILE: {
            char *L_start = new_label("Lwhile");
            char *L_end = new_label("Lend");
            emit("%s:", L_start);
            generate_expr(s->u.wh.cond);
            emit("JZ %s", L_end);
            generate_stmt(s->u.wh.body);
            emit("JMP %s", L_start);
            emit("%s:", L_end);
            free(L_start); free(L_end);
            break;
        }
        case ST_BLOCK:
            generate_block(s);
            break;
        default:
            break;
    }
}

int generate_asm(Stmt *root, const char *outfname) {
    out = fopen(outfname, "w");
    if (!out) return 0;
    emit("# ToyVM assembly generated");
    generate_stmt(root);
    emit("HALT");
    fclose(out);
    return 1;
}
