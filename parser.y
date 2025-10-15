%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int yylex(void);
extern int yylineno;
void yyerror(const char *s);
%}

%union {
    long num;
    char *str;
}

/* tokens */
%token <str> IDENT
%token <num> NUMBER
%token WHILE IF ELSE
%token EQ NEQ GTE LTE GT LT
%token ASSIGN

/* Declare types for nonterminals that use values */
%type <num> expression term factor
%type <str> args

%left '+' '-'
%left '*' '/' '%'

%%

/* grammar matches your gramatica.ebnf */
program:
      /* empty */
    | program statement
    ;

statement:
      assignment
    | function_call
    | while_statement
    | if_statement
    | ';'
    ;

assignment:
    IDENT ASSIGN expression ';' {
        /* semantic not required for entrega 2: just accept */
        free($1);
    }
    ;

function_call:
    IDENT '(' ')' ';' {
        free($1);
    }
    | IDENT '(' args ')' ';' {
        /* $3 is args (a string with argcount) or NULL */
        if ($3) free($3);
        free($1);
    }
    ;

args:
      expression {
          /* single arg -> return "1" as argcount string (only structural) */
          $$ = strdup("1");
      }
    | args ',' expression {
          int prev = atoi($1);
          char buf[32];
          snprintf(buf, sizeof(buf), "%d", prev+1);
          free($1);
          $$ = strdup(buf);
      }
    ;

while_statement:
    WHILE '(' condition ')' '{' program '}' { /* nothing to do */ }
    ;

if_statement:
    IF '(' condition ')' '{' program '}' {
        /* optional else handled below */
    }
    | IF '(' condition ')' '{' program '}' ELSE '{' program '}' {
        /* if-else */
    }
    ;

condition:
    expression comparator expression {
        /* no semantic action; just accept */
    }
    ;

comparator:
      EQ { }
    | NEQ { }
    | GT { }
    | LT { }
    | GTE { }
    | LTE { }
    ;

expression:
      term { $$ = $1; }
    | expression '+' term { $$ = 0; }
    | expression '-' term { $$ = 0; }
    ;

term:
      factor { $$ = $1; }
    | term '*' factor { $$ = 0; }
    | term '/' factor { $$ = 0; }
    | term '%' factor { $$ = 0; }
    ;

factor:
      NUMBER { $$ = $1; }
    | IDENT { free($1); $$ = 0; }
    | '(' expression ')' { $$ = $2; }
    ;

%%

void yyerror(const char *s) {*
