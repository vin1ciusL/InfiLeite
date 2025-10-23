#include <stdio.h>
#include <stdlib.h>
#include <time.h>

extern FILE *yyin;
int yyparse(void);
extern struct Stmt *root_program;
void exec_stmt_list(struct Stmt *root);
void free_stmt(struct Stmt *s);
void clear_all_scopes(void);

int main(int argc, char **argv) {
    if (argc < 2) {
        fprintf(stderr, "Uso: %s arquivo.infi\n", argv[0]);
        return 1;
    }
    yyin = fopen(argv[1], "r");
    if (!yyin) { perror("fopen"); return 1; }
    srand((unsigned)time(NULL));
    int res = yyparse();
    fclose(yyin);
    if (res == 0) {
        if (root_program) exec_stmt_list(root_program);
        /* free AST and runtime scopes */
        if (root_program) free_stmt(root_program);
        clear_all_scopes();
        printf("\nParse completed: syntactic analysis OK.\n");
        return 0;
    } else {
        fprintf(stderr, "Parse failed (syntax errors found).\n");
        return 2;
    }
}
