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
%token QUOTATION DBL_QUOTATION HASH DBL_HASH LT_COLON RT_COLON LT_MOD RT_MOD MOD_COLON DBL_MOD_COLON ALT_OPERATOR
%start compilationUnit

%%
compilationUnit 
    : test-seq EOF
    ;

test-seq
    : declaration-seq {
        console.log("defcl");
    }
    | statement-seq{
        console.log("stat");
    }
    ;


test-func 
    : TYPEID declaration-seq
    ;

/*
 * this part is class
 */
class-name 
    : identifier
 	| simple-template-id
    ;
class-specifier 
    : class-head LBRACE RBRACE
    | class-head LBRACE member-specification RBRACE
    ;
class-head 
    : class-key class-head-name
    | class-key class-head-name base-clause
    | class-key class-head-name class-virt-specifier-seq
    | class-key class-head-name class-virt-specifier-seq base-clause
    | class-key attribute-specifier-seq class-head-name
    | class-key attribute-specifier-seq class-head-name base-clause
    | class-key attribute-specifier-seq class-head-name class-virt-specifier-seq
    | class-key attribute-specifier-seq class-head-name class-virt-specifier-seq base-clause
    | class-key
    | class-key base-clause
    | class-key attribute-specifier-seq
    | class-key attribute-specifier-seq base-clause
    ;
class-head-name 
    : class-name
    | nested-name-specifier class-name
    ;
class-virt-specifier-seq 
    : class-virt-specifier
    | class-virt-specifier-seq class-virt-specifier
    ;
class-virt-specifier 
    : FINAL
 	| EXPLICIT
    ;
class-key 
    : CLASS
    | STRUCT
    ;



/**
 * this part is dcl
 */ 
/* dcl.dcl */
declaration-seq
    : declaration
 	| declaration-seq declaration
    ;
declaration
    : block-declaration
    | function-definition
 	| template-declaration
 	| explicit-instantiation
 	| explicit-specialization
 	| linkage-specification
 	| namespace-definition{
        console.log("function-declaration");
    }
 	| empty-declaration
 	| attribute-declaration
    ;
block-declaration
    : simple-declaration
    | asm-definition
 	| namespace-alias-definition
 	| using-declaration{
        console.log("using-declaration");
    }
 	| using-directive{
        console.log("using-directive");
    }
 	| static_assert-declaration
 	| alias-declaration
 	| opaque-enum-declaration
    ;
alias-declaration
    : USING identifier ASSIGN type-id SEMI
    ;
simple-declaration
    : SEMI{
        console.log("simple-declaration - 1");
    }
    | init-declarator-list SEMI{
        console.log("simple-declaration - 2");
    }
    | decl-specifier-seq SEMI{
        console.log("simple-declaration - 3");
    }
    | decl-specifier-seq init-declarator-list SEMI{
        console.log("simple-declaration - 4");
    }
    | attribute-specifier-seq SEMI{
        console.log("simple-declaration - 5");
    }
    | attribute-specifier-seq init-declarator-list SEMI{
        console.log("simple-declaration - 6");
    }
    | attribute-specifier-seq decl-specifier-seq SEMI{
        console.log("simple-declaration - 7");
    }
    | attribute-specifier-seq decl-specifier-seq init-declarator-list SEMI{
        console.log("simple-declaration - 8");
    }
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
    : decl-specifier{
        console.log("decl-specifier-seq - 1");
    }
    | decl-specifier attribute-specifier-seq{
        console.log("decl-specifier-seq - 2");
    }
    | decl-specifier decl-specifier-seq{
        console.log("decl-specifier-seq - 3");
    }
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
    : type-specifier
    | type-specifier attribute-specifier-seq
 	| type-specifier type-specifier-seq
    ;
trailing-type-specifier-seq
    : trailing-type-specifier
    | trailing-type-specifier attribute-specifier-seq
 	| trailing-type-specifier trailing-type-specifier-seq
    ;
simple-type-specifier
    : type-name	 
 	| nested-name-specifier type-name
 	| DBL_COLON type-name	 
 	| DBL_COLON nested-name-specifier type-name
 	| nested-name-specifier TEMPLATE simple-template-id
    | DBL_COLON nested-name-specifier TEMPLATE simple-template-id
 	| CHAR
 	| CHAR16_T
 	| CHAR32_T
 	| WCHAR_T
 	| SIGNED
 	| UNSIGNED
 	| BOOL
 	| SHORT
 	| INT
 	| LONG
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
    : DECLTYPE LPAREN expression RPAREN
    ;
elaborated-type-specifier
    : class-key identifier
    | class-key nested-name-specifier identifier
    | class-key DBL_COLON identifier
    | class-key DBL_COLON nested-name-specifier identifier
    | class-key attribute-specifier-seq identifier
    | class-key attribute-specifier-seq nested-name-specifier identifier
    | class-key attribute-specifier-seq DBL_COLON identifier
    | class-key attribute-specifier-seq DBL_COLON nested-name-specifier identifier
 	| class-key simple-template-id
    | class-key TEMPLATE simple-template-id
    | class-key nested-name-specifier simple-template-id
    | class-key nested-name-specifier TEMPLATE simple-template-id
    | class-key DBL_COLON simple-template-id
    | class-key DBL_COLON TEMPLATE simple-template-id
    | class-key DBL_COLON nested-name-specifier simple-template-id
    | class-key DBL_COLON nested-name-specifier TEMPLATE simple-template-id
 	| ENUM identifier
    | ENUM nested-name-specifier identifier
    | ENUM DBL_COLON identifier
    | ENUM DBL_COLON nested-name-specifier identifier
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
    : enum-key
    | enum-key enum-base
    | enum-key identifier
    | enum-key identifier enum-base
    | enum-key attribute-specifier-seq
    | enum-key attribute-specifier-seq enum-base
    | enum-key attribute-specifier-seq identifier
    | enum-key attribute-specifier-seq identifier enum-base
 	| enum-key nested-name-specifier
    | enum-key nested-name-specifier identifier enum-base
    | enum-key attribute-specifier-seq nested-name-specifier identifier
    | enum-key attribute-specifier-seq nested-name-specifier identifier enum-base
    ;
opaque-enum-declaration
    : enum-key identifier SEMI
    | enum-key identifier enum-base SEMI
    | enum-key attribute-specifier-seq identifier SEMI
    | enum-key attribute-specifier-seq identifier enum-base SEMI
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
    : enumerator
 	| enumerator ASSIGN constant-expression
    ;
enumerator
    : identifier
    ;
/* namespace.def */
namespace-name
    : identifier
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
    : NAMESPACE identifier LBRACE namespace-body RBRACE
    | INLINE NAMESPACE identifier LBRACE namespace-body RBRACE
    ;
extension-namespace-definition
    : NAMESPACE original-namespace-name LBRACE namespace-body RBRACE
    | INLINE NAMESPACE original-namespace-name LBRACE namespace-body RBRACE
    ;
unnamed-namespace-definition
    : NAMESPACE LBRACE namespace-body RBRACE
    | INLINE NAMESPACE LBRACE namespace-body RBRACE
    ;
namespace-body
    : %empty
    | declaration-seq
    ;

namespace-alias-definition
    : NAMESPACE identifier ASSIGN qualified-namespace-specifier SEMI
    ;
qualified-namespace-specifier
    : namespace-name
    | nested-name-specifier namespace-name
    | DBL_COLON namespace-name
    | DBL_COLON nested-name-specifier namespace-name
    ;
/* namespace.udecl */
using-declaration
    : USING nested-name-specifier unqualified-id SEMI
    | USING DBL_COLON nested-name-specifier unqualified-id SEMI
    | USING TYPENAME nested-name-specifier unqualified-id SEMI
    | USING TYPENAME DBL_COLON nested-name-specifier unqualified-id SEMI
 	| USING DBL_COLON unqualified-id SEMI
    ;
/* namespace.udir */
using-directive
    : USING NAMESPACE identifier SEMI // fixed namespace-name -> identifier
    | USING NAMESPACE nested-name-specifier namespace-name SEMI
    | USING NAMESPACE DBL_COLON namespace-name SEMI
    | USING NAMESPACE DBL_COLON nested-name-specifier namespace-name SEMI
    | attribute-specifier-seq USING NAMESPACE namespace-name SEMI
    | attribute-specifier-seq USING NAMESPACE nested-name-specifier namespace-name SEMI
    | attribute-specifier-seq USING NAMESPACE DBL_COLON namespace-name SEMI
    | attribute-specifier-seq USING NAMESPACE DBL_COLON nested-name-specifier namespace-name SEMI
    ;
/* dcl.asm */
asm-definition
    : ASM LPAREN StringLiteral RPAREN SEMI
 	;
    
/* dcl.link */
linkage-specification
    : EXTERN StringLiteral LBRACE RBRACE
    | EXTERN StringLiteral LBRACE declaration-seq RBRACE
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
    : ALIGNAS LPAREN type-id RPAREN
    | ALIGNAS LPAREN type-id ELLIPSIS RPAREN
 	| ALIGNAS LPAREN alignment-expression RPAREN
    | ALIGNAS LPAREN alignment-expression ELLIPSIS RPAREN
    ;
attribute-list
    : %empty
    | attribute
    | attribute-list COMMA
    | attribute-list COMMA attribute
 	| attribute ELLIPSIS
 	| attribute-list COMMA attribute ELLIPSIS
    ;
attribute
    : attribute-token
    | attribute-token attribute-argument-clause
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
 	| token
    ;
/* lex.token */
token
    : identifier
    | keyword
    | literal
    | op-or-punc
//    | op-or-punc-0x
    ;
op-or-punc
    : LPAREN
    | RPAREN
    | LBRACE
    | RBRACE
    | LBRACK
    | RBRACK
    | HASH
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
 	| noptr-declarator LBRACK RBRACK
    | noptr-declarator LBRACK RBRACK attribute-specifier-seq
    | noptr-declarator LBRACK constant-expression RBRACK
    | noptr-declarator LBRACK constant-expression RBRACK attribute-specifier-seq
 	| LPAREN ptr-declarator RPAREN
    ;
parameters-and-qualifiers
    : LPAREN parameter-declaration-clause RPAREN
    | LPAREN parameter-declaration-clause RPAREN exception-specification
    | LPAREN parameter-declaration-clause RPAREN ref-qualifier
    | LPAREN parameter-declaration-clause RPAREN ref-qualifier exception-specification
    | LPAREN parameter-declaration-clause RPAREN cv-qualifier-seq
    | LPAREN parameter-declaration-clause RPAREN cv-qualifier-seq exception-specification
    | LPAREN parameter-declaration-clause RPAREN cv-qualifier-seq ref-qualifier
    | LPAREN parameter-declaration-clause RPAREN cv-qualifier-seq ref-qualifier exception-specification
    | LPAREN parameter-declaration-clause RPAREN attribute-specifier-seq
    | LPAREN parameter-declaration-clause RPAREN attribute-specifier-seq exception-specification
    | LPAREN parameter-declaration-clause RPAREN attribute-specifier-seq ref-qualifier
    | LPAREN parameter-declaration-clause RPAREN attribute-specifier-seq ref-qualifier exception-specification
    | LPAREN parameter-declaration-clause RPAREN attribute-specifier-seq cv-qualifier-seq
    | LPAREN parameter-declaration-clause RPAREN attribute-specifier-seq cv-qualifier-seq exception-specification
    | LPAREN parameter-declaration-clause RPAREN attribute-specifier-seq cv-qualifier-seq ref-qualifier
    | LPAREN parameter-declaration-clause RPAREN attribute-specifier-seq cv-qualifier-seq ref-qualifier exception-specification
    ;
trailing-return-type
    : INDIR_MBR_ACCESS trailing-type-specifier-seq
    | INDIR_MBR_ACCESS trailing-type-specifier-seq abstract-declarator
    ;
ptr-operator
    : MUL
    | MUL cv-qualifier-seq
    | MUL attribute-specifier-seq
    | MUL attribute-specifier-seq cv-qualifier-seq
 	| BITAND
    | BITAND attribute-specifier-seq
 	| AND
    | AND attribute-specifier-seq
 	| nested-name-specifier MUL
    | nested-name-specifier MUL cv-qualifier-seq
    | nested-name-specifier MUL attribute-specifier-seq
    | nested-name-specifier MUL attribute-specifier-seq cv-qualifier-seq
    | DBL_COLON nested-name-specifier MUL
    | DBL_COLON nested-name-specifier MUL cv-qualifier-seq
    | DBL_COLON nested-name-specifier MUL attribute-specifier-seq
    | DBL_COLON nested-name-specifier MUL attribute-specifier-seq cv-qualifier-seq
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
 	| class-name
    | nested-name-specifier class-name
    | DBL_COLON  class-name
    | DBL_COLON  nested-name-specifier class-name
    ;
/* dcl.name */
type-id
    : type-specifier-seq
    | type-specifier-seq abstract-declarator
    ;
abstract-declarator
    : ptr-abstract-declarator
 	| parameters-and-qualifiers trailing-return-type
    | noptr-abstract-declarator parameters-and-qualifiers trailing-return-type
 	| ELLIPSIS
    ;
ptr-abstract-declarator
    : noptr-abstract-declarator
    | ptr-operator
    | ptr-operator ptr-abstract-declarator
    ;
noptr-abstract-declarator
    : parameters-and-qualifiers
    | noptr-abstract-declarator parameters-and-qualifiers
 	| LBRACK constant-expression RBRACK
    | LBRACK constant-expression RBRACK attribute-specifier-seq
    | noptr-abstract-declarator LBRACK constant-expression RBRACK
    | noptr-abstract-declarator LBRACK constant-expression RBRACK attribute-specifier-seq
 	| LPAREN ptr-abstract-declarator RPAREN
    ;
/* dcl.fct */
parameter-declaration-clause
    : %empty
    | ELLIPSIS
    | parameter-declaration-list
    | parameter-declaration-list ELLIPSIS
 	| parameter-declaration-list COMMA ELLIPSIS
    ;
parameter-declaration-list
    : parameter-declaration
    | parameter-declaration-list COMMA parameter-declaration
    ;
parameter-declaration
    : decl-specifier-seq declarator
    | attribute-specifier-seq decl-specifier-seq declarator
 	| decl-specifier-seq declarator ASSIGN initializer-clause
    | attribute-specifier-seq decl-specifier-seq declarator ASSIGN initializer-clause
 	| decl-specifier-seq
    | decl-specifier-seq abstract-declarator
    | attribute-specifier-seq decl-specifier-seq
    | attribute-specifier-seq decl-specifier-seq abstract-declarator
 	| decl-specifier-seq ASSIGN initializer-clause
    | decl-specifier-seq abstract-declarator ASSIGN initializer-clause
    | attribute-specifier-seq decl-specifier-seq ASSIGN initializer-clause
    | attribute-specifier-seq decl-specifier-seq abstract-declarator ASSIGN initializer-clause
    ;
function-definition
    : declarator function-body
    | decl-specifier-seq declarator function-body
    | attribute-specifier-seq declarator function-body
    | attribute-specifier-seq decl-specifier-seq declarator function-body
 	| declarator ASSIGN DEFAULT SEMI
    | decl-specifier-seq declarator ASSIGN DEFAULT SEMI
    | attribute-specifier-seq declarator ASSIGN DEFAULT SEMI
    | attribute-specifier-seq decl-specifier-seq declarator ASSIGN DEFAULT SEMI
 	| declarator ASSIGN DELETE SEMI
    | decl-specifier-seq declarator ASSIGN DELETE SEMI
    | attribute-specifier-seq declarator ASSIGN DELETE SEMI
    | attribute-specifier-seq decl-specifier-seq declarator ASSIGN DELETE SEMI
    ;
function-body
    : compound-statement
    | ctor-initializer compound-statement
 	| function-try-block
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
    
/**
 * this part is for statement 
 */
/* stmt.stmt */
statement
    : labeled-statement
 	| expression-statement
    | attribute-specifier-seq expression-statement
 	| compound-statement
    | attribute-specifier-seq compound-statement
 	| selection-statement
    | attribute-specifier-seq selection-statement
 	| iteration-statement
    | attribute-specifier-seq iteration-statement
 	| jump-statement
    | attribute-specifier-seq jump-statement
 	| declaration-statement
 	| try-block
    | attribute-specifier-seq try-block
    ;
/* stmt.label */
labeled-statement
    : identifier COLON statement
    | attribute-specifier-seq identifier COLON statement
    | case constant-expression COLON statement
 	| attribute-specifier-seq default COLON statement
    ;
/* stmt.expr*/
expression-statement
    : SEMI
    | expression SEMI
    ;
/* stmt.bloc */
compound-statement 
    : LBRACE statement-seq RBRACE
    | LBRACE RBRACE
    ;
statement-seq : statement
 	| statement-seq statement
    ;
/* stmt.select */
selection-statement
    : IF LPAREN condition RPAREN statement
 	| IF LPAREN condition RPAREN statement ELSE statement
 	| SWITCH ( condition ) statement
    ;
condition
    : expression
 	| decl-specifier-seq declarator ASSIGN initializer-clause
    | attribute-specifier-seq decl-specifier-seq declarator ASSIGN initializer-clause
 	| decl-specifier-seq declarator braced-init-list
    | attribute-specifier-seq decl-specifier-seq declarator braced-init-list
    ;
/* stmt.iter */
iteration-statement
    : WHILE LPAREN condition RPAREN statement
 	| DO statement WHILE LPAREN expression RPAREN SEMI
 	| FOR LPAREN for-init-statement SEMI RPAREN statement
    | FOR LPAREN for-init-statement SEMI expression RPAREN statement
    | FOR LPAREN for-init-statement condition SEMI RPAREN statement
    | FOR LPAREN for-init-statement condition SEMI expression RPAREN statement
 	| FOR LPAREN for-range-declaration COLON for-range-initializer RPAREN statement
    ;
for-init-statement
    : expression-statement
 	| simple-declaration
    ;
for-range-declaration
    : type-specifier-seq declarator
    | attribute-specifier-seq type-specifier-seq declarator
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
 	| RETURN SEMI
    | RETURN braced-init-list SEMI
 	| GOTO identifier SEMI
    ;
/* stmt.dcl */
declaration-statement
    : block-declaration
    ;
    
/**
 * this is for expression 
 */
/* expr.prim */    
primary-expression 
    : literal
    | THIS
    | LPAREN expression RPAREN
    | id-expression
    | lambda-expression
    ;
id-expression 
    : unqualified-id
 	|qualified-id
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
    : nested-name-specifier unqualified-id 
    | nested-name-specifier TEMPLATE unqualified-id
    | DBL_COLON nested-name-specifier unqualified-id
    | DBL_COLON nested-name-specifier TEMPLATE unqualified-id
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
    | nested-name-specifier simple-template-id DBL_COLON
    | nested-name-specifier template simple-template-id DBL_COLON
    ;
/* expr.lambda */
lambda-expression 
    : lambda-introducer compound-statement
    | lambda-introducer lambda-declarator compound-statement
    ;   
lambda-introducer 
    : LBRACK RBRACK
    | LBRACK lambda-capture RBRACK
    ;

lambda-capture
    : capture-default
    | capture-list
 	| capture-default COMMA capture-list
    ;
capture-default 
    : BITAND 
    | ASSIGN
    ;
capture-list 
    : capture
    | capture ELLIPSIS
    | capture-list COMMA capture
    | capture-list COMMA capture ELLIPSIS
    ;
capture 
    : identifier
    | BITAND identifier
    | THIS
    ;
lambda-declarator 
    : LPAREN RPAREN INDIR_MBR_ACCESS
    | LPAREN parameter-declaration-clause RPAREN
    | LPAREN parameter-declaration-clause RPAREN trailing-return-type
    | LPAREN parameter-declaration-clause RPAREN attribute-specifier-seq
    | LPAREN parameter-declaration-clause RPAREN attribute-specifier-seq trailing-return-type
    | LPAREN parameter-declaration-clause RPAREN exception-specification
    | LPAREN parameter-declaration-clause RPAREN exception-specification trailing-return-type
    | LPAREN parameter-declaration-clause RPAREN exception-specification attribute-specifier-seq
    | LPAREN parameter-declaration-clause RPAREN exception-specification attribute-specifier-seq trailing-return-type
    | LPAREN parameter-declaration-clause RPAREN mutable
    | LPAREN parameter-declaration-clause RPAREN mutable trailing-return-type
    | LPAREN parameter-declaration-clause RPAREN mutable attribute-specifier-seq
    | LPAREN parameter-declaration-clause RPAREN mutable attribute-specifier-seq trailing-return-type
    | LPAREN parameter-declaration-clause RPAREN mutable exception-specification
    | LPAREN parameter-declaration-clause RPAREN mutable exception-specification trailing-return-type
    | LPAREN parameter-declaration-clause RPAREN mutable exception-specification attribute-specifier-seq
    | LPAREN parameter-declaration-clause RPAREN mutable exception-specification attribute-specifier-seq trailing-return-type
    ;
/* expr.post */
postfix-expression 
    : primary-expression
    | postfix-expression LBRACK expression RBRACK
    | postfix-expression LBRACK RBRACK
    | postfix-expression LBRACK braced-init-list RBRACK
    | postfix-expression LPAREN RPAREN
    | postfix-expression LPAREN expression-list RPAREN
 	| simple-type-specifier LPAREN RPAREN
 	| simple-type-specifier LPAREN expression-list RPAREN
 	| typename-specifier LPAREN RPAREN
    | typename-specifier LPAREN expression-list RPAREN
 	| simple-type-specifier braced-init-list
 	| typename-specifier braced-init-list
 	| postfix-expression DOT template id-expression
    | postfix-expression DOT id-expression
 	| postfix-expression INDIR_MBR_ACCESS id-expression
    | postfix-expression INDIR_MBR_ACCESS template id-expression
 	| postfix-expression DOT pseudo-destructor-name
 	| postfix-expression INDIR_MBR_ACCESS pseudo-destructor-name
    | postfix-expression INC
 	| postfix-expression DEC
 	| DYNAMIC_CAST LT type-id RT LPAREN expression RPAREN
 	| STATIC_CAST LT type-id RT LPAREN expression RPAREN
 	| REINTERPRET_CAST LT type-id RT LPAREN expression RPAREN
 	| CONST_CAST LT type-id RT LPRAEN expression RPAREN
 	| TYPEID LPRAEN expression RPAREN
 	| TYPEID LPRAEN type-id RPAREN
    ;
expression-list 
    : initializer-list
    ;
pseudo-destructor-name
    : type-name DBL_COLON TILDE type-name
    | nested-name-specifier type-name DBL_COLON TILDE type-name
    | DBL_COLON type-name DBL_COLON TILDE type-name
    | DBL_COLON nested-name-specifier type-name DBL_COLON TILDE type-name
    | nested-name-specifier TEMPLATE simple-template-id DBL_COLON TILDE type-name
    | DBL_COLON nested-name-specifier TEMPLATE simple-template-id DBL_COLON TILDE type-name
    | TILDE type-name
    | nested-name-specifier TILDE type-name
    | DBL_COLON TILDE type-name
    | DBL_COLON nested-name-specifier TILDE type-name
 	| TILDE decltype-specifier
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
noexcept-expression 
    : NOEXCEPT LPAREN expression RPAREN
    ;
new-expression
    : NEW new-type-id
    | NEW new-type-id new-initializer
    | NEW new-placement new-type-id
    | NEW new-placement new-type-id new-initializer
    | DBL_COLON NEW new-type-id
    | DBL_COLON NEW new-type-id new-initializer
    | DBL_COLON NEW new-placement new-type-id
    | DBL_COLON NEW new-placement new-type-id new-initializer
 	| NEW LPAREN type-id RPAREN
    | NEW LPAREN type-id RPAREN new-initializer
    | NEW new-placement LPAREN type-id RPAREN
    | NEW new-placement LPAREN type-id RPAREN new-initialize
    | DBL_COLON NEW LPAREN type-id RPAREN
    | DBL_COLON NEW LPAREN type-id RPAREN new-initializer
    | DBL_COLON NEW new-placement LPAREN type-id RPAREN
    | DBL_COLON NEW new-placement LPAREN type-id RPAREN new-initializer
    ;
new-placement
    : LPAREN expression-list RPAREN
    ;
new-type-id
    : type-specifier-seq
    | type-specifier-seq new-declarator
    ;
new-declarator
    : ptr-operator
    | ptr-operator new-declarator
 	| noptr-new-declarator
    ;
noptr-new-declarator
    : LBRACK expression RBRACK
    | LBRACK expression RBRACK attribute-specifier-seq
 	| noptr-new-declarator LBRACK constant-expression RBRACK
    | noptr-new-declarator LBRACK constant-expression RBRACK attribute-specifier-seq
    ;
new-initializer
    : LPAREN RPAREN
    | LPAREN expression-list RPAREN
 	| braced-init-list
    ;
delete-expression 
    : DELETE cast-expression
    | DBL_COLON DELETE cast-expression
    | DELETE LBRACK RBRACK cast-expression
    | DBL_COLON DELETE LBRACK RBRACK cast-expression
    ;
cast-expression 
    : unary-expression
 	| LPAREN type-id RPAREN cast-expression
    ;
pm-expression 
    : cast-expression
 	| pm-expression DOT_STAR cast-expression
 	| pm-expression ARROW_STAR cast-expression
    ;
multiplicative-expression 
    : pm-expression
 	| multiplicative-expression MUL pm-expression
 	| multiplicative-expression DIV pm-expression
 	| multiplicative-expression MOD pm-expression
    ;
additive-expression 
    : multiplicative-expression
 	| additive-expression ADD multiplicative-expression
 	| additive-expression SUB multiplicative-expression
    ;
shift-expression 
    : additive-expression
    | shift-expression LSHIFT additive-expression
 	| shift-expression RSHIFT additive-expression
 	;
relational-expression 
    : shift-expression
 	| relational-expression LT shift-expression
 	| relational-expression RT shift-expression
 	| relational-expression LE shift-expression
 	| relational-expression RE shift-expression
    ;
equality-expression 
    : relational-expression
 	| equality-expression EQUAL relational-expression
 	| equality-expression NOTEQUAL relational-expression
    ;
and-expression 
    : equality-expression
 	| and-expression BITAND equality-expression
    ;
exclusive-or-expression 
    : and-expression
 	| exclusive-or-expression CARET and-expression
    ;
inclusive-or-expression 
    : exclusive-or-expression
 	| inclusive-or-expression BITOR exclusive-or-expression
    ;
logical-and-expression 
    : inclusive-or-expression
 	| logical-and-expression AND inclusive-or-expression
    ;
logical-or-expression 
    : logical-and-expression
 	| logical-or-expression OR logical-and-expression
    ;
conditional-expression 
    : logical-or-expression
 	| logical-or-expression QUESTION expression COLON assignment-expression
    ;
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
expression 
    : assignment-expression
 	| expression COMMA assignment-expression
    ;
    
constant-expression 
    : conditional-expression
    ;

/* part for unimplmented lex */
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
    | user-defined-string-literal
 	| user-defined-character-literal
    ;
user-defined-integer-literal 
    : IntegerLiteral ud-suffix
    ;
user-defined-floating-literal 
    : FloatingLiteral ud-suffix
    ;
user-defined-string-literal 
    : StringLiteral ud-suffix
    ;
user-defined-character-literal 
    : CharacterLiteral ud-suffix
    ;
ud-suffix 
    : identifier
    ;