Require Import String ZArith Lia.
From Equations Require Import Equations.
Set Equations Transparent.

Derive NoConfusion EqDec for Strings.Ascii.ascii string positive Z.

Declare Scope metacoq_scope.

(** We cannot use ssrbool currently as it breaks extraction. *)
Coercion is_true : bool >-> Sortclass.

Notation "'eta_compose'" := (fun g f x => g (f x)).

(* \circ *)
Notation "g ∘ f" := (eta_compose g f) (at level 40, left associativity).

Notation " ! " := (@False_rect _ _) : metacoq_scope.

(* Use \sum to input ∑ in Company Coq (it is not a sigma Σ). *)
Notation "'∑' x .. y , p" := (sigT (fun x => .. (sigT (fun y => p%type)) ..))
  (at level 200, x binder, right associativity,
   format "'[' '∑'  '/  ' x  ..  y ,  '/  ' p ']'")
  : type_scope.

Notation "( x ; y )" := (@existT _ _ x y).
Notation "( x ; y ; z )" := (x ; ( y ; z)).
Notation "( x ; y ; z ; t )" := (x ; ( y ; (z ; t))).
Notation "( x ; y ; z ; t ; u )" := (x ; ( y ; (z ; (t ; u)))).
Notation "( x ; y ; z ; t ; u ; v )" := (x ; ( y ; (z ; (t ; (u ; v))))).
Notation "x .π1" := (@projT1 _ _ x) (at level 3, format "x '.π1'").
Notation "x .π2" := (@projT2 _ _ x) (at level 3, format "x '.π2'").

Create HintDb terms.

Ltac arith_congr := repeat (try lia; progress f_equal).

Ltac easy0 :=
  let rec use_hyp H :=
   (match type of H with
    | _ /\ _ => exact H || destruct_hyp H
    | _ * _ => exact H || destruct_hyp H
    | _ => try (solve [ inversion H ])
    end)
  with do_intro := (let H := fresh in
                    intro H; use_hyp H)
  with destruct_hyp H := (case H; clear H; do_intro; do_intro)
  in
  let rec use_hyps :=
   (match goal with
    | H:_ /\ _ |- _ => exact H || (destruct_hyp H; use_hyps)
    | H:_ * _ |- _ => exact H || (destruct_hyp H; use_hyps)
    | H:_ |- _ => solve [ inversion H ]
    | _ => idtac
    end)
  in
  let do_atom := (solve [ trivial with eq_true | reflexivity | symmetry; trivial | contradiction | congruence]) in
  let rec do_ccl := (try do_atom; repeat (do_intro; try do_atom); try arith_congr; (solve [ split; do_ccl ])) in
  (solve [ do_atom | use_hyps; do_ccl ]) || fail "Cannot solve this goal".

Hint Extern 10 (_ < _)%nat => lia : terms.
Hint Extern 10 (_ <= _)%nat => lia : terms.
Hint Extern 10 (@eq nat _ _) => lia : terms.

Ltac easy ::= easy0 || solve [intuition eauto 3 with core terms].

Ltac inv H := inversion_clear H.
