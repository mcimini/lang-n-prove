sig sums_and_pairs_par.

kind term type.
kind typ type.

kind label type.type arrow typ -> typ -> typ.
type sum typ -> typ -> typ.
type times typ -> typ -> typ.
type abs typ -> (term -> term) -> term.
type inr term -> term.
type inl term -> term.
type pair term -> term -> term.
type app term -> term -> term.
type case term -> (term -> term) -> (term -> term) -> term.
type fst term -> term.
type snd term -> term.

type value term -> o.

type error term -> o.

type typeOf term -> typ -> o.

type step term -> term -> o.

type nstep term -> term -> o.

