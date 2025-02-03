%{
#include "y.tab.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int lineno;
void yyerror(const char *s);
%}

%%
"print"         { return PRINT; }
[a-zA-Z_][a-zA-Z0-9_]*  { 
    yylval.string = strdup(yytext);
    return IDENTIFIER;
}
[0-9]+\.[0-9]+ { 
    yylval.float_val = atof(yytext);
    return FLOAT;
}
[0-9]+        { 
    yylval.int_val = atoi(yytext);
    return INTEGER;
}
"+"           { return ADD; }
"-"           { return SUB; }
"*"           { return MUL; }
"/"           { return DIV; }
"="           { return ASSIGN; }
"("           { return LPAREN; }
")"           { return RPAREN; }
";"           { return SEMICOLON; }
[\n]          { lineno++; }
[ \t]         ; /* Ignorar espacios en blanco */
.             { 
    char msg[100];
    sprintf(msg, "Token inválido: %s", yytext);
    yyerror(msg);
}

%%

int yywrap(void) {
    return 1;
}