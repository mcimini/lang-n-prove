sig recursive_withMore_cbv.

kind term type.
kind typ type.

kind label type.type arrow typ -> typ -> typ.
type mu (typ -> typ) -> typ.
type list typ -> typ.
type bool typ.
type excType typ.
type abs (term -> term) -> term.
type fold term -> (typ -> typ) -> term.
type cons term -> term -> term.
type emptyList term.
type ff term.
type tt term.
type excValue term.
type app term -> term -> term.
type unfold term -> term.
type head term -> term.
type tail term -> term.
type if term -> term -> term -> term.
type letrec (term -> term) -> (term -> term) -> term.
type fix term -> term.
type try term -> term -> term.
type raise term -> term.

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
