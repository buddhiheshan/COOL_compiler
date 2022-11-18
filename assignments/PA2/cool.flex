/*
 *  The scanner definition for COOL.
 */

/*
 *  Stuff enclosed in %{ %} in the first section is copied verbatim to the
 *  output, so headers and global definitions are placed here to be visible
 * to the code in the file.  Don't remove anything that was here initially
 */
%{
#include <cool-parse.h>
#include <stringtab.h>
#include <utilities.h>

/* The compiler assumes these identifiers. */
#define yylval cool_yylval
#define yylex  cool_yylex

/* Max size of string constants */
#define MAX_STR_CONST 1025
#define YY_NO_UNPUT   /* keep g++ happy */

extern FILE *fin; /* we read from this file */

/* define YY_INPUT so we read from the FILE fin:
 * This change makes it possible to use this scanner in
 * the Cool compiler.
 */
#undef YY_INPUT
#define YY_INPUT(buf,result,max_size) \
	if ( (result = fread( (char*)buf, sizeof(char), max_size, fin)) < 0) \
		YY_FATAL_ERROR( "read() in flex scanner failed");

char string_buf[MAX_STR_CONST]; /* to assemble string constants */
char *string_buf_ptr;

extern int curr_lineno;
extern int verbose_flag;

extern YYSTYPE cool_yylval;

/*
 *  Add Your own definitions here
 */

 /* to keep track of depth of comments**/
int comment_depth;

bool isStringMax();


%}

/****************************************************************/
/*						Definitions								*/
/****************************************************************/
/* name		pattern												*/
/****************************************************************/
 
/* Exclusive start conditions for comments and strings */
%x COMMENT STRING 

/* Newline */
NEW_LINE	\n

/* Composite notations */
DARROW		=>
ASSIGN		<-
LE			<=

/* KEYWORDS */
CLASS		(?i:class)
ELSE		(?i:else)
FI			(?i:fi)
IF			(?i:if)
IN			(?i:in)
INHERITS	(?i:inherits)
ISVOID		(?i:isvoid)
LET			(?i:let)
LOOP		(?i:loop)
POOL		(?i:pool)
THEN		(?i:then)
WHILE		(?i:while)
CASE		(?i:case)
ESAC		(?i:esac)
NEW			(?i:new)
OF			(?i:of)
NOT			(?i:not)

FALSE		f(?:alse)
TRUE		t(?i:rue)


/* INTEGERS */
DIGIT		[0-9]
INTEGER		[0-9]+

/* Type identifiers and object identifiers */
TYPEID	    [A-Z]([A-Za-z_0-9])*
OBJECTID    [a-z]([A-Za-z_0-9])*

/* Comments */
LINE_COMMENT		--.*
BEGIN_COMMENT		\(\*
END_COMMENT			\*\)

/* STRINGS */
QUOTE				\"
NULL_CHARACTER		\\0

%%

 /***************************************************************/
 /*							Rules								*/
 /***************************************************************/
 /* pattern		action											*/
 /***************************************************************/

 /* Rule to increment curr_line on newline */
{NEW_LINE}  {curr_lineno++;}

 /* Rules for keywords */
{CLASS}	    {return CLASS;}
{ELSE}	    {return ELSE;}
{IF}	    {return IF;}
{FI}	    {return FI;}
{WHILE}	    {return WHILE;}
{IN}	    {return IN;}
{INHERITS}  {return INHERITS;}
{ISVOID}    {return ISVOID;}
{LET}	    {return LET;}
{LOOP}      {return LOOP;}
{POOL}      {return POOL;}
{THEN}      {return THEN;}
{CASE}      {return CASE;}
{ESAC}      {return ESAC;}
{NEW}       {return NEW;}
{OF}        {return OF;}
{NOT}       {return NOT;}

{TRUE}	{
	cool_yylval.boolean = true;
	return (BOOL_CONST);     
}
{FALSE}	{
	cool_yylval.boolean = false;
	return (BOOL_CONST);
}

 /* Rule for integers */
{INTEGER}   {
	cool_yylval.symbol = inttable.add_string(yytext);
	return (INT_CONST);
}

 /* Rules for type identifiers and object identifiers */
{TYPEID}   {
	cool_yylval.symbol = idtable.add_string(yytext); 
	return (TYPEID);
}
{OBJECTID}   {
	cool_yylval.symbol = idtable.add_string(yytext); 
	return (OBJECTID);
}


 /* Rules for special syntactic symbols */
"("			{return '(';}
")"			{return ')';}
"."			{return '.';}
"@"			{return '@';}
"~"			{return '~';}
"*"			{return '*';}
"/"			{return '/';}
"+"			{return '+';}
"-"			{return '-';}
"<"			{return '<';}
"="			{return '=';}
{DARROW}	{return DARROW;}
{LE}		{return LE;}
{ASSIGN}	{return ASSIGN;}
"{"			{return '{';}
"}"			{return '}';}
":"			{return ':';}
","	 		{return ',';}
";"			{return ';';}

 /* Rules for comments */
{LINE_COMMENT}	{}
{BEGIN_COMMENT}	{
    BEGIN(COMMENT);
    comment_depth++;
}		
 /* Check for unmatched closing comment */
{END_COMMENT} {
    cool_yylval.error_msg = "Unmatched *)";
	return ERROR;
}

<COMMENT>{

    /* Increment comment_depth on new comment open */
    {BEGIN_COMMENT}	{
		++comment_depth;
	}

    /* Decrement comment depth on close and exit COMMENT state on depth == 0 */
    {END_COMMENT}   {
		if(--comment_depth == 0)
			BEGIN(INITIAL);
	}

    /* Error when EOF in comment */
    <<EOF>> {
		BEGIN(INITIAL);
		cool_yylval.error_msg = "EOF in comment";
		return ERROR;
    }

    /* increment on new line */
    {NEW_LINE}  {curr_lineno++;}
    \\\n  		{curr_lineno++;}

    /* eat up all characters inside comment  */
    . 			{}
}

 /* Rules for stings */

{QUOTE} {
	string_buf_ptr = string_buf;
	BEGIN(STRING);
}

<STRING>{

    /* Check for closing quote if so append null character and create entry on string table */
	{QUOTE} {
		*string_buf_ptr++ = '\0';
		BEGIN(INITIAL);
		cool_yylval.symbol = stringtable.add_string(string_buf);
		return STR_CONST;
	}

	/* Error on null characters in string */
	{NULL_CHARACTER} {
		cool_yylval.error_msg = "String contains null character";
    	return ERROR;
	}

	/* Increment line on new line but return ERROR */
	{NEW_LINE} {
		curr_lineno++;
		cool_yylval.error_msg = "Unterminated string constant";
		BEGIN(INITIAL);
		return ERROR;			
	}

	/* Return EOF in string error  */
	<<EOF>>	{
		BEGIN(INITIAL);
		cool_yylval.error_msg = "EOF in string constant";
		return ERROR;
	}


	/* Check character escape in string if so take as c and append to string */
	\\c {
	    if(isStringMax()){
		*string_buf_ptr++ = 'c';
	    }else{
		   BEGIN(INITIAL);
		   cool_yylval.error_msg = "String constant too long";
		   return ERROR;
	    }
	}
	
	/* Check tab in string if so take as \t and append to string */
	\\t {
	    if(isStringMax()){
		*string_buf_ptr++ = '\t';
	    }else{
		   BEGIN(INITIAL);
		   cool_yylval.error_msg = "String constant too long";
		   return ERROR;
	    }
	}

	/* Check backspace in string if so take as \b and append to string */
	\\b {
	    if(isStringMax()){
			*string_buf_ptr++ = '\b';
	    }else{
			BEGIN(INITIAL);
			cool_yylval.error_msg = "String constant too long";
			return ERROR;
	    }
	}

	/* Check newline in string if so take as \n and append to string */
	\\n {
	    if(isStringMax()){
			*string_buf_ptr++ = '\n';
	    }else{
			BEGIN(INITIAL);
			cool_yylval.error_msg = "String constant too long";
			return ERROR;
	    }
	}

	/* Check formfeed in string if so take as \f and append to string */
	\\f {
	    if(isStringMax()){
			*string_buf_ptr++ = '\f';
	    }else{
			BEGIN(INITIAL);
			cool_yylval.error_msg = "String constant too long";
			return ERROR;
	    }
	}

	/* Check escaped newline in string if so take as \n and append to string and increment line */
	\\\n {
	    curr_lineno++;

	    if(isStringMax()){
			*string_buf_ptr++ = '\n';
	    }else{
		   	BEGIN(INITIAL);
		   	cool_yylval.error_msg = "String constant too long";
			return ERROR;
	    }
	}

	/* For all other escaped characters append character to string */
	\\. {
	    if(isStringMax()){
			*string_buf_ptr++ = yytext[1];
	    }else{
		   	BEGIN(INITIAL);
		   	cool_yylval.error_msg = "String constant too long";
		   	return ERROR;
	    }
	}

	/* For all other characters append directly to string */
	. {
	    if(isStringMax()){
			*string_buf_ptr++ = yytext[0];
	    }else{
		   	BEGIN(INITIAL);
		   	cool_yylval.error_msg = "String constant too long";
		   	return ERROR;
	    }
	}
}

 /* Whitespaces & other extras  */

 /* Handle multiple newlines */
\n+ {
   curr_lineno += yyleng;
}

 /* remove whitespaces  */ 
[\t\r\f\v ]+ 	{};

 /* Give error for non token elements in code */
. 	{
    cool_yylval.error_msg = yytext;
    return ERROR;
}

%%

/****************************************************************/
/*							User Codes							*/
/****************************************************************/

/* Function that returns boolean on the max string length reached */
bool isStringMax(){
    return (string_buf_ptr+1 < &string_buf[MAX_STR_CONST-1]);
}