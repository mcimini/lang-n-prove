sig forall_withMoreWithType_cbn.

kind term type.
kind typ type.

kind label type.type arrow typ -> typ -> typ.
type all (typ -> typ) -> typ.
type list typ -> typ.
type bool typ.
type excType typ.
type abs typ -> (term -> term) -> term.
type absT (typ -> term) -> term.
type cons term -> term -> term.
type emptyList term.
type ff term.
type tt term.
type excValue term.
type app term -> term -> term.
type appT term -> typ -> term.
type head term -> term.
type tail term -> term.
type if term -> term -> term -> term.
type letrec typ -> (term -> term) -> (term -> term) -> term.
type let term -> (term -> term) -> term.
type fix term -> term.
type try term -> term -> term.
type raise term -> term.

type value term -> o.

type error term -> o.

type typeOf term -> typ -> o.

type step term -> term -> o.

type nstep term -> term -> o.

