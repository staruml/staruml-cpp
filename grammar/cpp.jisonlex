/* Identifiers */
CppLetter                       [a-zA-Z$_];

%%

/* Keywords */
"virtaul"                       return 'VITRUAL';
"static"                        return 'STATIC';
"const"                         return 'CONST';

"struct"                        return 'STRUCT';
"class"                         return 'CLASS';

/* variable type */
"bool"                          return 'BOOL';
"int"                           return 'INT';
"long"                          return 'LONG';
"double"                        return 'DOUBLE';
"float"                         return 'FLOAT';
"char"                          return 'CHAR';
"void"                          return 'VOID';


/* special character */

"("                             return 'LPAREN';
")"                             return 'RPAREN';
"{"                             return 'LBRACE';
"}"                             return 'RBRACE';

%s                              comment
%%

\s+                             /* skip whitespace */
[/]{2}.*                        /* skip comments */


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


<<EOF>>                         return 'EOF';