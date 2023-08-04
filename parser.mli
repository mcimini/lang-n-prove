
(* The type of tokens. *)

type token = 
  | WHERE
  | VAR of (string)
  | VALUESOF
  | VALUEARGS
  | UNDERSCORE
  | TURNSTYLE
  | TO
  | THEOREM
  | THEN
  | TARGETV
  | TARGETOP
  | TARGETOFERRORHANDLER
  | TARGETOFELIMFORM
  | SUBTYPING
  | STEP
  | SKIP
  | SEARCH
  | RULE
  | RSQUARE
  | RPAREN
  | PROOF
  | PREMISES
  | ORTERM
  | ORMACRO
  | OR
  | ON
  | OFTYPE
  | NOP
  | NAME of (string)
  | LSQUARE
  | LPAREN
  | LET
  | ISVAR
  | ISSINGLEVALUE
  | ISERRORHANDLER
  | ISELIM
  | ISDERIVED
  | IS
  | INTROS
  | INT of (int)
  | INN
  | INDUCTIONSTAR
  | INDUCTION
  | IN
  | IMPLYMACRO
  | IMPLY
  | IF
  | GETARGTYPE
  | GETARGS
  | FORALLVARS
  | FORALLSTAR
  | FORALL
  | FOR
  | EXISTSVARS
  | EXISTSTAR
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
  | APPEND
  | ANDTERM
  | ANDMACRO
  | AND
  | ALIGN

(* This exception is raised by the monolithic API functions. *)

exception Error

(* The monolithic API. *)

val mystring: (Lexing.lexbuf -> token) -> Lexing.lexbuf -> (Lnp.schema)

val file: (Lexing.lexbuf -> token) -> Lexing.lexbuf -> (Lnp.schema)
