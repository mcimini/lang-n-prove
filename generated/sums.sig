sig sums.

kind term type.
kind typ type.

kind label type.type sum typ -> typ -> typ.
type inr term -> term.
type inl term -> term.
type case term -> (term -> term) -> (term -> term) -> term.

type value term -> o.

type error term -> o.

type typeOf term -> typ -> o.

type step term -> term -> o.

type nstep term -> term -> o.

