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

%token <str> IDENT
%token <num> NUMBER
%token WHILE IF ELSE
%token EQ NEQ GTE LTE GT LT
%token ASSIGN
%type <num> expression term factor
%type <str> args

%left '+' '-'
%left '*' '/' '%'

%%

program:
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
    IDENT ASSIGN expression ';' { free($1); }
    ;

function_call:
    IDENT '(' ')' ';' { free($1); }
    | IDENT '(' args ')' ';' { if($3) free($3); free($1); }
    ;

args:
      expression { $$ = strdup("1"); }
    | args ',' expression {
          int prev = atoi($1);
          char buf[32];
          snprintf(buf, sizeof(buf), "%d", prev+1);
          free($1);
          $$ = strdup(buf);
      }
    ;

while_statement:
    WHILE '(' condition ')' '{' program '}' ;
    
if_statement:
    IF '(' condition ')' '{' program '}' 
    | IF '(' condition ')' '{' program '}' ELSE '{' program '}' 
    ;

condition:
    expression comparator expression ;

comparator:
      EQ | NEQ | GT | LT | GTE | LTE ;

expression:
      term
    | expression '+' term
    | expression '-' term
    ;

term:
      factor
    | term '*' factor
    | term '/' factor
    | term '%' factor
    ;

factor:
      NUMBER
    | IDENT { free($1); }
    | '(' expression ')'
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Erro sintático: %s (linha %d)\n", s, yylineno);
}
