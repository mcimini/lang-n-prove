sig stlc_par_recursive.

kind term type.
kind typ type.

kind label type.type arrow typ -> typ -> typ.
type mu (typ -> typ) -> typ.
type abs typ -> (term -> term) -> term.
type fold term -> (typ -> typ) -> term.
type app term -> term -> term.
type unfold term -> term.

type value term -> o.

type error term -> o.


type step term -> term -> o.

type nstep term -> term -> o.

kind tenv type. type empty tenv.
type consEnv term -> typ -> tenv -> tenv. 

type typeOf tenv -> term -> typ -> o.
type typeOfA tenv -> term -> typ -> o.
type subtypeA typ -> typ -> o.
type subtype typ -> typ -> o.
type join typ -> typ ->  typ -> o.
type meet typ -> typ ->  typ -> o.


