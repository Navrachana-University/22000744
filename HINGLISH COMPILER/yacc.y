%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern FILE *yyin;
extern FILE *yyout;
int yylex(void);
void yyerror(char *);
char* newTemp();
char* newLabel();

int tempCount = 1;
int labelCount = 1;

char* newTemp() {
    char buffer[10];
    sprintf(buffer, "t%d", tempCount++);
    return strdup(buffer);
}

char* newLabel() {
    char buffer[10];
    sprintf(buffer, "L%d", labelCount++);
    return strdup(buffer);
}
%}

%union {
    struct {
        char* temp;  // Temporary variable (e.g., t7)
        char* code;  // TAC code (e.g., t1 = 100\n ...)
    } expr;
    char* str;  // For statements and statement blocks
}

%token <str> ID NUMBER
%token SHURU BOLO AGAR NAHITO JABTAK
%token AND OR NOT EQ NEQ LE GE

%type <expr> E T F G H I J
%type <str> Statement StatementBlock Statements

%%

Program : SHURU Statements {
            fprintf(yyout, "%s", $2);
            free($2);
        }
        ;

Statements : Statements Statement {
               char* temp = malloc(strlen($1) + strlen($2) + 1);
               sprintf(temp, "%s%s", $1, $2);
               free($1);
               free($2);
               $$ = temp;
           }
           | Statement { $$ = $1; }
           ;

Statement : ID '=' E ';' {
              char* temp = malloc(strlen($3.code) + strlen($1) + strlen($3.temp) + 20);
              sprintf(temp, "%s%s = %s\n", $3.code, $1, $3.temp);
              free($3.code);
              free($3.temp);
              $$ = temp;
          }
          | BOLO E ';' {
              char* temp = malloc(strlen($2.code) + strlen($2.temp) + 20);
              sprintf(temp, "%sprint %s\n", $2.code, $2.temp);
              free($2.code);
              free($2.temp);
              $$ = temp;
          }
          | AGAR '(' E ')' StatementBlock NAHITO StatementBlock {
              char* trueLabel = newLabel();
              char* falseLabel = newLabel();
              char* endLabel = newLabel();

              char* temp = malloc(strlen($3.code) + strlen($3.temp) + strlen($5) + strlen($7) + 100);
              sprintf(temp, "%sif %s goto %s\n"
                            "goto %s\n"
                            "%s:\n"
                            "%s"
                            "goto %s\n"
                            "%s:\n"
                            "%s"
                            "%s:\n",
                            $3.code, $3.temp, trueLabel, falseLabel,
                            trueLabel, $5, endLabel,
                            falseLabel, $7, endLabel);
              free($3.code);
              free($3.temp);
              free($5);
              free($7);
              free(trueLabel);
              free(falseLabel);
              free(endLabel);
              $$ = temp;
          }
          | JABTAK '(' E ')' StatementBlock {
              char* startLabel = newLabel();
              char* bodyLabel = newLabel();
              char* endLabel = newLabel();

              char* temp = malloc(strlen($3.code) + strlen($3.temp) + strlen($5) + 100);
              sprintf(temp, "%s:\n"
                            "%s"
                            "if %s goto %s\n"
                            "goto %s\n"
                            "%s:\n"
                            "%s"
                            "goto %s\n"
                            "%s:\n",
                            startLabel, $3.code, $3.temp, bodyLabel,
                            endLabel, bodyLabel, $5, startLabel, endLabel);
              free($3.code);
              free($3.temp);
              free($5);
              free(startLabel);
              free(bodyLabel);
              free(endLabel);
              $$ = temp;
          }
          ;

StatementBlock : '{' Statements '}' { $$ = $2; }

E : E OR T {
        char* temp = newTemp();
        char* code = malloc(strlen($1.code) + strlen($3.code) + strlen($1.temp) + strlen($3.temp) + 50);
        sprintf(code, "%s%s%s = %s || %s\n", $1.code, $3.code, temp, $1.temp, $3.temp);
        $$.temp = temp;
        $$.code = code;
        free($1.code);
        free($1.temp);
        free($3.code);
        free($3.temp);
    }
  | T {
        $$.temp = $1.temp;
        $$.code = $1.code;
    }
  ;

T : T AND F {
        char* temp = newTemp();
        char* code = malloc(strlen($1.code) + strlen($3.code) + strlen($1.temp) + strlen($3.temp) + 50);
        sprintf(code, "%s%s%s = %s && %s\n", $1.code, $3.code, temp, $1.temp, $3.temp);
        $$.temp = temp;
        $$.code = code;
        free($1.code);
        free($1.temp);
        free($3.code);
        free($3.temp);
    }
  | F {
        $$.temp = $1.temp;
        $$.code = $1.code;
    }
  ;

F : F EQ G {
        char* temp = newTemp();
        char* code = malloc(strlen($1.code) + strlen($3.code) + strlen($1.temp) + strlen($3.temp) + 50);
        sprintf(code, "%s%s%s = %s == %s\n", $1.code, $3.code, temp, $1.temp, $3.temp);
        $$.temp = temp;
        $$.code = code;
        free($1.code);
        free($1.temp);
        free($3.code);
        free($3.temp);
    }
  | F NEQ G {
        char* temp = newTemp();
        char* code = malloc(strlen($1.code) + strlen($3.code) + strlen($1.temp) + strlen($3.temp) + 50);
        sprintf(code, "%s%s%s = %s != %s\n", $1.code, $3.code, temp, $1.temp, $3.temp);
        $$.temp = temp;
        $$.code = code;
        free($1.code);
        free($1.temp);
        free($3.code);
        free($3.temp);
    }
  | F '<' G {
        char* temp = newTemp();
        char* code = malloc(strlen($1.code) + strlen($3.code) + strlen($1.temp) + strlen($3.temp) + 50);
        sprintf(code, "%s%s%s = %s < %s\n", $1.code, $3.code, temp, $1.temp, $3.temp);
        $$.temp = temp;
        $$.code = code;
        free($1.code);
        free($1.temp);
        free($3.code);
        free($3.temp);
    }
  | F '>' G {
        char* temp = newTemp();
        char* code = malloc(strlen($1.code) + strlen($3.code) + strlen($1.temp) + strlen($3.temp) + 50);
        sprintf(code, "%s%s%s = %s > %s\n", $1.code, $3.code, temp, $1.temp, $3.temp);
        $$.temp = temp;
        $$.code = code;
        free($1.code);
        free($1.temp);
        free($3.code);
        free($3.temp);
    }
  | F LE G {
        char* temp = newTemp();
        char* code = malloc(strlen($1.code) + strlen($3.code) + strlen($1.temp) + strlen($3.temp) + 50);
        sprintf(code, "%s%s%s = %s <= %s\n", $1.code, $3.code, temp, $1.temp, $3.temp);
        $$.temp = temp;
        $$.code = code;
        free($1.code);
        free($1.temp);
        free($3.code);
        free($3.temp);
    }
  | F GE G {
        char* temp = newTemp();
        char* code = malloc(strlen($1.code) + strlen($3.code) + strlen($1.temp) + strlen($3.temp) + 50);
        sprintf(code, "%s%s%s = %s >= %s\n", $1.code, $3.code, temp, $1.temp, $3.temp);
        $$.temp = temp;
        $$.code = code;
        free($1.code);
        free($1.temp);
        free($3.code);
        free($3.temp);
    }
  | G {
        $$.temp = $1.temp;
        $$.code = $1.code;
    }
  ;

G : NOT G {
        char* temp = newTemp();
        char* code = malloc(strlen($2.code) + strlen($2.temp) + 30);
        sprintf(code, "%s%s = !%s\n", $2.code, temp, $2.temp);
        $$.temp = temp;
        $$.code = code;
        free($2.code);
        free($2.temp);
    }
  | H {
        $$.temp = $1.temp;
        $$.code = $1.code;
    }
  ;

H : H '+' I {
        char* temp = newTemp();
        char* code = malloc(strlen($1.code) + strlen($3.code) + strlen($1.temp) + strlen($3.temp) + 50);
        sprintf(code, "%s%s%s = %s + %s\n", $1.code, $3.code, temp, $1.temp, $3.temp);
        $$.temp = temp;
        $$.code = code;
        free($1.code);
        free($1.temp);
        free($3.code);
        free($3.temp);
    }
  | H '-' I {
        char* temp = newTemp();
        char* code = malloc(strlen($1.code) + strlen($3.code) + strlen($1.temp) + strlen($3.temp) + 50);
        sprintf(code, "%s%s%s = %s - %s\n", $1.code, $3.code, temp, $1.temp, $3.temp);
        $$.temp = temp;
        $$.code = code;
        free($1.code);
        free($1.temp);
        free($3.code);
        free($3.temp);
    }
  | I {
        $$.temp = $1.temp;
        $$.code = $1.code;
    }
  ;

I : I '*' J {
        char* temp = newTemp();
        char* code = malloc(strlen($1.code) + strlen($3.code) + strlen($1.temp) + strlen($3.temp) + 50);
        sprintf(code, "%s%s%s = %s * %s\n", $1.code, $3.code, temp, $1.temp, $3.temp);
        $$.temp = temp;
        $$.code = code;
        free($1.code);
        free($1.temp);
        free($3.code);
        free($3.temp);
    }
  | I '/' J {
        char* temp = newTemp();
        char* code = malloc(strlen($1.code) + strlen($3.code) + strlen($1.temp) + strlen($3.temp) + 50);
        sprintf(code, "%s%s%s = %s / %s\n", $1.code, $3.code, temp, $1.temp, $3.temp);
        $$.temp = temp;
        $$.code = code;
        free($1.code);
        free($1.temp);
        free($3.code);
        free($3.temp);
    }
  | J {
        $$.temp = $1.temp;
        $$.code = $1.code;
    }
  ;

J : ID {
        $$.temp = $1;
        $$.code = strdup("");
    }
  | NUMBER {
        char* temp = newTemp();
        char* code = malloc(strlen($1) + 30);
        sprintf(code, "%s = %s\n", temp, $1);
        $$.temp = temp;
        $$.code = code;
        free($1);
    }
  | '(' E ')' {
        $$.temp = $2.temp;
        $$.code = $2.code;
    }
  ;

%%

void yyerror(char *s) {
    fprintf(stderr, "Error: %s\n", s);
}

int main() {
    yyin = fopen("input.txt", "r");
    yyout = fopen("output.txt", "w");
    yyparse();
    fclose(yyin);
    fclose(yyout);
    return 0;
}