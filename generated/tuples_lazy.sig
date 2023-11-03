sig tuples_lazy.

kind term type.
kind typ type.

kind label type.type times5 typ -> typ -> typ -> typ -> typ -> typ.
type tuple5 term -> term -> term -> term -> term -> term.
type select1 term -> term.
type select2 term -> term.
type select3 term -> term.
type select4 term -> term.
type select5 term -> term.

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
