sig stlc_cbv_lists_rightToLeft.

kind term type.
kind typ type.

kind label type.type arrow typ -> typ -> typ.
type list typ -> typ.
type abs typ -> (term -> term) -> term.
type cons term -> term -> term.
type emptyList term.
type app term -> term -> term.
type head term -> term.
type tail term -> term.
type myError term.

type value term -> o.

type error term -> o.

type typeOf term -> typ -> o.

type step term -> term -> o.

type nstep term -> term -> o.

