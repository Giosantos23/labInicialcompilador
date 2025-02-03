%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int lineno = 1;
void yyerror(const char *s);
int yylex(void);

// Estructura para la tabla de símbolos
struct symbol {
    char *name;
    double value;
    struct symbol *next;
};

struct symbol *sym_table = NULL;

// Funciones para manejar la tabla de símbolos
struct symbol *lookup(char *name);
void insert(char *name, double value);
%}

%union {
    int int_val;
    double float_val;
    char *string;
}

%token <string> IDENTIFIER
%token <int_val> INTEGER
%token <float_val> FLOAT
%token ADD SUB MUL DIV
%token ASSIGN SEMICOLON LPAREN RPAREN
%token PRINT

%type <float_val> expression
%type <float_val> term
%type <float_val> factor

// Definir precedencia y asociatividad
%left ADD SUB
%left MUL DIV

%%

program:
    | program statement
    ;

statement:
    IDENTIFIER ASSIGN expression SEMICOLON {
        insert($1, $3);
        printf("%s = %f\n", $1, $3);
        free($1);
    }
    | PRINT expression SEMICOLON {
        printf("Resultado: %f\n", $2);
    }
    | error SEMICOLON {
        yyerrok;
    }
    ;

expression:
    expression ADD term { $$ = $1 + $3; }
    | expression SUB term { $$ = $1 - $3; }
    | term { $$ = $1; }
    ;

term:
    term MUL factor { $$ = $1 * $3; }
    | term DIV factor {
        if ($3 == 0) {
            yyerror("División por cero");
            $$ = 0;
        } else {
            $$ = $1 / $3;
        }
    }
    | factor { $$ = $1; }
    ;

factor:
    INTEGER { $$ = $1; }
    | FLOAT { $$ = $1; }
    | IDENTIFIER {
        struct symbol *s = lookup($1);
        if (s == NULL) {
            char msg[100];
            sprintf(msg, "Variable no definida: %s", $1);
            yyerror(msg);
            $$ = 0;
        } else {
            $$ = s->value;
        }
        free($1);
    }
    | LPAREN expression RPAREN { $$ = $2; }
    ;

%%

// Implementación de la tabla de símbolos
struct symbol *lookup(char *name) {
    struct symbol *s;
    for (s = sym_table; s != NULL; s = s->next) {
        if (strcmp(s->name, name) == 0) {
            return s;
        }
    }
    return NULL;
}

void insert(char *name, double value) {
    struct symbol *s = lookup(name);
    if (s == NULL) {
        s = (struct symbol *)malloc(sizeof(struct symbol));
        s->name = strdup(name);
        s->next = sym_table;
        sym_table = s;
    }
    s->value = value;
}

void yyerror(const char *s) {
    fprintf(stderr, "Error en línea %d: %s\n", lineno, s);
}

int main(void) {
    printf("Compilador iniciado. Ingrese expresiones:\n");
    printf("Ejemplo: x = 5; y = x + 3; print x + y;\n");
    printf("(Ctrl+D para salir)\n\n");
    yyparse();
    return 0;
}