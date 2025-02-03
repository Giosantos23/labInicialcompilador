%{
#include "y.tab.h"
#include <stdlib.h>
void yyerror(char *);
%}

%%
[a-zA-Z]       { yylval = *yytext - 'a'; return VARIABLE; }
[0-9]+         { yylval = atoi(yytext); return NUMBER; }
[ \t]          ; 
\n             { return '\n'; }
"+"            { return '+'; }
"-"            { return '-'; }
"*"            { return '*'; }
"/"            { return '/'; }
"="            { return '='; }
"("            { return '('; }
")"            { return ')'; }
.              { yyerror("Token inválido"); }
%%

int yywrap(void) {
    return 1;
}