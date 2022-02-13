module stlc_lists_range.

typeOf (abs T1 R) (arrow T1 T2) :- (pi x\ typeOf x T1 => typeOf (R x) T2).

typeOf (zero) (int).

typeOf (succ E) (int) :- typeOf E (int).

typeOf (tt) (bool).

typeOf (ff) (bool).

typeOf (emptyList) (list T).

typeOf (cons E1 E2) (list T) :- typeOf E1 T, typeOf E2 (list T).

typeOf (app E1 E2) T2 :- typeOf E1 (arrow T1 T2), typeOf E2 T1.

typeOf (pred E) (int) :- typeOf E (int).

typeOf (isZero E) (bool) :- typeOf E (int).

typeOf (if E1 E2 E3) T :- typeOf E1 (bool), typeOf E2 T, typeOf E3 T.

typeOf (head E) T :- typeOf E (list T).

typeOf (tail E) (list T) :- typeOf E (list T).

typeOf (fix E) T :- typeOf E (arrow T T).

typeOf (let E R) T2 :- typeOf E T1, (pi x\ typeOf x T1 => typeOf (R x) T2).

typeOf (letrec T1 R1 R2) T2 :- (pi x\ typeOf x T1 => typeOf (R1 x) T1), (pi x\ typeOf x T1 => typeOf (R2 x) T2).

typeOf (myerror) T.

typeOf (reverseRange E) (list (int)) :- typeOf E (int).

typeOf (range E) (list (int)) :- typeOf E (int).

typeOf (reverse E) (list T) :- typeOf E (list T).

typeOf (append E1 E2) (list T) :- typeOf E1 (list T), typeOf E2 (list T).
step (reverseRange (zero)) (emptyList).

step (reverseRange (succ V)) (cons (succ V) (reverseRange V)).

step (range V) (reverse (reverseRange V)).

step (reverse (emptyList)) (emptyList).

step (reverse (cons V1 V2)) (append (reverse V2) (cons V1 (emptyList))).

step (append (emptyList) V) V.

step (append (cons V1 V2) V3) (cons V1 (append V2 V3)).

step (app (abs T R) V) (R V) :- value V.

step (let V R) (R V) :- value V.

step (pred (zero)) (myerror).

step (pred (succ E)) E.

step (isZero (zero)) (tt).

step (isZero (succ E)) (ff).

step (if (tt) E1 E2) E1.

step (if (ff) E1 E2) E2.

step (head (emptyList)) (myerror).

step (head (cons E1 E2)) E1.

step (tail (emptyList)) (myerror).

step (tail (cons E1 E2)) E2.

step (fix E) (app E (fix E)) :- value E.

step (letrec T1 R1 R2) (R2 (fix (abs T1 R1))).
value (abs E1 E2).

value (zero).

value (succ E1) :- value E1.

value (tt).

value (ff).

value (emptyList).

value (cons E1 E2) :- value E2, value E1.
error (myerror).
step (succ E1) (succ E1') :- step E1 E1'.

step (cons E1 E2) (cons E1' E2) :- step E1 E1'.

step (cons E1 E2) (cons E1 E2') :- step E2 E2', value E1.

step (app E1 E2) (app E1' E2) :- step E1 E1'.

step (app E1 E2) (app E1 E2') :- step E2 E2', value E1.

step (pred E1) (pred E1') :- step E1 E1'.

step (isZero E1) (isZero E1') :- step E1 E1'.

step (if E1 E2 E3) (if E1' E2 E3) :- step E1 E1'.

step (head E1) (head E1') :- step E1 E1'.

step (tail E1) (tail E1') :- step E1 E1'.

step (let E1 E2) (let E1' E2) :- step E1 E1'.

step (fix E1) (fix E1') :- step E1 E1'.

step (range E1) (range E1') :- step E1 E1'.

step (reverse E1) (reverse E1') :- step E1 E1'.

step (reverseRange E1) (reverseRange E1') :- step E1 E1'.

step (append E1 E2) (append E1' E2) :- step E1 E1'.

step (append E1 E2) (append E1 E2') :- step E2 E2', value E1.
step (succ E1) E1 :- error E1.

step (cons E1 E2) E1 :- error E1.

step (cons E1 E2) E2 :- error E2, value E1.

step (app E1 E2) E1 :- error E1.

step (app E1 E2) E2 :- error E2, value E1.

step (pred E1) E1 :- error E1.

step (isZero E1) E1 :- error E1.

step (if E1 E2 E3) E1 :- error E1.

step (head E1) E1 :- error E1.

step (tail E1) E1 :- error E1.

step (let E1 E2) E1 :- error E1.

step (fix E1) E1 :- error E1.

step (range E1) E1 :- error E1.

step (reverse E1) E1 :- error E1.

step (reverseRange E1) E1 :- error E1.

step (append E1 E2) E1 :- error E1.

step (append E1 E2) E2 :- error E2, value E1.
