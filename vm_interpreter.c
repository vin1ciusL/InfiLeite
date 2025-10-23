/* vm_interpreter.c -- interpreta o assembly textual gerado por codegen.c */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#define STACK_SIZE 1024

typedef struct Var {
    char *name;
    long value;
    struct Var *next;
} Var;

static Var *vars = NULL;
static long stackv[STACK_SIZE];
static int sp = 0;

static void push(long v) {
    if (sp >= STACK_SIZE) { fprintf(stderr,"stack overflow\n"); exit(1); }
    stackv[sp++] = v;
}
static long popv(void) {
    if (sp <= 0) { fprintf(stderr,"stack underflow\n"); return 0; }
    return stackv[--sp];
}
static Var *find_var(const char *name) {
    for (Var *v = vars; v; v=v->next) if (strcmp(v->name,name)==0) return v;
    return NULL;
}
static void set_var_vm(const char *name, long v) {
    Var *x = find_var(name);
    if (x) x->value = v;
    else {
        Var *n = malloc(sizeof(Var));
        n->name = strdup(name);
        n->value = v;
        n->next = vars;
        vars = n;
    }
}
static long get_var_vm(const char *name) {
    Var *x = find_var(name);
    if (x) return x->value;
    fprintf(stderr, "Aviso(vm): variável '%s' não declarada, usando 0\n", name);
    return 0;
}

static void trim(char *s) { /* rstrip newline */ char *p=strchr(s,'\n'); if (p) *p=0; }

int run_vm(const char *fname) {
    FILE *f = fopen(fname,"r");
    if (!f) { perror("fopen asm"); return 0; }
    char line[512];
    while (fgets(line,sizeof(line),f)) {
        trim(line);
        if (line[0]=='#' || strlen(line)==0) continue;
        /* labels end with ':' -> skip */
        int L = strlen(line);
        if (line[L-1]==':') continue;
        char op[64], arg1[256];
        op[0]=arg1[0]=0;
        sscanf(line, "%s %[^\n]", op, arg1);
        if (strcmp(op,"PUSH_CONST")==0) {
            long v = atol(arg1);
            push(v);
        } else if (strcmp(op,"POP")==0) {
            popv();
        } else if (strcmp(op,"LOAD")==0) {
            long v = get_var_vm(arg1);
            push(v);
        } else if (strcmp(op,"STORE")==0) {
            long v = popv();
            set_var_vm(arg1, v);
        } else if (strcmp(op,"ADD")==0) {
            long b=popv(), a=popv(); push(a+b);
        } else if (strcmp(op,"SUB")==0) {
            long b=popv(), a=popv(); push(a-b);
        } else if (strcmp(op,"MUL")==0) {
            long b=popv(), a=popv(); push(a*b);
        } else if (strcmp(op,"DIV")==0) {
            long b=popv(), a=popv(); push(b==0?0:(a/b));
        } else if (strcmp(op,"MOD")==0) {
            long b=popv(), a=popv(); push(b==0?0:(a%b));
        } else if (strcmp(op,"LT")==0) {
            long b=popv(), a=popv(); push(a < b ? 1 : 0);
        } else if (strcmp(op,"GT")==0) {
            long b=popv(), a=popv(); push(a > b ? 1 : 0);
        } else if (strcmp(op,"EQ")==0) {
            long b=popv(), a=popv(); push(a == b ? 1 : 0);
        } else if (strcmp(op,"NEQ")==0) {
            long b=popv(), a=popv(); push(a != b ? 1 : 0);
        } else if (strcmp(op,"JZ")==0) {
            /* pop top, if zero jump to label: implement by scanning file (slow but OK) */
            long v = popv();
            if (v == 0) {
                /* rewind file and find label line "label:" */
                rewind(f);
                char target_label[256];
                snprintf(target_label, sizeof(target_label), "%s:", arg1);
                while (fgets(line,sizeof(line),f)) {
                    trim(line);
                    if (strcmp(line, target_label)==0) break;
                }
            }
        } else if (strcmp(op,"JMP")==0) {
            rewind(f);
            char target_label[256];
            snprintf(target_label, sizeof(target_label), "%s:", arg1);
            while (fgets(line,sizeof(line),f)) {
                trim(line);
                if (strcmp(line, target_label)==0) break;
            }
        } else if (strcmp(op,"CALL")==0) {
            /* arg1 = "<name> <nargs>" */
            char name[128]; int nargs=0;
            sscanf(arg1, "%s %d", name, &nargs);
            if (strcmp(name,"aleatorio")==0 && nargs==2) {
                long b=popv(), a=popv();
                long r = (random() % (b - a + 1)) + a;
                push(r);
            } else {
                fprintf(stderr,"CALL: builtin unknown %s\n", name);
            }
        } else if (strcmp(op,"PRINT")==0) {
            long v = popv();
            printf("%ld\n", v);
        } else if (strcmp(op,"HALT")==0) {
            break;
        } else {
            fprintf(stderr,"unknown op '%s' (line='%s')\n", op, line);
        }
    }
    fclose(f);
    return 1;
}

/* small main for the VM */
#ifdef VM_MAIN
int main(int argc, char **argv) {
    if (argc < 2) { fprintf(stderr,"Usage: %s file.asm\n", argv[0]); return 1; }
    srandom((unsigned)time(NULL));
    run_vm(argv[1]);
    return 0;
}
#endif
