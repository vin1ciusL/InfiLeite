#include <stdio.h>
#include <stdlib.h>

extern FILE *yyin;
int yyparse(void);

int main(int argc, char **argv) {
    if (argc < 2) {
        fprintf(stderr, "Uso: %s arquivo.infi\n", argv[0]);
        return 1;
    }
    yyin = fopen(argv[1], "r");
    if (!yyin) { perror("fopen"); return 1; }
    int res = yyparse();
    fclose(yyin);
    if (res == 0) {
        printf("Parse completed: syntactic analysis OK.\n");
        return 0;
    } else {
        fprintf(stderr, "Parse failed (syntax errors found).\n");
        return 2;
    }
}
