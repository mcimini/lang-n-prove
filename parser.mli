
(* The type of tokens. *)

type token = 
  | WITH
  | WHERE
  | VARSOF
  | VAR of (string)
  | VALUESOF
  | VALUEARGS
  | UNDERSCORE
  | TURNSTYLEA
  | TURNSTYLE
  | TO
  | THEOREM
  | THEN
  | TARGETV
  | TARGETOP
  | TARGETOFERRORHANDLER
  | TARGETOFELIMFORM
  | SUBTYPINGA
  | SUBTYPING
  | STEP
  | SKIP
  | SECOND
  | SEARCH
  | RULE
  | RSQUARE
  | RPAREN
  | REVERSEIMPLY
  | PROOF
  | PREMISESIDX
  | PREMISES
  | ORTERM
  | ORMACRO
  | OR
  | ON
  | OFTYPE
  | NOP
  | NAME of (string)
  | MUTUAL
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
  | FIRST
  | FIND
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
  | COVARIANT
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
