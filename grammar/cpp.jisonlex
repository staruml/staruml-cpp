%lex
%options flex
 

/* Documentation Comments */
SINGLE_LINE_DOC_COMMENT         '///'{Input_characters}?   
 

/* Line Terminators */
NEW_LINE                        [\u000D]|[\u000A]|([\u000D][\u000A])|[\u0085]|[\u2029]
   

/* Comments */
SINGLE_LINE_COMMENT             [/]{2} {Input_characters}?                       /* skip comments */
Input_characters                {Input_character}+

/* <Any Unicode Character Except A NEW_LINE_CHARACTER> */
Input_character                 [^\u000D\u000A\u0085\u2028\u2029\n]
NEW_LINE_CHARACTER              [\u000D]|[\u000A]|[\u0085]|[\u2028]|[\u2029]|'\n' 

 
 
  
 

/* Custome Lexer rules */
QUOTE                           '\''
DOUBLE_QUOTE                    '"'
BACK_SLASH                      '\\'
DOUBLE_BACK_SLASH               '\\\\'
SHARP                           '#'
DOT                             '.'  
STAR                            '*'

TRUE                            'true'
FALSE                           'false'
OP_OR                           '||'


/* Unicode character classes */  
UNICODE_CLASS_Zs                [\u0020]|[\u00A0]|[\u1680]|[\u180E]|[\u2000]|[\u2001]|[\u2002]|[\u2003]|[\u2004]|[\u2005]|[\u2006]|[\u2008]|[\u2009]|[\u200A]|[\u202F]|[\u3000]|[\u205F] 
UNICODE_CLASS_Lu                [\u0041-\u005A]|[\u00C0-\u00DE]
UNICODE_CLASS_Ll                [\u0061-\u007A]
UNICODE_CLASS_Lt                [\u01C5]|[\u01C8]|[\u01CB]|[\u01F2]
UNICODE_CLASS_Lm                [\u02B0-\u02EE]
UNICODE_CLASS_Lo                [\u01BB]|[\u01C0]|[\u01C1]|[\u01C2]|[\u01C3]|[\u0294]
UNICODE_CLASS_Nl                [\u16EE]|[\u16EF]|[\u16F0]|[\u2160]|[\u2161]|[\u2162]|[\u2163]|[\u2164]|[\u2165]|[\u2166]|[\u2167]|[\u2168]|[\u2169]|[\u216A]|[\u216B]|[\u216C]|[\u216D]|[\u216E]|[\u216F]
UNICODE_CLASS_Mn                [\u0300]|[\u0301]|[\u0302]|[\u0303]|[\u0304]|[\u0305]|[\u0306]|[\u0307]|[\u0308]|[\u0309]|[\u030A]|[\u030B]|[\u030C]|[\u030D]|[\u030E]|[\u030F]|[\u0310]
UNICODE_CLASS_Mc                [\u0903]|[\u093E]|[\u093F]|[\u0940]|[\u0949]|[\u094A]|[\u094B]|[\u094C]
UNICODE_CLASS_Cf                [\u00AD]|[\u0600]|[\u0601]|[\u0602]|[\u0603]|[\u06DD]
UNICODE_CLASS_Pc                [\u005F]|[\u203F]|[\u2040]|[\u2054]|[\uFE33]|[\uFE34]|[\uFE4D]|[\uFE4E]|[\uFE4F]|[\uFF3F]
UNICODE_CLASS_Nd                [\u0030]|[\u0031]|[\u0032]|[\u0033]|[\u0034]|[\u0035]|[\u0036]|[\u0037]|[\u0038]|[\u0039]


/* White space */  
WHITESPACE                      {Whitespace_characters}      
Whitespace_characters           {Whitespace_character}+
Whitespace_character            {UNICODE_CLASS_Zs}|[\u0009]|[\u000B]|[\u000C]|[\s]


/* Unicode Character Escape Sequences */
Unicode_escape_sequence         '\\u' {HEX_DIGIT}{4}|'\\U' {HEX_DIGIT}{8} 



Template                        [<][^=;\|\+\-\"\'\{\\}]*[>]+

/* Identifiers  */
IDENTIFIER                      ({Available_identifier}|'@'{Identifier_or_keyword}) 

/* <An Identifier_or_keyword That Is Not A Keyword> */
Available_identifier            {Identifier_or_keyword}
Identifier_or_keyword           {Identifier_start_character}{Identifier_part_characters}?
Identifier_start_character      {Letter_character}|'_'
Identifier_part_characters      {Identifier_part_character}+
Identifier_part_character       {Letter_character}|{Decimal_digit_character}|{Connecting_character}|{Combining_character}|{Formatting_character}
  
/* <A Unicode Character Of Classes Lu, Ll, Lt, Lm, Lo, Or Nl> */ 
Letter_character                {UNICODE_CLASS_Lu}|{UNICODE_CLASS_Ll}|{UNICODE_CLASS_Lt}|{UNICODE_CLASS_Lm}|{UNICODE_CLASS_Lo}|{UNICODE_CLASS_Nl}

/* <A Unicode Character Of Classes Mn Or Mc> */
Combining_character             {UNICODE_CLASS_Mn}|{UNICODE_CLASS_Mc}

/* <A Unicode Character Of The Class Nd> */
Decimal_digit_character         {UNICODE_CLASS_Nd}

/* <A Unicode Character Of The Class Pc> */
Connecting_character            {UNICODE_CLASS_Pc}

/* <A Unicode Character Of The Class Cf> */ 
Formatting_character            {UNICODE_CLASS_Cf}



/* Real Literals */
REAL_LITERAL                    {Decimal_digits}{DOT}{Decimal_digits}?{Exponent_part}?{Real_type_suffix}?|{DOT}{Decimal_digits}{Exponent_part}?{Real_type_suffix}?|{Decimal_digits}{Exponent_part}{Real_type_suffix}?|{Decimal_digits}{Real_type_suffix}
Exponent_part                   'e'{Sign}?{Decimal_digits}|'E'{Sign}?{Decimal_digits}
Sign                            '+'|'-'
Real_type_suffix                'F'|'f'|'L'|'l'


/* Integer Literals */
INTEGER_LITERAL                 {Hexadecimal_integer_literal}|{Decimal_integer_literal}
Decimal_integer_literal         {Decimal_digits}{Integer_type_suffix}?
Decimal_digits                  {DECIMAL_DIGIT}+
DECIMAL_DIGIT                   [0-9]
Integer_type_suffix             'ULL'|'UL'|'Ul'|'uL'|'ul'|'LU'|'Lu'|'LL'|'lU'|'lu'|'ll'|'U'|'u'|'L'|'l'|'i64'
Hexadecimal_integer_literal     ('0x'{Hex_digits}{Integer_type_suffix}?) | ('0X'{Hex_digits}{Integer_type_suffix}?)
Hex_digits                      {HEX_DIGIT}+
HEX_DIGIT                       [0-9a-fA-F] 


/* String Literals */
STRING_LITERAL                              [L]?{Regular_string_literal}|{Verbatim_string_literal}
Regular_string_literal                      {DOUBLE_QUOTE}{Regular_string_literal_characters}?{DOUBLE_QUOTE}
Regular_string_literal_characters           {Regular_string_literal_character}+  
Regular_string_literal_character            {Single_regular_string_literal_character}|{Simple_escape_sequence}|{Hexadecimal_escape_sequence}|{Unicode_escape_sequence}|'\"'|'\\'
  
/* <Any Character Except " (U+0022), \\ (U+005C), And NEW_LINE_CHARACTER> */
Single_regular_string_literal_character     [^"\\]

Verbatim_string_literal                     '@'{DOUBLE_QUOTE}{Verbatim_string_literal_characters}?{DOUBLE_QUOTE}
Verbatim_string_literal_characters          {Verbatim_string_literal_character}+
Verbatim_string_literal_character           {Single_verbatim_string_literal_character}|{Quote_escape_sequence}|'\"'|'\\' 
Single_verbatim_string_literal_character    [^"]
Quote_escape_sequence                       '""'
  

/* Character Literals */
CHARACTER_LITERAL               [L]?{QUOTE}{Character}{QUOTE}
Character                       {Single_character}|{Simple_escape_sequence}|{Hexadecimal_escape_sequence}|{Unicode_escape_sequence}
Single_character                [^']
Simple_escape_sequence          '\\\''|'\\"'|{DOUBLE_BACK_SLASH}|'\\0'|'\\a'|'\\b'|'\\f'|'\\n'|'\\r'|'\\t'|'\\v'  
Hexadecimal_escape_sequence     '\\x'{HEX_DIGIT}{4}|'\\x'{HEX_DIGIT}{3}|'\\x'{HEX_DIGIT}{2}|'\\x'{HEX_DIGIT}
   
   
/* C.1.10 Pre-processing directives */
SINGLE_PREPROCESSING            [#] {Input_characters}? 
   

%s                              comment
 
%%
 
((("/*")))                      %{ this.begin('comment'); %}

<comment>[^\*]+                 %{
                                    if (yy.__currentComment) {
                                        yy.__currentComment += "\n" + yytext.trim();
                                    } else {
                                        yy.__currentComment = yytext.trim();
                                    }
                                %}
<comment>[\"]                   /* skip */                  
<comment>[=]                    /* skip */
<comment>[\*][=\"']*            %{
                                    var currentChar = yytext;                                    
                                    // console.log("currentChar" + currentChar);
                                    if(currentChar === '*') {
                                        var nxtChar = this._input[0]; // peek into next char without altering lexer's position
                                        //console.log("* match :"+yytext)
                                        //console.log("* match, nxt char:"+nxtChar)
                                        if(nxtChar === '/')
                                        {
                                            //console.log("inside popBlock"+nxtChar);
                                            nxtChar = this.input();
                                            if(nxtChar.length > 1)
                                            this.unput(2,nxtChar.length);
                                            //console.log("popped state");
                                            //console.log(this.showPosition());
                                            this.popState();
                                        }
                                    }
                                %}

{WHITESPACE}                    /* skip */
{NEW_LINE_CHARACTER}            /* skip */
        
{SINGLE_LINE_COMMENT}           /* skip */ 

{SINGLE_LINE_DOC_COMMENT}       /* skip */ 
{NEW_LINE}                      /* skip */
 
 

/* Keywords */
"abstract"                      return 'ABSTRACT';
"as"                            return 'AS'; 
"bool"                          return 'BOOL';
"break"                         return 'BREAK'; 
"case"                          return 'CASE';
"catch"                         return 'CATCH';
"char"                          return 'CHAR';
"checked"                       return 'CHECKED';
"class"                         return 'CLASS';
"const"                         return 'CONST';
"continue"                      return 'CONTINUE';
"decimal"                       return 'DECIMAL';
"default"                       return 'DEFAULT';
"delegate"                      return 'DELEGATE';
"do"                            return 'DO';
"double"                        return 'DOUBLE';
"else"                          return 'ELSE';
"enum"                          return 'ENUM'; 
"explicit"                      return 'EXPLICIT';
"extern"                        return 'EXTERN';
{FALSE}                         return 'FALSE';
"finally"                       return 'FINALLY';
"fixed"                         return 'FIXED';
"float"                         return 'FLOAT';
"for"                           return 'FOR';
"foreach"                       return 'FOREACH';
"goto"                          return 'GOTO';
"if"                            return 'IF';
"implicit"                      return 'IMPLICIT';  
"int"                           return 'INT';
"interface"                     return 'INTERFACE';
"internal"                      return 'INTERNAL'; 
"long"                          return 'LONG';
"namespace"                     return 'NAMESPACE';
"new"                           return 'NEW';
"null"                          return 'NULL'; 
"operator"                      return 'OPERATOR'; 
"override"                      return 'OVERRIDE';
"params"                        return 'PARAMS';
"private"                       return 'PRIVATE';
"protected"                     return 'PROTECTED';
"public"                        return 'PUBLIC';
"readonly"                      return 'READONLY'; 
"return"                        return 'RETURN';
"sbyte"                         return 'SBYTE'; 
"short"                         return 'SHORT';
"sizeof"                        return 'SIZEOF';
"stackalloc"                    return 'STACKALLOC';
"static"                        return 'STATIC'; 
"struct"                        return 'STRUCT';
"switch"                        return 'SWITCH';
"this"                          return 'THIS';
"throw"                         return 'THROW';
{TRUE}                          return 'TRUE';
"try"                           return 'TRY';
"typeof"                        return 'TYPEOF';
"uint"                          return 'UINT';
"ulong"                         return 'ULONG';
"unchecked"                     return 'UNCHECKED';
"unsafe"                        return 'UNSAFE';
"ushort"                        return 'USHORT';
"using"                         return 'USING';
"virtual"                       return 'VIRTUAL';
"void"                          return 'VOID';
"volatile"                      return 'VOLATILE';
"while"                         return 'WHILE';

"assembly"                      return 'ASSEMBLY';
"module"                        return 'MODULE';

"field"                         return 'FIELD';
"method"                        return 'METHOD';
"param"                         return 'PARAM';
"property"                      return 'PROPERTY'; 
 

"add"                           return 'ADD';
"remove"                        return 'REMOVE';

"partial"                       return 'PARTIAL';
"yield"                         return 'YIELD';
 
"await"                         return 'AWAIT';

"where"                         return 'WHERE';

"delete"                        return 'DELETE';

"friend"                        return 'FRIEND';
"typedef"                       return 'TYPEDEF';

"auto"                          return 'AUTO';
"register"                      return 'REGISTER';

"inline"                        return 'INLINE';

"signed"                        return 'SIGNED';
"unsigned"                      return 'UNSIGNED';

"union"                         return 'UNION';

"asm"                           return 'ASM';

"ref"                           return 'REF';

{Unicode_escape_sequence}       return 'Unicode_escape_sequence';
 
{REAL_LITERAL}                  return 'REAL_LITERAL';
{INTEGER_LITERAL}               return 'INTEGER_LITERAL'; 
{STRING_LITERAL}                return 'STRING_LITERAL';
{CHARACTER_LITERAL}             return 'CHARACTER_LITERAL';

/* Operators And Punctuators*/
"{"                             return 'OPEN_BRACE';
"}"                             return 'CLOSE_BRACE';
"["                             return 'OPEN_BRACKET';
"]"                             return 'CLOSE_BRACKET';
"("                             return 'OPEN_PARENS';
")"                             return 'CLOSE_PARENS';
","                             return 'COMMA';
":"                             return 'COLON';
";"                             return 'SEMICOLON';
"+"                             return 'PLUS';
"-"                             return 'MINUS';
{STAR}                          return 'STAR';
"/"                             return 'DIV';
"%"                             return 'PERCENT';
"&"                             return 'AMP';
"|"                             return 'BITWISE_OR';
"^"                             return 'CARET';
"!"                             return 'BANG';
"~"                             return 'TILDE';
"="                             return 'ASSIGN';
"<"                             return 'LT';
">"                             return 'GT';
"?"                             return 'INTERR';
"::"                            return 'DOUBLE_COLON';
"??"                            return 'OP_COALESCING';
"++"                            return 'OP_INC';
"--"                            return 'OP_DEC';
"&&"                            return 'OP_AND';
{OP_OR}                         return 'OP_OR';
"->"                            return 'OP_PTR';
"=>"                            return 'OP_DBLPTR';
"=="                            return 'OP_EQ';
"!="                            return 'OP_NE';
"<="                            return 'OP_LE';
">="                            return 'OP_GE';
"+="                            return 'OP_ADD_ASSIGNMENT';
"-="                            return 'OP_SUB_ASSIGNMENT';
"*="                            return 'OP_MULT_ASSIGNMENT';
"/="                            return 'OP_DIV_ASSIGNMENT';
"%="                            return 'OP_MOD_ASSIGNMENT';
"&="                            return 'OP_AND_ASSIGNMENT';
"|="                            return 'OP_OR_ASSIGNMENT';
"^="                            return 'OP_XOR_ASSIGNMENT';
"<<"                            return 'OP_LEFT_SHIFT';
"<<="                           return 'OP_LEFT_SHIFT_ASSIGNMENT';
">>"                            return 'RIGHT_SHIFT';
">>="                           return 'RIGHT_SHIFT_ASSIGNMENT';
{DOT}                           return 'DOT'
"..."                           return 'DOTS'

{SINGLE_PREPROCESSING}          %{
                                    var r = yytext;
                                    //console.log('#1: '+r);
                                    while(r[r.length-1]=='\\'){
                                        yylloc.first_line++;
                                        yylloc.last_line++; 
                                        temp = '';
                                        idx = 1;
                                        nxtLine = this._input;
                                        if(this._input[0]!='\n'){
                                            idx=0;
                                        }
                                        while(this._input[idx]!='\n'){
                                                temp= temp+this._input[idx];
                                                idx++;
                                            }
                                        this._input = nxtLine.substring(idx);
                                        r = temp; 
                                        
                                    }
                                        
                                %}

{Template}                      %{
                                        //console.log(this.showPosition());
                                    var r = yytext;
                                    var forTest3 = "";
                                    /* 
                                     * test 1: check if it is template declaration or LT operator
                                     * test 3: check for && operator. if found, its not a template
                                     * test 2: balanced < and > symbols
                                    */
                                    var test1=false,test2=false,test3=false, skipTest3= false;
                                     
                                    for(var i=1; i<r.length; i++) {
                                        if((r[i] === ' ')||(r[i]==='\t')||(r[i]==='\n'))
                                            continue; 
                                        else {
                                            if(r[i]==='<') {
                                                console.log(this.showPosition());
                                                //this.parseError("Invalid bitshift/template expression. Try grouping with parantheses",{text:yytext,token:'',line:yylineno})
                                                test1 = false;
                                                this.unput(r.substring(2,r.length));
                                                return 'OP_LEFT_SHIFT';
                                                break;
                                            } else {
                                                test1 = true;
                                                break;
                                            }
                                        }
                                    }
                                    /* Start Test 2 */
                                    r = yytext;
                                    var balance = 1;
                                    var splitPos = -1;
                                    for(var i=1; i<r.length; i++) {
                                        if(r[i] === '<')
                                            balance = balance+1;
                                        if(r[i] === '>')
                                            balance = balance-1;
                                        if(balance === 0) {
                                            splitPos = i;
                                            break;
                                        }
                                    }
                                    if(balance === 0) {
                                        if(splitPos === (r.length-1)) {
                                            test2 = true;
                                            forTest3 = r;
                                        }
                                        else {
                                            if(r[splitPos+1]=='>') { /* >> left shift operator */
                                                /* test case /openjdk/hotspot/test/compiler/6711117/Test.java:76 */
                                                test2 = false;
                                                this.unput(r.substring(1,r.length));
                                                return 'LT';
                                            } else {
                                                forTest3 = r.substring(0,splitPos+1);
                                                //console.log("inside test2: "+yytext);
                                                //console.log("test2 unput: "+r.substring(splitPos+1,r.length));
                                                this.unput(r.substring(splitPos+1,r.length))
                                                test2 = true;
                                            }
                                        }
                                    }
                                    else {
                                        test2 = false;
                                        this.unput(r.substring(1,r.length));
                                        return 'LT';
                                    }
                                    /* Start Test 3 */
                                    //console.log("test3 start"+forTest3);
                                    if(forTest3.search("&&") === -1) {
                                        test3 = true;
                                    }
                                    else
                                    {
                                        test3 = false;
                                        //console.log("inside test3: "+forTest3);
                                        this.unput(forTest3.substring(1,forTest3.length));
                                        return 'LT';
                                    }
                                    if(test1 && test2 && test3) {
                                        yytext = forTest3;
                                        return 'TEMPLATE'; 
                                    }
                                %}

{IDENTIFIER}                    return 'IDENTIFIER';
 
        
<<EOF>>                         return 'EOF';
 
    
  