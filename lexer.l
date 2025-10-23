%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast.h"
#include "parser.tab.h"
extern int yylineno;
%}

DIGIT   [0-9]
ID      [A-Za-z_][A-Za-z0-9_]*
NUM     {DIGIT}+

%%

"enquanto"      { return WHILE; }
"se"            { return IF; }
"entao"         { return THEN; }
"senao"         { return ELSE; }
"print"         { return PRINT; }

{ID}            { yylval.str = strdup(yytext); return IDENT; }
{NUM}           { yylval.num = atol(yytext); return NUMBER; }

"=="            { return EQ; }
"!="            { return NEQ; }
">="            { return GTE; }
"<="            { return LTE; }

">"             { return GT; }
"<"             { return LT; }

"="             { return ASSIGN; }

";"             { return ';'; }
","             { return ','; }

"("             { return '('; }
")"             { return ')'; }

"{"             { return '{'; }
"}"             { return '}'; }

"+"             { return '+'; }
"-"             { return '-' ;}

"*"             { return '*'; }
"/"             { return '/'; }
"%"             { return '%'; }

[ \t\r\n]+      ;

.               { return yytext[0]; }

%%

int yywrap(void) { return 1; }
