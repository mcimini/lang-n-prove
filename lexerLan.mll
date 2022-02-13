{
  open Lexing 
  open ParserLan
  exception Error of string

let next_line lexbuf =
  let pos = lexbuf.lex_curr_p in
  lexbuf.lex_curr_p <-
    { pos with pos_bol = lexbuf.lex_curr_pos;
               pos_lnum = pos.pos_lnum + 1
    }

}

let idLOW = ['a'-'z']['a'-'z' 'A'-'Z' '0'-'9' '_' '-' ''']*
let idUP = ['A'-'Z']['a'-'z' 'A'-'Z' '0'-'9' '_' '-' ''']*

rule token = parse
    [' ' '\t']  { token lexbuf }
  | ['\r' '\n']  { next_line lexbuf; token lexbuf }
  | ['0'-'9']+           { INT (int_of_string(Lexing.lexeme lexbuf)) }
  | "x" { VARX }
  | "X" { VARBIGX }
  | "-->" { STEP }
  | "v" { VALUECTX }
  | "e" { EXPCTX }
  | "::=" { GRAMMARASSIGN }
  | "|" { MID }
  | "[]" { EMPTYCTX }
  | "Gamma" { GAMMA }
  | "|-" { TURNSTYLE }
  | ":" { COLON }
  | "(" { LEFTPAR }
  | ")" { RIGHTPAR }
  | "<==" { PROVIDED }
  | "," { COMMA }
  | "/\\"            { AND }
  | "." { DOT }
  | "[" { LEFTSQUARE }
  | "]" { RIGHTSQUARE }
  | "/" { SUBSTBAR }
  | "value" { VALUEPRED }
  | "%" { DIRECTIVE }
  | "<:" { SUBTYPING }
  | idLOW             { VARLEX (Lexing.lexeme lexbuf) }
  | idUP             { VARTERM (Lexing.lexeme lexbuf) }
  | eof             { EOF }
  | _
	    { raise (Error (Printf.sprintf "At offset %d: unexpected character %s.\n" (Lexing.lexeme_start lexbuf) (Lexing.lexeme lexbuf))) }
{
}