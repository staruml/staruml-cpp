%token ABSTRACT ASSERT
%token BOOLEAN BREAK BYTE
%token CASE CATCH CHAR CLASS CONST CONTINUE
%token DEFAULT DO DOUBLE
%token ELSE ENUM EXTENDS EXPLICIT
%token FINAL FINALLY FLOAT FOR
%token IF
%token GOTO
%token IMPLEMENTS IMPORT INSTANCEOF INT INTERFACE
%token LONG
%token NATIVE NEW
%token PACKAGE PRIVATE PROTECTED PUBLIC
%token RETURN
%token SHORT STATIC STRICTFP SUPER SWITCH SYNCHRONIZED STRUCT
%token THIS THROW THROWS TRANSIENT TRY TYPEID VOID VOLATILE WHILE 
%token NOEXCEPT UNION
/* literal */
%token IntegerLiteral FloatingLiteral BooleanLiteral CharacterLiteral StringLiteral NullLiteral PointerLiteral
%token LPAREN RPAREN LBRACE RBRACE LBRACK RBRACK SEMI COMMA DOT
%token ASSIGN RT LSHIFT LT BANG TILDE QUESTION COLON DBL_COLON EQUAL LE GE NOTEQUAL AND OR INC DEC ADD SUB MUL DIV BITAND BITOR CARET MOD
%token DOT_STAR ARROW_STAR
%token ADD_ASSIGN SUB_ASSIGN MUL_ASSIGN DIV_ASSIGN AND_ASSIGN OR_ASSIGN XOR_ASSIGN MOD_ASSIGN LSHIFT_ASSIGN RSHIFT_ASSIGN URSHIFT_ASSIGN
%token identifier
%token ELLIPSIS
%token EOF
%token DYNAMIC_CAST STATIC_CAST REINTERPRET_CAST CONST_CAST MUTABLE TEMPLATE
%token SIZEOF ALIGNOF USING STATIC_ASSERT AUTO REGISTER THREAD_LOCAL EXTERN INLINE VIRTUAL CHAR CHAR16_T CHAR32_T WCHAR_T SIGNED UNSIGNED DECLTYPE TYPENAME NAMESPACE BACKSLASH 
%token HASH DBL_HASH LT_COLON RT_COLON LT_MOD RT_MOD MOD_COLON DBL_MOD_COLON ALT_OPERATOR

%start translation-unit

%%
translation-unit
    : EOF
    | declaration-seq EOF
    ;

/*
 * this is for opt things
 */ 
 DBL_COLON-opt
    : %empty
    | DBL_COLON
    ;
TEMPLATE-opt
    : %empty
    | TEMPLATE
    ;
ELLIPSIS-opt
    : %empty
    | ELLIPSIS
    ;
MUTABLE-opt
    : %empty
    | MUTABLE
    ;
COMMA-opt
    : %empty
    | COMMA
    ;
INLINE-opt
    : %empty
    | INLINE
    ;
TYPENAME-opt
    : %empty
    | TYPENAME
    ;
/*
  this is for expression 
*/
/* expr.prim.general */

primary-expression
    : literal
 	| THIS
 	| LPAREN expression RPAREN
 	| id-expression
 	| lambda-expression
    ;
id-expression
    : unqualified-id
 	| qualified-id
    ;
unqualified-id
    : identifier
 	| operator-function-id
 	| conversion-function-id
 	| literal-operator-id
 	| TILDE class-name
 	| TILDE decltype-specifier
 	| template-id
    ;
qualified-id
    : DBL_COLON-opt nested-name-specifier TEMPLATE-opt unqualified-id
 	| DBL_COLON identifier
 	| DBL_COLON operator-function-id
 	| DBL_COLON literal-operator-id
 	| DBL_COLON template-id
    ;
nested-name-specifier
    : type-name DBL_COLON
 	| namespace-name DBL_COLON
 	| decltype-specifier DBL_COLON
 	| nested-name-specifier identifier DBL_COLON
 	| nested-name-specifier TEMPLATE-opt simple-template-id DBL_COLON
 	;
/* expr.prim.lambda*/
lambda-expression
    : lambda-introducer lambda-declarator-opt compound-statement
    ;
lambda-declarator-opt
    : %empty
    | lambda-declarator
    ;
lambda-introducer
    : LBRACK lambda-capture-opt RBRACK
    ;
lambda-capture-opt
    : %empty
    | lambda-capture {
        $$ = $1;
    }
    ;
lambda-capture
    : capture-default
 	| capture-list
 	| capture-default COMMA capture-list
    ;
capture-default
    : BITAND {
        $$ = $1;
    }
 	| ASSIGN {
        $$ = $1;
    }
    ;
capture-list
    : capture ELLIPSIS-opt
    | capture-list COMMA capture ELLIPSIS-opt{
        $$ += $1 + " " + $3 ;
    }
    ;
capture
    : identifier {
        $$ = $1;
    }
 	| BITAND identifier {
        $$ = $2;
    }
 	| THIS  {
        $$ = $1;
    }
    ;
lambda-declarator
    : LPAREN parameter-declaration-clause RPAREN MUTABLE-opt exception-specification-opt attribute-specifier-seq-opt trailing-return-type-opt
    | LPAREN RPAREN MUTABLE-opt exception-specification-opt attribute-specifier-seq-opt trailing-return-type-opt
    ;
exception-specification-opt
    : %empty
    | exception-specification
    ;
attribute-specifier-seq-opt
    : %empty
    | attribute-specifier-seq
    ;
trailing-return-type-opt
    : %empty
    | trailing-return-type
    ;	
/* expr.post */
postfix-expression
    : primary-expression
 	| postfix-expression LBRACK expression RBRACK
 	| postfix-expression LBRACK braced-init-list-opt RBRACK
 	| postfix-expression LPAREN expression-list-opt RPAREN
 	| simple-type-specifier LPAREN expression-list-opt RPAREN
 	| simple-type-specifier braced-init-list
 	| typename-specifier LPAREN expression-list-opt RPAREN
 	| typename-specifier braced-init-list
 	| postfix-expression DOT TEMPLATE-opt id-expression
 	| postfix-expression INDIR_MBR_ACCESS TEMPLATE-opt id-expression
 	| postfix-expression DOT pseudo-destructor-name
 	| postfix-expression INDIR_MBR_ACCESS pseudo-destructor-name
 	| postfix-expression INC
 	| postfix-expression DEC
 	| DYNAMIC_CAST LT type-id RT LPAREN expression RPAREN
 	| STATIC_CAST LT type-id RT LPAREN expression RPAREN
 	| REINTERPRET_CAST LT type-id RT LPAREN expression RPAREN
 	| CONST_CAST LT type-id RT LPAREN expression RPAREN
 	| TYPEID LPAREN expression RPAREN
 	| TYPEID LPAREN type-id RPAREN
    ;
braced-init-list-opt
    : %empty
    | braced-init-list
    ;
expression-list-opt
    : %emtpy
    | expression-list
    ;

expression-list
    : initializer-list
    ;
pseudo-destructor-name
    : DBL_COLON-opt nested-name-specifier-opt type-name DBL_COLON TILDE type-name
 	| DBL_COLON-opt nested-name-specifier TEMPLATE simple-template-id DBL_COLON TILDE type-name
 	| DBL_COLON-opt nested-name-specifier-opt TILDE type-name
 	| TILDE decltype-specifier
    ;
nested-name-specifier-opt
    : %empty
    | nested-name-specifier
    ;
/* expr.unary */
unary-expression
    : postfix-expression
    | INC cast-expression
 	| DEC cast-expression
 	| unary-operator cast-expression
 	| SIZEOF unary-expression
 	| SIZEOF LPAREN type-id RPAREN
 	| SIZEOF ELLIPSIS LPAREN identifier RPAREN
 	| ALIGNOF LPAREN type-id RPAREN
 	| noexcept-expression
 	| new-expression
 	| delete-expression
    ;
unary-operator
    : MUL
    | BITAND
 	| ADD
 	| SUB
 	| BANG
 	| TILDE
 	;
/* expr.new */
new-expression
    : DBL_COLON-opt NEW new-placement-opt new-type-id new-initializer-opt
 	| DBL_COLON-opt NEW new-placement-opt LPAREN type-id RPAREN new-initializer-opt
    ;
new-placement-opt
    : %empty
    | new-placement
    ;
new-initializer-opt
    : %empty
    | new-initializer
    ;
new-placement
    : LPAREN expression-list RPAREN
    ;
new-type-id
    : type-specifier-seq new-declarator-opt
    ;
new-declarator-opt
    : %empty
    | new-declarator
    ;
new-declarator
    : ptr-operator new-declarator-opt
 	| noptr-new-declarator
    ;
noptr-new-declarator
    : LBRACK expression RBRACK attribute-specifier-seq-opt
 	| noptr-new-declarator LBRACK constant-expression RBRACK attribute-specifier-seq-opt
    ;
new-initializer
    : LPAREN expression-list-opt RPAREN
 	| braced-init-list
    ;
/* expr.delete */
delete-expression
    : DBL_COLON-opt DELETE cast-expression
 	| DBL_COLON-opt DELETE LBRACK RBRACK cast-expression
    ;
/* expr.unary.noexcept */
noexcept-expression
    : noexcept LPAREN expression RPAREN
 	;
/* expr.cast */
cast-expression
    : unary-expression
 	| LPAREN type-id RPAREN cast-expression
    ;
/* expr.mptr.oper */
pm-expression
    :cast-expression
    | pm-expression DOT_STAR cast-expression
 	| pm-expression ARROW_STAR cast-expression
    ;
/* expr.mul */
multiplicative-expression
    : pm-expression
 	| multiplicative-expression MUL pm-expression
 	| multiplicative-expression DIV pm-expression
 	| multiplicative-expression MOD pm-expression
    ;
/* expr.add */
additive-expression
    : multiplicative-expression
 	| additive-expression ADD multiplicative-expression
 	| additive-expression SUB multiplicative-expression
    ;
/* expr.shift */
shift-expression
    : additive-expression
 	| shift-expression LSHIFT additive-expression
 	| shift-expression RSHIFT additive-expression
    ;
/* expr.rel */
relational-expression
    : shift-expression
    | relational-expression LT shift-expression
 	| relational-expression RT shift-expression
 	| relational-expression LE shift-expression
 	| relational-expression RE shift-expression
 	;
/* expr.eq */
equality-expression
    : relational-expression
 	| equality-expression EQUAL relational-expression
 	| equality-expression NOTEQUAL relational-expression
 	;
/* expr.bit.and */
and-expression
    :equality-expression
    | and-expression BITAND equality-expression
 	;
/* expr.xor */
exclusive-or-expression
    : and-expression
    | exclusive-or-expression CARET and-expression
 	;
/* expr.or */
inclusive-or-expression
    : exclusive-or-expression
    | inclusive-or-expression BITOR exclusive-or-expression
 	;
/* expr.log.and */
logical-and-expression
    : inclusive-or-expression
    | logical-and-expression AND inclusive-or-expression
 	;
/* expr.log.or*/
logical-or-expression
    : logical-and-expression
    | logical-or-expression OR logical-and-expression
    ;
/* expr.cond */
conditional-expression
    : logical-or-expression
    | logical-or-expression QUESTION expression COLON assignment-expression
    ;
/* expr.ass */
assignment-expression
    : conditional-expression
    | logical-or-expression assignment-operator initializer-clause
 	| throw-expression
    ;
assignment-operator 
    : ASSIGN
 	| MUL_ASSIGN
 	| DIV_ASSIGN
 	| MOD_ASSIGN
 	| ADD_ASSIGN
 	| SUB_ASSIGN
 	| RSHIFT_ASSIGN
 	| LSHIFT_ASSIGN
 	| AND_ASSIGN
 	| XOR_ASSIGN
 	| OR_ASSIGN
    ;
/* expr.comma */
expression
    : assignment-expression
 	| expression COMMA assignment-expression
    ;
/* expr.const */
constant-expression
    : conditional-expression
    ;






/* this is for declaration */
/* dcl.dcl */
declaration-seq
    : declaration
    | declaration-seq declaration
    ;
declaration
    : block-declaration {
        console.log("block");
    }
    | function-definition {
        console.log("============outside fuction================\n");
    }
 	| template-declaration {
        console.log("template");
    }
 	| explicit-instantiation {
        console.log("explicit-in");
    }
 	| explicit-specialization {
        console.log("explicit-sp");
    }
 	| linkage-specification {
        console.log("linkage");
    }
 	| namespace-definition {
        console.log("namespace");
    }
 	| empty-declaration {
        console.log("empty");
    }
 	| attribute-declaration {
        console.log("attribute");
    }
    ;
block-declaration
    : simple-declaration {
        console.log("simple-declaration " + $1);
    }
 	| asm-definition
 	| namespace-alias-definition
 	| using-declaration
 	| using-directive
 	| static_assert-declaration
 	| alias-declaration
 	| opaque-enum-declaration
    ;
alias-declaration
    : USING identifier ASSIGN type-id SEMI
    ;
simple-declaration
    : attribute-specifier-seq-opt decl-specifier-seq-opt init-declarator-list-opt SEMI
    ;
    
decl-specifier-seq-opt
    : %empty
    | decl-specifier-seq
    ;
init-declarator-list-opt
    : %empty
    | init-declarator-list
    ;
static_assert-declaration
    : STATIC_ASSERT LPAREN constant-expression COMMA StringLiteral RPAREN SEMI
    ;
empty-declaration
    : SEMI
    ;
attribute-declaration
    : attribute-specifier-seq SEMI
    ;
/* dcl.spec */
decl-specifier
    : storage-class-specifier
 	| type-specifier
 	| function-specifier
 	| FRIEND
 	| TYPEDEF
 	| CONSTEXPR
    ;
decl-specifier-seq
    : decl-specifier attribute-specifier-seq-opt
 	| decl-specifier decl-specifier-seq
    ;
    
/* dcl.stc */
storage-class-specifier
    : AUTO
 	| REGISTER
 	| STATIC
 	| THREAD_LOCAL
 	| EXTERN
 	| MUTABLE
    ;
/* dcl.fct.spec */
function-specifier
    : INLINE
 	| VIRTUAL
 	| EXPLICIT
    ;
/* dcl.typedef */
typedef-name
    : identifier
    ;
/* dcl.type */
type-specifier
    : trailing-type-specifier
    | class-specifier
 	| enum-specifier
    ;
trailing-type-specifier
    : simple-type-specifier
 	| elaborated-type-specifier
 	| typename-specifier
 	| cv-qualifier
    ;
type-specifier-seq
    : type-specifier attribute-specifier-seq-opt
 	| type-specifier type-specifier-seq
    ;
trailing-type-specifier-seq
    : trailing-type-specifier attribute-specifier-seq-opt
 	| trailing-type-specifier trailing-type-specifier-seq
    ;
/* dct.type.simple */
simple-type-specifier
    : DBL_COLON-opt nested-name-specifier-opt type-name
 	| DBL_COLON-opt nested-name-specifier template simple-template-id
 	| CHAR
 	| CHAR16_T
 	| CHAR32_T
 	| WCHAR_T
 	| BOOL
 	| SHORT
 	| INT
 	| LONG
 	| SIGNED
 	| UNSIGNED
 	| FLOAT
 	| DOUBLE
    | VOID
 	| AUTO
 	| decltype-specifier
    ;
type-name
    : class-name
 	| enum-name
 	| typedef-name
 	| simple-template-id
    ;
decltype-specifier
    : decltype LPAREN expression RPAREN
    ;
/* dcl.type.elab */
elaborated-type-specifier
    : class-key attribute-specifier-seq-opt DBL_COLON-opt nested-name-specifier-opt identifier
 	| class-key DBL_COLON-opt nested-name-specifier-opt TEMPLATE-opt simple-template-id
 	| ENUM DBL_COLON-opt nested-name-specifier-opt identifier
    ;
/* dcl.enum */
enum-name
    : identifier
    ;
enum-specifier
    : enum-head LBRACE RBRACE
    | enum-head LBRACE enumerator-list RBRACE
 	| enum-head LBRACE enumerator-list COMMA RBRACE
    ;
enum-head
    : enum-key attribute-specifier-seq-opt identifier-opt enum-base-opt
 	| enum-key attribute-specifier-seq-opt nested-name-specifier identifier enum-base-opt
    ;
identifier-opt
    : %empty
    | identifier
    ;
enum-base-opt
    : %empty
    | enum-base
    ;
opaque-enum-declaration
    : enum-key attribute-specifier-seq-opt identifier enum-base-opt SEMI
    ;
enum-key
    : ENUM
 	| ENUM CLASS
 	| ENUM STRUCT
    ;
enum-base
    : COLON type-specifier-seq
    ;
enumerator-list
    : enumerator-definition
 	| enumerator-list COMMA enumerator-definition
    ;
enumerator-definition
    : identifier
    | identifier ASSIGN constant-expression
    ;
/* namespace.def */
namespace-name
    : original-namespace-name
    | namespace-alias
    ;
original-namespace-name
    : identifier
    ;
namespace-definition
    : named-namespace-definition
 	| unnamed-namespace-definition
    ;
named-namespace-definition
    : original-namespace-definition
 	| extension-namespace-definition
    ;
original-namespace-definition
    : inline-opt namespace identifier LBRACE namespace-body RBRACE
    ;
extension-namespace-definition
    : inline-opt namespace original-namespace-name LBRACE namespace-body RBRACE
    ;
unnamed-namespace-definition
    : inline-opt namespace LBRACE namespace-body RBRACE
    ;
namespace-body
    : declaration-seq-opt
    ;
declaration-seq-opt
    : %empty
    | declaration-seq
    ;
/* namespace.alias */
namespace-alias
    : identifier
    ;
namespace-alias-definition
    : namespace identifier ASSIGN qualified-namespace-specifier SEMI
    ;
qualified-namespace-specifier
    : DBL_COLON-opt nested-name-specifier-opt namespace-name
    ;
/* namespace.udecl */
using-declaration
    : USING TYPENAME-opt DBL_COLON-opt nested-name-specifier unqualified-id SEMI
 	| USING DBL_COLON unqualified-id SEMI
    ;
/* namespace.udir */
using-directive
    : attribute-specifier-seq USING NAMESPACE nested-name-specifier-opt namespace-name SEMI
    | attribute-specifier-seq USING NAMESPACE DBL_COLON nested-name-specifier-opt namespace-name SEMI
    | USING NAMESPACE DBL_COLON-opt nested-name-specifier-opt namespace-name SEMI
    ;
/* dcl.asm */
asm-definition
    : ASM LPAREN StringLiteral RPAREN SEMI
    ;
/* dcl.link */
linkage-specification
    : EXTERN StringLiteral LBRACE declaration-seq-opt RBRACE
 	| EXTERN StringLiteral declaration
    ;
/* dcl.attr.grammar */
attribute-specifier-seq
    : attribute-specifier
 	| attribute-specifier-seq attribute-specifier
    ;
attribute-specifier
    : LBRACK LBRACK attribute-list RBRACK RBRACK
 	| alignment-specifier
    ;
alignment-specifier
    : ALIGNAS LPAREN type-id ELLIPSIS-opt RPAREN
 	| ALIGNAS LPAREN alignment-expression ELLIPSIS-opt RPAREN
    ;
attribute-list
    : attribute-opt
 	| attribute-list COMMA attribute-opt
 	| attribute ELLIPSIS
 	| attribute-list COMMA attribute ELLIPSIS
    ;
attribute
    : attribute-token attribute-argument-clause-opt
    ;
attribute-argument-clause-opt
    : %empty
    | attribute-argument-clause
    ;
attribute-token
    : identifier
 	| attribute-scoped-token
    ;
attribute-scoped-token
    : attribute-namespace DBL_COLON identifier
    ;
attribute-namespace
    : identifier
    ;
attribute-argument-clause
    : LPAREN balanced-token-seq RPAREN
    ;
balanced-token-seq
    : balanced-token
 	| balanced-token-seq balanced-token
    ;
balanced-token
    : LPAREN balanced-token-seq RPAREN
 	| LBRACK balanced-token-seq RBRACK
 	| LBRACE balanced-token-seq RBRACE
 	| lex-token
    ;	
/* dcl.decl */
init-declarator-list
    : init-declarator
    | init-declarator-list COMMA init-declarator
    ;
init-declarator
    : declarator
    | declarator initializer
    ;
declarator
    : ptr-declarator
 	| noptr-declarator parameters-and-qualifiers trailing-return-type
    ;
ptr-declarator
    : noptr-declarator
 	| ptr-operator ptr-declarator
    ;
    
noptr-declarator
    : declarator-id
    | declarator-id attribute-specifier-seq
 	| noptr-declarator parameters-and-qualifiers
    | noptr-declarator brack-part-seq attribute-specifier-seq
    | noptr-declarator brack-part-seq
    | declarator-id brack-part-seq attribute-specifier-seq
    | declarator-id brack-part-seq
 	| LPAREN ptr-declarator RPAREN
    ;
brack-part-seq
    : brack-part
    | brack-part-seq brack-part
    ;
brack-part
    : LBRACK RBRACK
    | LBRACK constant-expression RBRACK
    ;
parameters-and-qualifiers
    : LPAREN parameter-declaration-clause RPAREN attribute-specifier-seq-opt cv-qualifier-seq-opt ref-qualifier-opt exception-specification-opt {
        $$ = $1 + " " + $2 + " " + $3;
        console.log("\n============inside fuction================");
    }
    | LPAREN RPAREN attribute-specifier-seq-opt cv-qualifier-seq-opt ref-qualifier-opt exception-specification-opt {
        $$ = $1 + " " + $2;
        console.log("\n============inside fuction================");
    }
    ;
cv-qualifier-seq-opt
    : %empty
    | cv-qualifier-seq
    ;
ref-qualifier-opt
    : %empty
    | ref-qualifier
    ;
trailing-return-type
    : INDIR_MBR_ACCESS trailing-type-specifier-seq abstract-declarator-opt
    ;
abstract-declarator-opt
    : %empty
    | abstract-declarator
    ;
ptr-operator
    : MUL attribute-specifier-seq-opt cv-qualifier-seq-opt
 	| BITAND attribute-specifier-seq-opt
 	| AND attribute-specifier-seq-opt
 	| DBL_COLON-opt nested-name-specifier MUL attribute-specifier-seq-opt cv-qualifier-seq-opt
    ;
cv-qualifier-seq
    : cv-qualifier
    | cv-qualifier cv-qualifier-seq
    ;
cv-qualifier
    : CONST
    | VOLATILE
    ;
ref-qualifier
    : BITAND
 	| AND
    ;
declarator-id
    : id-expression
    | ELLIPSIS id-expression
 	| DBL_COLON-opt nested-name-specifier-opt class-name
    ;
/* dcl.name */
type-id
    : type-specifier-seq abstract-declarator-opt
    ;
abstract-declarator
    : ptr-abstract-declarator
    | noptr-abstract-declarator-opt parameters-and-qualifiers trailing-return-type
 	| ELLIPSIS
    ;
noptr-abstract-declarator-opt
    : %empty
    | noptr-abstract-declarator
    ;
ptr-abstract-declarator
    : noptr-abstract-declarator
 	| ptr-operator ptr-abstract-declarator-opt
    ;
ptr-abstract-declarator-opt
    : %empty
    | ptr-abstract-declarator
    ;
noptr-abstract-declarator
    : noptr-abstract-declarator-opt parameters-and-qualifiers
 	| noptr-abstract-declarator-opt LBRACK constant-expression RBRACK attribute-specifier-seq-opt
 	| LPAREN ptr-abstract-declarator RPAREN
    ;
    
/* dcl.fct */
parameter-declaration-clause // <- action like -opt / a parameter-declaration-clause b | a b 두개 모두 명시 할것 
    : parameter-declaration-list
    | ELLIPSIS
    | parameter-declaration-list ELLIPSIS
 	| parameter-declaration-list COMMA ELLIPSIS
    ;
parameter-declaration-list
    : parameter-declaration
    | parameter-declaration-list COMMA parameter-declaration
    ;
parameter-declaration
    : attribute-specifier-seq-opt decl-specifier-seq declarator
 	| attribute-specifier-seq-opt decl-specifier-seq declarator ASSIGN initializer-clause
 	| attribute-specifier-seq-opt decl-specifier-seq abstract-declarator-opt
 	| attribute-specifier-seq-opt decl-specifier-seq abstract-declarator-opt ASSIGN initializer-clause
    ;
 	
/* dcl.fct.def.general */
//
// c++0x11 has ambiguity lots of.
// void push( ... ) { ... }
// if { ... } has some if-switch-etc-expr it consider as function, but lalr can't find alot
// so change bnf 
//
function-definition
    : attribute-specifier-seq-opt decl-specifier-seq declarator function-body 
 	| attribute-specifier-seq-opt decl-specifier-seq-opt declarator ASSIGN DEFAULT SEMI
 	| attribute-specifier-seq-opt decl-specifier-seq-opt declarator ASSIGN DELETE SEMI
    ;
function-body
    : compound-statement {
        console.log("function body");
    }
    | ctor-initializer compound-statement {
        console.log("function body");
    }
 	| function-try-block {
        console.log("function body");
    }
    ;
/* dcl.init */
initializer
    : brace-or-equal-initializer
 	| LPAREN expression-list RPAREN
    ;
brace-or-equal-initializer
    : ASSIGN initializer-clause 
 	| braced-init-list
    ;
initializer-clause
    : assignment-expression
 	| braced-init-list
    ;
initializer-list	 
 	: initializer-clause
    | initializer-clause ELLIPSIS
 	| initializer-list COMMA initializer-clause
    | initializer-list COMMA initializer-clause ELLIPSIS
    ;
braced-init-list
    : LBRACE initializer-list RBRACE
    | LBRACE initializer-list COMMA RBRACE
 	| LBRACE RBRACE
    ;









/*
 * this part is for statement 
 */
/* stmt.stmt */

statement
    : labeled-statement
 	| attribute-specifier-seq-opt expression-statement
 	| attribute-specifier-seq-opt compound-statement
 	| attribute-specifier-seq-opt selection-statement
 	| attribute-specifier-seq-opt iteration-statement
 	| attribute-specifier-seq-opt jump-statement
 	| declaration-statement
 	| attribute-specifier-seq-opt try-block
    ;
/* stmt.label */
labeled-statement
    : attribute-specifier-seq-opt identifier COLON statement
 	| attribute-specifier-seq-opt CASE constant-expression COLON statement
 	| attribute-specifier-seq-opt DEFAULT COLON statement
 	;
/* stmt.expr */
expression-statement
    : SEMI
    | expression SEMI
    ;
expression-opt
    : %empty
    | expression
    ;
compound-statement
    : LBRACE RBRACE
    | LBRACE statement-seq RBRACE
    ;
statement-seq
    : statement 
    | statement statement-seq
    ;
/* stmt.block 
compound-statement
    : LBRACE RBRACE
    | LBRACE statement-seq RBRACE
    ;
compound-statement
	: LBRACE RBRACE
	| LBRACE decl-stat-both-seq RBRACE
	;
decl-stat-both-seq
    : decl-stat-both
    | decl-stat-both decl-stat-both-seq
    ;
decl-stat-both
    : declaration
    | statement
    ;
*/
/* stmt.select */
selection-statement
    : IF LPAREN condition RPAREN statement
 	| IF LPAREN condition RPAREN statement ELSE statement
 	| SWITCH LPAREN condition RPAREN statement
    ;
condition
    : expression
 	| attribute-specifier-seq-opt decl-specifier-seq declarator ASSIGN initializer-clause
 	| attribute-specifier-seq-opt decl-specifier-seq declarator braced-init-list
    ;
/* stmt.iter */
iteration-statement
    : WHILE LPAREN condition RPAREN statement
 	| DO statement WHILE LPAREN expression RPAREN SEMI
 	| FOR LPAREN for-init-statement condition-opt SEMI expression-opt RPAREN statement
 	| FOR LPAREN for-range-declaration COLON for-range-initializer RPAREN statement
    ;
condition-opt
    : %empty
    | condition
    ;
for-init-statement
    : expression-statement
    | decl-specifier-seq init-declarator-list SEMI
    ;
for-range-declaration
    : attribute-specifier-seq-opt type-specifier-seq declarator
    ;
for-range-initializer
    : expression braced-init-list
    ;
/* stmt.jump */
jump-statement
    : BREAK SEMI
 	| CONTINUE SEMI
 	| RETURN SEMI
    | RETURN expression SEMI
    | RETURN braced-init-list SEMI
 	| GOTO identifier SEMI
    ;
/* stmt.dcl */
declaration-statement
    : block-declaration
    ;
    
    
    
    
    
    
/* part for unimplmented lex */
/* lex.token */
lex-token
    : identifier
    | keyword
    | literal
    | op-or-punc-0x
    ;
op-or-punc-0x // c++0x version
    : HASH
    | DBL_HASH
    | LT_COLON
    | RT_COLON
    | LT_MOD
    | RT_MOD
    | MOD_COLON
    | DBL_MOD_COLON
    | SEMI
    | COLON
    | ELLIPSIS
    | QUESTION
    | DBL_COLON
    | DOT
    | DOT_STAR
    | ADD
    | SUB
    | MUL
    | DIV
    | MOD
    | CARET
    | BITAND
    | BITOR
    | TILDE
    | BANG
    | ASSIGN
    | LT
    | RT
    | ADD_ASSIGN
    | SUB_ASSIGN
    | MUL_ASSIGN
    | DIV_ASSIGN
    | MOD_ASSIGN
    | XOR_ASSIGN
    | AND_ASSIGN
    | OR_ASSIGN
    | LSHIFT
    | RSHIFT
    | LSHIFT_ASSIGN
    | RSHIFT_ASSIGN
    | EQUAL
    | NOTEQUAL
    | LE
    | GE
    | AND
    | OR
    | INC
    | DEC
    | COMMA
    | ARROW_STAR
    | INDIR_MBR_ACCESS
    | NEW
    | DELETE
    | ALT_OPERATOR
    ;
/* lex.literal.kinds */
literal 
    : IntegerLiteral
    | FloatingLiteral
    | BooleanLiteral
    | CharacterLiteral
    | StringLiteral
    | NullLiteral
    | PointerLiteral
    ;
/* lex.ext */
user-defined-literal 
    : user-defined-integer-literal
    | user-defined-floating-literal
    | user-defined-StringLiteral
 	| user-defined-character-literal
    ;
user-defined-integer-literal 
    : IntegerLiteral ud-suffix
    ;
user-defined-floating-literal 
    : FloatingLiteral ud-suffix
    ;
user-defined-StringLiteral 
    : StringLiteral ud-suffix
    ;
user-defined-character-literal 
    : CharacterLiteral ud-suffix
    ;
ud-suffix 
    : identifier
    ;