sig listsIsNil.

kind term type.
kind typ type.

kind label type.type list typ -> typ.
type bool typ.
type cons term -> term -> term.
type emptyList term.
type ff term.
type tt term.
type head term -> term.
type tail term -> term.
type isnil term -> term.
type if term -> term -> term -> term.
type myError term.

type value term -> o.

type error term -> o.

type typeOf term -> typ -> o.

type step term -> term -> o.

type nstep term -> term -> o.

