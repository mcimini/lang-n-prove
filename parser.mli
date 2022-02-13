
(* The type of tokens. *)

type token = 
  | VAR of (string)
  | VALUESOF
  | VALUEARGS
  | UNDERSCORE
  | TO
  | THEOREM
  | THEN
  | TARGETV
  | TARGETOP
  | SKIP
  | SEARCH
  | RPAREN
  | PROOF
  | ORTERM
  | ORMACRO
  | OR
  | ON
  | OFTYPE
  | NOP
  | NAME of (string)
  | LPAREN
  | ISVAR
  | ISSINGLEVALUE
  | ISERRORHANDLER
  | ISELIM
  | ISDERIVED
  | IS
  | INTROS
  | INT of (int)
  | INDUCTIONSTAR
  | INDUCTION
  | IN
  | IMPLYMACRO
  | IMPLY
  | IF
  | GETARGTYPE
  | GETARGS
  | FORALLVARS
  | FORALL
  | FOR
  | EXISTSVARS
  | EXISTS
  | EVALORDER
  | EQUAL
  | EOF
  | ENDOR
  | ENDIMPLY
  | ENDIF
  | ENDFOR
  | ENDAND
  | ELSE
  | EACH
  | DOT
  | CONTEXTARGS
  | CONTAINSSUB
  | COMMA
  | COLON
  | CASESTAR
  | CASE
  | BACKCHAIN
  | APPLY
  | ANDTERM
  | ANDMACRO
  | AND

(* This exception is raised by the monolithic API functions. *)

exception Error

(* The monolithic API. *)

val mystring: (Lexing.lexbuf -> token) -> Lexing.lexbuf -> (Lnp.schema)

val file: (Lexing.lexbuf -> token) -> Lexing.lexbuf -> (Lnp.schema)
