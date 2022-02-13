module foralll.

typeOf (absT R2) (all R) :- (pi x\ typeOf (R2 x) (R x)).

typeOf (appT E X) (R X) :- typeOf E (all R).
step (appT (absT R2) X) (R2 X).
value (absT E1).
step (appT E1 E2) (appT E1' E2) :- step E1 E1'.
step (appT E1 E2) E1 :- error E1.
