{
  open Lexing
  open Parser
  exception Error of string


let next_line lexbuf =
  let pos = lexbuf.lex_curr_p in
  lexbuf.lex_curr_p <-
    { pos with pos_bol = lexbuf.lex_curr_pos;
               pos_lnum = pos.pos_lnum + 1
    }

}

let var = ['a'-'z']['a'-'z' 'A'-'Z' '0'-'9' '-']*
let name = ['A'-'Z']['a'-'z' 'A'-'Z' '0'-'9' '-']*

rule token = parse
    [' ' '\t']  { token lexbuf }
  | ['\r' '\n']  { next_line lexbuf; token lexbuf }
  | "for"               { FOR }
  | "each"               { EACH }
  | "in"           { IN }
  | "inn"           { INN }
  | ","               { COMMA }
  | "Theorem"               { THEOREM }
  | "_"            { UNDERSCORE }
  | "("             { LPAREN }
  | ")"             { RPAREN }
  | "["             { LSQUARE }
  | "]"             { RSQUARE }
  | ":"               { COLON }
  | "forall*"              { FORALLSTAR }
  | "forall"               { FORALL }
  | "."               { DOT }
  | "premises"        { PREMISES }
  | "rule"            { RULE }
  | "<:" { SUBTYPING }
  | "|-" { TURNSTYLE }
  | "-->" { STEP }
  | "forallVars"               { FORALLVARS }
  | "->"            { IMPLY }
  | "OR"               { ORMACRO }
  | "existsVars"               { EXISTSVARS }
  | "="             { EQUAL }
  | "/\\"            { AND }
  | "AND"               { ANDMACRO }
  | "valuesOf"           { VALUESOF }
  | "valueArgs"           { VALUEARGS }
  | "ofType"           { OFTYPE }
  | "isSingleValue"           { ISSINGLEVALUE }
  | "targetsFromValue"           { TARGETV }
  | "targetsFromOp"           { TARGETOP }
  | "containsSubstitution"           { CONTAINSSUB }
  | "IMPLY"               { IMPLYMACRO }
  | "evaluationOrder"           { EVALORDER } 
  | "contextualArgs"           { CONTEXTARGS } 
  | "getArgs"           { GETARGS }
  | "Proof"           { PROOF }
  | "intros"             { INTROS }
  | "search"            { SEARCH }
  | "case"            { CASE }
  | "case*"            { CASESTAR }
  | "if"            { IF }
  | "then"            { THEN }
  | "else"            { ELSE }
  | "noOp"            { NOP }
  | "exists*"               { EXISTSTAR }
  | "exists"               { EXISTS }
  | "induction"            { INDUCTION }
  | "induction*"            { INDUCTIONSTAR }
  | "on"             { ON }
  | "endfor"               { ENDFOR }
  | "apply"             { APPLY }
  | "to"             { TO }
  | "backchain"             { BACKCHAIN }
  | "isEliminationForm"           { ISELIM }
  | "isDerived"           { ISDERIVED }
  | "isErrorHandler"           { ISERRORHANDLER }
  | "getArgType"           { GETARGTYPE }
  | "\\/"            { OR }
  | "exists"               { EXISTS }
  | "isVar"               { ISVAR }
  | "is"               { IS }
  | "or"               { ORTERM }
  | "and"               { ANDTERM }
  | "endOR"               { ENDOR }
  | "endAND"               { ENDAND }
  | "endIMPLY"               { ENDIMPLY }
  | "endif"               { ENDIF }
  | "skip"               { SKIP }
  | "let"       { LET }
  | "align"     { ALIGN }
  | "where"     { WHERE }
  | "append"    { APPEND }
  | "targetOfElimForm" { TARGETOFELIMFORM }
  | "targetOfErrorHandler" { TARGETOFERRORHANDLER }
  | var             { VAR (Lexing.lexeme lexbuf) }
  | name             { NAME (Lexing.lexeme lexbuf) }
  | ['0'-'9']+ as i { INT (int_of_string i) }  
  | eof             { EOF }
  | _
	    { raise (Error (Printf.sprintf "At offset %d: unexpected character %s.\n" (Lexing.lexeme_start lexbuf) (Lexing.lexeme lexbuf))) }
{
}
