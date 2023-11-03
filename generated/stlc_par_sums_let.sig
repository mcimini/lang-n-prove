sig stlc_par_sums_let.

kind term type.
kind typ type.

kind label type.type arrow typ -> typ -> typ.
type sum typ -> typ -> typ.
type abs typ -> (term -> term) -> term.
type inr term -> term.
type inl term -> term.
type app term -> term -> term.
type case term -> (term -> term) -> (term -> term) -> term.
type let term -> (term -> term) -> term.

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

type top typ.
