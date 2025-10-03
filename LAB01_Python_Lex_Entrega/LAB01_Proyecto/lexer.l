%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>

/* -------- Symbol table for identifiers -------- */
typedef struct IdNode {
    char *name;
    int index;
    struct IdNode *next;
} IdNode;

#define IDTABLE_SIZE 1024

static IdNode* idtable[IDTABLE_SIZE];
static int idcount = 0;
static int lex_errors = 0;

unsigned long djb2(const char *str) {
    unsigned long hash = 5381;
    int c;
    while ((c = *str++)) {
        hash = ((hash << 5) + hash) + c;
    }
    return hash;
}

int get_identifier_index(const char* name) {
    unsigned long h = djb2(name) % IDTABLE_SIZE;
    IdNode* cur = idtable[h];
    while (cur) {
        if (strcmp(cur->name, name) == 0) return cur->index;
        cur = cur->next;
    }
    // insert new
    IdNode* node = (IdNode*)malloc(sizeof(IdNode));
    node->name = strdup(name);
    node->index = ++idcount;
    node->next = idtable[h];
    idtable[h] = node;
    return node->index;
}

void print_identifiers_summary() {
    // Collect all identifiers by scanning hash buckets and dumping into array for stable ordering by index
    IdNode **arr = (IdNode**)malloc(sizeof(IdNode*) * idcount);
    if (!arr) return;
    memset(arr, 0, sizeof(IdNode*) * idcount);
    for (int i = 0; i < IDTABLE_SIZE; ++i) {
        IdNode* cur = idtable[i];
        while (cur) {
            if (cur->index >= 1 && cur->index <= idcount) {
                arr[cur->index-1] = cur;
            }
            cur = cur->next;
        }
    }
    printf("\n\n%d Identificadores\n\n", idcount);
    for (int i = 0; i < idcount; ++i) {
        if (arr[i]) printf("Id%d=%s\n", arr[i]->index, arr[i]->name);
    }
    free(arr);
    printf("\n%d Errores\n", lex_errors);
}

/* Helper to emit identifier with stable numbering */
void emit_identifier(const char* name) {
    int idx = get_identifier_index(name);
    printf("id%d=%s ", idx, name);
}
%}

/* ------- Flex options ------- */
%option noyywrap nodefault
%option yylineno
%option case-insensitive

/* ------- Definitions ------- */
/* whitespace */
WS          [ \t\r]+

/* string literals: do not span newlines, basic single or double quotes */
SINGLE_STR  \'([^\'\n]|\\.)*\'
DOUBLE_STR  \"([^\"\n]|\\.)*\"

/* numbers */
DIGIT       [0-9]
SIGN        [\+\-]
INT         {SIGN}?{DIGIT}+
LONGINT     {INT}[lL]
EXP         [eE]{SIGN}?{DIGIT}+
DEC1        {DIGIT}+\.{DIGIT}*({EXP})?
DEC2        \.{DIGIT}+({EXP})?
DEC3        {DIGIT}+{EXP}
DECIMAL     ({DEC1}|{DEC2}|{DEC3})
IMAG        (({INT})|({DECIMAL}))[jJ]

/* identifiers */
ID_START    [A-Za-z_]
ID_CONT     [A-Za-z0-9_]
IDENT       {ID_START}{ID_CONT}*

/* compound ops (longest first) */
OP_POWEQ    \*\*=
OP_SHREQ    >>=
OP_SHLEQ    <<=
OP_FDIVEQ   //[ ]?=
OP_ADDEQ    \+=
OP_SUBEQ    \-=
OP_MULEQ    \*=
OP_DIVEQ    /=
OP_ANDEQ    &=
OP_OREQ     \|=
OP_XOREQ    \^=
OP_MODEQ    %=

/* double-char ops */
OP_POW      \*\*
OP_FDIV     //[ ]
OP_SHR      >>
OP_SHL      <<
OP_LE       <=
OP_GE       >=
OP_EQ       ==
OP_NE1      !=
OP_NE2      <>

/* single-char ops / delimiters */
LPAREN      \(
RPAREN      \)
LBRACK      \[
RBRACK      \]
ASSIGN      =
SEMI        ;
COMMA       ,
COLON       :
DOT         \.
PLUS        \+
MINUS       \-
STAR        \*
SLASH       /
PERCENT     %
LT          <
GT          >
AMP         &
PIPE        \|
CARET       \^
TILDE       ~

/* keywords (lowercase in spec; case-insensitive option is on) */
%%

{WS}                {/* ignore spaces/tabs */}

"#".*               {/* comment to end of line, ignore but keep newline separation */}

{SINGLE_STR}        { printf("cadena=%s ", yytext); }
{DOUBLE_STR}        { printf("cadena=%s ", yytext); }

{IMAG}              { printf("imaginario=%s ", yytext); }
{LONGINT}           { printf("long=%s ", yytext); }
{DECIMAL}           { printf("real=%s ", yytext); }
{INT}               { printf("entero=%s ", yytext); }

/* Keywords (emit uppercased) */
"and"               { printf("AND "); }
"else"              { printf("ELSE "); }
"is"                { printf("IS "); }
"return"            { printf("RETURN "); }
"break"             { printf("BREAK "); }
"for"               { printf("FOR "); }
"not"               { printf("NOT "); }
"while"             { printf("WHILE "); }
"continue"          { printf("CONTINUE "); }
"if"                { printf("IF "); }
"or"                { printf("OR "); }
"def"               { printf("DEF "); }
"import"            { printf("IMPORT "); }
"pass"              { printf("PASS "); }
"elif"              { printf("ELIF "); }
"in"                { printf("IN "); }
"print"             { printf("PRINT "); }

/* Identifiers */
{IDENT}             { emit_identifier(yytext); }

/* Assignments and delimiters with labels similar to example */
{LPAREN}            { printf("parabre=( "); }
{RPAREN}            { printf("parcierr=) "); }
{LBRACK}            { printf("corabre=[ "); }
{RBRACK}            { printf("corcierr=] "); }
{ASSIGN}            { printf("asign== "); }
{SEMI}              { printf("pcomas=; "); }
{COMMA}             { printf("coma=, "); }
{COLON}             { printf("dospunt=: "); }
{DOT}               { printf("punto=. "); }

/* Compound assignment ops */
{OP_POWEQ}          { printf("**= "); }
{OP_SHREQ}          { printf(">>= "); }
{OP_SHLEQ}          { printf("<<= "); }
{OP_FDIVEQ}         { printf("//= "); }
{OP_ADDEQ}          { printf("+= "); }
{OP_SUBEQ}          { printf("-= "); }
{OP_MULEQ}          { printf("*= "); }
{OP_DIVEQ}          { printf("/= "); }
{OP_ANDEQ}          { printf("&= "); }
{OP_OREQ}           { printf("|= "); }
{OP_XOREQ}          { printf("^= "); }
{OP_MODEQ}          { printf("%%= "); }

/* Operators (binary/uni) */
{OP_POW}            { printf("** "); }
{OP_FDIV}           { printf("// "); }
{OP_SHR}            { printf(">> "); }
{OP_SHL}            { printf("<< "); }
{OP_LE}             { printf("<= "); }
{OP_GE}             { printf(">= "); }
{OP_EQ}             { printf("== "); }
{OP_NE1}            { printf("!= "); }
{OP_NE2}            { printf("<> "); }
{PLUS}              { printf("suma=+ "); }
{MINUS}             { printf("menos=- "); }
{STAR}              { printf("mult=* "); }
{SLASH}             { printf("/ "); }
{PERCENT}           { printf("%% "); }
{LT}                { printf("< "); }
{GT}                { printf("> "); }
{AMP}               { printf("& "); }
{PIPE}              { printf("| "); }
{CARET}             { printf("^ "); }
{TILDE}             { printf("~ "); }

\n                  { printf("\n"); }

.                   { printf("ERROR=%s ", yytext); lex_errors++; }

%%

int main(int argc, char **argv) {
    if (argc < 2) {
        fprintf(stderr, "Uso: %s <archivo_entrada.py>\n", argv[0]);
        return 1;
    }
    FILE *in = fopen(argv[1], "r");
    if (!in) {
        perror("No se pudo abrir el archivo de entrada");
        return 1;
    }
    yyin = in;
    yylex();
    fclose(in);
    print_identifiers_summary();
    return 0;
}
