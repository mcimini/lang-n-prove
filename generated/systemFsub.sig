sig systemFsub.

kind term type.
kind typ type.

kind label type.type arrow typ -> typ -> typ.
type all typ -> (typ -> typ) -> typ.
type top typ.
type abs typ -> (term -> term) -> term.
type absT typ -> (typ -> term) -> term.
type topObj term.
type app term -> term -> term.
type appT term -> typ -> term.

type value term -> o.

type error term -> o.

type typeOf term -> typ -> o.

type step term -> term -> o.

type nstep term -> term -> o.

type subtype typ -> typ -> o.
