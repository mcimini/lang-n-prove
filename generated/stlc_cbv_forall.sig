sig stlc_cbv_forall.

kind term type.
kind typ type.

kind label type.type arrow typ -> typ -> typ.
type all (typ -> typ) -> typ.
type abs typ -> (term -> term) -> term.
type absT (typ -> term) -> term.
type app term -> term -> term.
type appT term -> typ -> term.

type value term -> o.

type error term -> o.

type typeOf term -> typ -> o.

type step term -> term -> o.

type nstep term -> term -> o.

