%{
#include "parser.tab.h"
#include <stdlib.h>
#include <string.h>
void yyerror(const char *s);
%}

DIGIT   [0-9]
ID      [A-Za-z_][A-Za-z0-9_]*
NUM     {DIGIT}+

%%

"enquanto"      { return WHILE; }
"se"            { return IF; }
"senao"         { return ELSE; }

{ID}            { yylval.str = strdup(yytext); return IDENT; }
{NUM}           { yylval.num = atol(yytext); return NUMBER; }

"==" { return EQ; } "!=" { return NEQ; } ">=" { return GTE; } "<=" { return LTE; }
">"  { return GT; } "<"  { return LT; }

"="  { return ASSIGN; }
";"  { return ';'; } "," { return ','; }
"("  { return '('; } ")" { return ')'; }
"{"  { return '{'; } "}" { return '}'; }

"+" { return '+'; } "-" { return '-'; }
"*" { return '*'; } "/" { return '/'; } "%" { return '%'; }

[ \t\r\n]+  ;
.           { return yytext[0]; }

%%

int yywrap(void) { return 1; }
