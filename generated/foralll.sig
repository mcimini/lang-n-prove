sig foralll.

kind term type.
kind typ type.

kind label type.type all (typ -> typ) -> typ.
type absT (typ -> term) -> term.
type appT term -> typ -> term.

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


