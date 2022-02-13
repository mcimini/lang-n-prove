sig foralll.

kind term type.
kind typ type.

kind label type.type all (typ -> typ) -> typ.
type absT (typ -> term) -> term.
type appT term -> typ -> term.

type value term -> o.

type error term -> o.

type typeOf term -> typ -> o.

type step term -> term -> o.

type nstep term -> term -> o.

