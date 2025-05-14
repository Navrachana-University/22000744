%{
#include "yacc.tab.h"
#include <string.h>
%}

%%

shuru              return SHURU;
bolo               return BOLO;
agar               return AGAR;
"nahi to"          return NAHITO;
jabtak             return JABTAK;  /* New token for while loop */

"&&"               return AND;
"||"               return OR;
"!"                return NOT;

"=="               return EQ;
"!="               return NEQ;
"<="               return LE;
">="               return GE;
"<"                return '<';
">"                return '>';

[0-9]+             { yylval.str = strdup(yytext); return NUMBER; }
[a-zA-Z_][a-zA-Z0-9_]*   { yylval.str = strdup(yytext); return ID; }

"="                return '=';
";"                return ';';
"("                return '(';
")"                return ')';
"{"                return '{';
"}"                return '}';
"+"                return '+';
"-"                return '-';
"*"                return '*';
"/"                return '/';

[ \t\r\n]+         ;  // Ignore whitespace

.                  { printf("Unknown character: %s\n", yytext); }

%%

int yywrap() {
    return 1;
}