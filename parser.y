%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
extern int yylex(void);
extern FILE *yyin;
extern int yylineno;
void yyerror(const char *s);
#define MAX_VARS 256
static char *var_name[MAX_VARS];
static long var_value[MAX_VARS];
static int var_count = 0;
long get_var(const char *name) {
    for (int i=0;i<var_count;i++) if (strcmp(var_name[i], name)==0) return var_value[i];
    return 0;
}
void set_var(const char *name, long v) {
    for (int i=0;i<var_count;i++) if (strcmp(var_name[i], name)==0) { var_value[i]=v; return; }
    if (var_count < MAX_VARS) {
        var_name[var_count] = strdup(name);
        var_value[var_count] = v;
        var_count++;
    }
}
static long leite = 0;
static long dinheiro = 0;
static long vacas = 1;
static long bred_cows = 0;
static double cow_price = 50.0;
static int cup_quality = 0;
static int vehicle_discount_percent = 0;
static int pasture_bonus_percent = 0;
static long op_count = 0;
void ordenhar_run() {
    op_count++;
    double effective = (double)(vacas - bred_cows) + (double)bred_cows * 0.2;
    effective += ((double)pasture_bonus_percent / 100.0) * (double)vacas;
    int maxprod = (int)(effective + 0.999);
    if (maxprod < 1) maxprod = 1;
    long ganho = (rand() % maxprod) + 1;
    leite += ganho;
    printf("ordenhar -> +%ld leite (total %ld)\n", ganho, leite);
}
void vender_run(long qtd) {
    op_count++;
    if (qtd > leite) qtd = leite;
    leite -= qtd;
    long ganho = qtd * 5;
    dinheiro += ganho;
    printf("vender(%ld) -> +$%ld (dinheiro %ld, leite %ld)\n", qtd, ganho, dinheiro, leite);
}
void comprar_vaca_run() {
    op_count++;
    double price = cow_price * (1.0 - ((double)vehicle_discount_percent / 100.0));
    long p = (long)(price + 0.999);
    if (dinheiro >= p) {
        dinheiro -= p;
        vacas += 1;
        printf("comprar_vaca -> vacas=%ld, dinheiro=%ld (preco %ld)\n", vacas, dinheiro, p);
    } else {
        printf("comprar_vaca falhou (dinheiro=%ld, preco %ld)\n", dinheiro, p);
    }
}
void comprar_fazenda_run() {
    op_count++;
    if (vacas >= 30 && dinheiro >= 100) {
        dinheiro -= 100;
        long aumento = (vacas * 50) / 100;
        vacas += aumento;
        printf("comprar_fazenda -> vacas=%ld (aumento +%ld), dinheiro=%ld\n", vacas, aumento, dinheiro);
    } else {
        printf("comprar_fazenda falhou (requer 30 vacas e 100 de dinheiro)\n");
    }
}
void tomar_leite_run() {
    if (leite >= 1) {
        leite -= 1;
        if (cup_quality == 0) printf("e nutritivo\n");
        else if (cup_quality == 1) printf("e nutritivo!\n");
        else if (cup_quality == 2) printf("e nutritivo!!\n");
        else if (cup_quality == 3) printf("e bem nutritivo!!\n");
    } else {
        printf("nao ha leite para tomar\n");
    }
}
void acasalar_run() {
    op_count++;
    if (vacas >= 2) {
        vacas -= 2;
        vacas += 3;
        bred_cows += 1;
        printf("acasalar -> nova vaca nascida (bred_cows=%ld), vacas=%ld\n", bred_cows, vacas);
    } else {
        printf("acasalar falhou (precisa de 2 vacas)\n");
    }
}
void cassino_run() {
    op_count++;
    if (dinheiro >= 1000) {
        dinheiro -= 1000;
        int r = rand() % 100;
        if (r < 49) {
            dinheiro += 1250;
            printf("cassino -> venceu! +1250 (dinheiro=%ld)\n", dinheiro);
        } else {
            printf("cassino -> perdeu (dinheiro=%ld)\n", dinheiro);
        }
    } else {
        printf("cassino falhou (precisa de 1000)\n");
    }
}
void maquina_run(long opt) {
    if (opt < 1 || opt > 9) {
        printf("maquina: opcao invalida\n");
        return;
    }
    if (opt >= 4) op_count++;
    if (opt == 1) cup_quality = 1;
    else if (opt == 2) cup_quality = 2;
    else if (opt == 3) cup_quality = 3;
    else if (opt == 4) vehicle_discount_percent = 5;
    else if (opt == 5) vehicle_discount_percent = 10;
    else if (opt == 6) vehicle_discount_percent = 20;
    else if (opt == 7) pasture_bonus_percent = 10;
    else if (opt == 8) pasture_bonus_percent = 20;
    else if (opt == 9) pasture_bonus_percent = 30;
    printf("maquina(%ld) -> cup_quality=%d vehicle_discount=%d pasture_bonus=%d\n", opt, cup_quality, vehicle_discount_percent, pasture_bonus_percent);
}

void resultado_run() {
    op_count++;
    printf("RESULTADO -> operacoes=%ld dinheiro=%ld vacas=%ld leite=%ld bred_cows=%ld\n", op_count, dinheiro, vacas, leite, bred_cows);
}
long aleatorio_run(long a, long b) {
    if (b < a) { long t=a; a=b; b=t; }
    if (a==b) return a;
    long r = (rand() % (b - a + 1)) + a;
    return r;
}
%}
%union {
    long num;
    char *str;
}
%token <str> IDENT
%token <num> NUMBER
%token WHILE IF ELSE PRINT
%token EQ NEQ GTE LTE GT LT ASSIGN
%type <num> expression term factor func_args
%left '+' '-'
%left '*' '/' '%'
%%

program:
    | program statement
    ;
statement:
      assignment
    | function_call
    | print_statement
    | while_statement
    | if_statement
    | ';'
    ;
assignment:
    IDENT ASSIGN expression ';' {
        set_var($1, $3);
        free($1);
    }
    ;
function_call:
    IDENT '(' ')' ';' {
        if (strcmp($1, "ordenhar")==0) ordenhar_run();
        else if (strcmp($1, "comprar_vaca")==0) comprar_vaca_run();
        else if (strcmp($1, "comprar_fazenda")==0) comprar_fazenda_run();
        else if (strcmp($1, "tomar_leite")==0) tomar_leite_run();
        else if (strcmp($1, "acasalar")==0) acasalar_run();
        else if (strcmp($1, "cassino")==0) cassino_run();
        else if (strcmp($1, "resultado")==0) resultado_run();
        else printf("funcao %s() chamada sem implementacao\n", $1);
        free($1);
    }
  | IDENT '(' expression ')' ';' {
        if (strcmp($1, "vender")==0) vender_run($3);
        else if (strcmp($1, "maquina")==0) maquina_run($3);
        else printf("funcao %s(arg) chamada sem implementacao\n", $1);
        free($1);
    }
    ;
print_statement:
    PRINT '(' expression ')' ';' {
        printf("%ld\n", $3);
    }
    ;
while_statement:
    WHILE '(' expression ')' '{' program '}' {
    }
    ;
if_statement:
    IF '(' expression ')' '{' program '}' {
    }
  | IF '(' expression ')' '{' program '}' ELSE '{' program '}' {
    }
  ;
condition:
    expression comparator expression ;
comparator:
      EQ | NEQ | GT | LT | GTE | LTE
    ;
expression:
      term { $$ = $1; }
    | expression '+' term { $$ = $1 + $3; }
    | expression '-' term { $$ = $1 - $3; }
    ;
term:
      factor { $$ = $1; }
    | term '*' factor { $$ = $1 * $3; }
    | term '/' factor { if ($3==0) $$ = 0; else $$ = $1 / $3; }
    | term '%' factor { if ($3==0) $$ = 0; else $$ = $1 % $3; }
    ;
factor:
      NUMBER { $$ = $1; }
    | IDENT {
        $$ = get_var($1);
        free($1);
    }
    | IDENT '(' func_args ')' {
        long packed = $3;
        long a = (int)(packed & 0xffffffff);
        long b = (int)((packed >> 32) & 0xffffffff);
        if (strcmp($1, "aleatorio")==0) {
            $$ = aleatorio_run(a, b);
        } else {
            $$ = 0;
        }
        free($1);
    }
    | '(' expression ')' { $$ = $2; }
    ;
func_args:
      expression { long pack = (long)( (unsigned long)$1 & 0xffffffffu ); $$ = pack; }
    | expression ',' expression { long a = (long)$1; long b = (long)$3; long pack = ( ( (long)( (unsigned long)b & 0xffffffffu) ) << 32 ) | ( (unsigned long)a & 0xffffffffu ); $$ = pack; }
    ;
%%
void yyerror(const char *s) {
    fprintf(stderr, "Erro sintático: %s (linha %d)\n", s, yylineno);
}
