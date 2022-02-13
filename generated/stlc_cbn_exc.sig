sig stlc_cbn_exc.

kind term type.
kind typ type.

kind label type.type arrow typ -> typ -> typ.
type excType typ.
type abs typ -> (term -> term) -> term.
type excValue term.
type app term -> term -> term.
type try term -> term -> term.
type raise term -> term.

type value term -> o.

type error term -> o.

type typeOf term -> typ -> o.

type step term -> term -> o.

type nstep term -> term -> o.

