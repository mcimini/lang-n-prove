
(* The type of tokens. *)

type token = 
  | VARX
  | VARTERM of (string)
  | VARLEX of (string)
  | VARBIGX
  | VALUEPRED
  | VALUECTX
  | TURNSTYLEA
  | TURNSTYLE
  | SUBTYPINGA
  | SUBTYPING
  | SUBSTBAR
  | STEP
  | RIGHTSQUARE
  | RIGHTPAR
  | PROVIDED
  | MID
  | MEET
  | LEFTSQUARE
  | LEFTPAR
  | JOIN
  | INT of (int)
  | GRAMMARASSIGN
  | GAMMA
  | EXPCTX
  | EOF
  | EMPTYCTX
  | DOT
  | DIRECTIVE
  | COMMA
  | COLON
  | AND

(* This exception is raised by the monolithic API functions. *)

exception Error

(* The monolithic API. *)

val fileLan: (Lexing.lexbuf -> token) -> Lexing.lexbuf -> (Language.language)
