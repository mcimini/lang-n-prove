sig lambdaBoolListLetExc.

kind term type.
kind typ type.

kind label type.type times typ -> typ -> typ.
type arrow typ -> typ -> typ.
type int typ.
type bool typ.
type sum typ -> typ -> typ.
type list typ -> typ.
type all (typ -> typ) -> typ.
type mu (typ -> typ) -> typ.
type pair term -> term -> term.
type abs typ -> (term -> term) -> term.
type succ term -> term.
type zero term.
type ff term.
type tt term.
type inr term -> term.
type inl term -> term.
type cons term -> term -> term.
type emptyList term.
type absT (typ -> term) -> term.
type fold term -> (typ -> typ) -> term.
type fst term -> term.
type snd term -> term.
type app term -> term -> term.
type pred term -> term.
type if term -> term -> term -> term.
type case term -> (term -> term) -> (term -> term) -> term.
type head term -> term.
type tail term -> term.
type appT term -> typ -> term.
type unfold term -> term.
type let term -> (term -> term) -> term.
type letrec typ -> (term -> term) -> (term -> term) -> term.
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
