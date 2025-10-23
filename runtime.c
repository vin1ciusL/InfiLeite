#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include "ast.h"
#include <stdint.h>
typedef struct Var {
    char *name;
    long value;
    struct Var *next;
} Var;

typedef struct Scope {
    Var *vars;
    struct Scope *next;
} Scope;

static Scope *scope_stack = NULL;

void push_scope(void) {
    Scope *s = malloc(sizeof(Scope));
    s->vars = NULL;
    s->next = scope_stack;
    scope_stack = s;
}

void pop_scope(void) {
    if (!scope_stack) return;
    Scope *s = scope_stack;
    scope_stack = s->next;
    Var *v = s->vars;
    while (v) {
        Var *n = v->next;
        free(v->name);
        free(v);
        v = n;
    }
    free(s);
}

void clear_all_scopes(void) {
    while (scope_stack) pop_scope();
}

static Var *find_var_in_scopes(const char *name) {
    Scope *s = scope_stack;
    while (s) {
        Var *v = s->vars;
        while (v) {
            if (strcmp(v->name, name) == 0) return v;
            v = v->next;
        }
        s = s->next;
    }
    return NULL;
}

int var_exists(const char *name) {
    return find_var_in_scopes(name) != NULL;
}

long get_var(const char *name) {
    Var *v = find_var_in_scopes(name);
    if (v) return v->value;
    fprintf(stderr, "Aviso: variável '%s' não declarada. Usando 0 como valor.\n", name);
    return 0;
}

void set_var(const char *name, long v) {
    if (!scope_stack) push_scope(); 
    Var *found = find_var_in_scopes(name);
    if (found) {
        found->value = v;
        return;
    }
    Var *nv = malloc(sizeof(Var));
    nv->name = strdup(name);
    nv->value = v;
    nv->next = scope_stack->vars;
    scope_stack->vars = nv;
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


long aleatorio_run(long a, long b) {
    if (b < a) { long t=a; a=b; b=t; }
    if (a==b) return a;
    long r = (rand() % (b - a + 1)) + a;
    return r;
}

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

long runtime_get_leite() { return leite; }
long runtime_get_dinheiro() { return dinheiro; }
long runtime_get_vacas() { return vacas; }
long runtime_get_bred() { return bred_cows; }

void comprar_ate_run(long target) {
    op_count++;
    if (target <= 0) return;
    while (vacas < target) {
        double price = cow_price * (1.0 - ((double)vehicle_discount_percent / 100.0));
        long p = (long)(price + 0.999);
        if (dinheiro < p) break;
        dinheiro -= p;
        vacas += 1;
        printf("comprar_vaca -> vacas=%ld, dinheiro=%ld (preco %ld)\n", vacas, dinheiro, p);
    }
}
void tomar_tudo_run() {
    while (leite > 0) {
        tomar_leite_run();
    }
    printf("tomar_tudo -> terminou (leite=%ld)\n", leite);
}
void criar_vicio_run() {
    op_count++;
    long maxbets = dinheiro / 1000;
    long n = maxbets >= 7 ? 7 : maxbets;
    if (n == 0) {
        printf("criar_vicio -> sem dinheiro para apostar\n");
        return;
    }
    for (long i = 0; i < n; ++i) {
        cassino_run();
    }
    printf("criar_vicio -> apostou %ld vezes\n", n);
}
