sig stlc_cbv_fix.

kind term type.
kind typ type.

kind label type.type arrow typ -> typ -> typ.
type abs typ -> (term -> term) -> term.
type app term -> term -> term.
type fix term -> term.

type value term -> o.

type error term -> o.

type typeOf term -> typ -> o.

type step term -> term -> o.

type nstep term -> term -> o.

