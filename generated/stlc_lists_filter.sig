sig stlc_lists_filter.

kind term type.
kind typ type.

kind label type.type arrow typ -> typ -> typ.
type int typ.
type bool typ.
type list typ -> typ.
type abs typ -> (term -> term) -> term.
type succ term -> term.
type zero term.
type ff term.
type tt term.
type cons term -> term -> term.
type emptyList term. 
type app term -> term -> term.
type pred term -> term.
type isZero term -> term.
type if term -> term -> term -> term.
type filter term -> term -> term.
type head term -> term.
type tail term -> term.
type letrec typ -> (term -> term) -> (term -> term) -> term.
type fix term -> term.
type let term -> (term -> term) -> term.
type myerror term.

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
