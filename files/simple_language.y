%{
#include <stdio.h>
#include <stdlib.h>

void yyerror(char *);
int yylex(void);

int sym[26];    /* 26 variables con nombres de una letra */
%}

%token NUMBER VARIABLE
%left '+' '-'
%left '*' '/'

%%
program:
        program statement '\n'     { printf(">> "); }
        | /* NULL */
        ;

statement:
        VARIABLE '=' expr          { 
            sym[$1] = $3; 
            printf("%c = %d\n", $1 + 'a', $3);
        }
        | expr                     { printf("= %d\n", $1); }
        ;

expr:
        NUMBER                     { $$ = $1; }
        | VARIABLE                 { $$ = sym[$1]; }
        | expr '+' expr            { $$ = $1 + $3; }
        | expr '-' expr            { $$ = $1 - $3; }
        | expr '*' expr            { $$ = $1 * $3; }
        | expr '/' expr            {
            if($3 == 0) {
                yyerror("División por cero");
                $$ = 0;
            } else {
                $$ = $1 / $3;
            }
        }
        | '(' expr ')'            { $$ = $2; }
        ;
%%

void yyerror(char *s) {
    fprintf(stderr, "Error: %s\n", s);
}

int main(void) {
    printf("Analizador sintáctico iniciado.\n");
    printf(">> ");
    yyparse();
    return 0;
}