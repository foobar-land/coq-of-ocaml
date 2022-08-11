Require Import CoqOfOCaml.Libraries.
Require Import CoqOfOCaml.Settings.
Require Import CoqOfOCaml.Basics.
Require CoqOfOCaml.Char.

Definition length (s : string) : Z :=
  Z.of_nat (String.length s).

(* TODO: raise an exception if n < 0. *)
Definition get (s : string) (n : Z) : ascii :=
  match String.get (Z.to_nat n) s with
  | None => "?" % char
  | Some c => c
  end.

Fixpoint _make (n : nat) (c : ascii) : string :=
  match n with
  | O => EmptyString
  | S n => String c (_make n c)
  end.

Fixpoint concat (sep : string) (sl : list string) : string :=
  match sl with
  | [] => ""
  | [s] => s
  | s :: sl => String.append (String.append s sep) (concat sep sl)
  end.

(* TODO: raise an exception if n < 0. *)
Definition make (n : Z) (c : ascii) : string :=
  _make (Z.to_nat n) c.

(* TODO *)
Definition sub (s : string) (start : Z) (length : Z) : string :=
  s.

(* TODO *)
Definition escaped (s : string) : string :=
  s.

Module Lt.
  Inductive t : string -> string -> Prop :=
  | EmptyString : forall c s, t EmptyString (String c s)
  | StringStringLt : forall c1 s1 c2 s2,
    N.lt (N_of_ascii c1) (N_of_ascii c2) -> t (String c1 s1) (String c2 s2)
  | StringStringEq : forall c1 s1 c2 s2,
    c1 = c2 -> t s1 s2 -> t (String c1 s1) (String c2 s2).

  Fixpoint irreflexivity (s : string) (H : t s s) : False.
    inversion_clear H.
    - apply (Char.Lt.irreflexivity _ H0).
    - apply (irreflexivity _ H1).
  Qed.

  Fixpoint transitivity (s1 s2 s3 : string) (H12 : t s1 s2) (H23 : t s2 s3) : t s1 s3.
    inversion H12; inversion H23; try apply EmptyString; try congruence.
    - apply StringStringLt.
      apply N.lt_trans with (m := N_of_ascii c2); congruence.
    - apply StringStringLt; congruence.
    - apply StringStringLt; congruence.
    - apply StringStringEq; try congruence.
      replace s4 with s5 in * by congruence.
      now apply transitivity with (s2 := s5).
  Qed.
End Lt.

Fixpoint ltb (s1 s2 : string) : bool :=
  match s1, s2 with
  | EmptyString, EmptyString => false
  | EmptyString, String _ _ => true
  | String _ _, EmptyString => false
  | String c1 s1', String c2 s2' =>
  let n1 := N_of_ascii c1 in
  let n2 := N_of_ascii c2 in
  (N.ltb n1 n2 || (N.eqb n1 n2 && ltb s1' s2')) % bool
  end.

Fixpoint ltb_spec (s1 s2 : string) : Bool.reflect (Lt.t s1 s2) (ltb s1 s2).
  destruct s1 as [| c1 s1]; destruct s2 as [| c2 s2]; simpl.
  - apply Bool.ReflectF.
    intro; now apply Lt.irreflexivity with (s := "" % string).
  - apply Bool.ReflectT.
    apply Lt.EmptyString.
  - apply Bool.ReflectF.
    intro H; inversion H.
  - case_eq ((N_of_ascii c1 <? N_of_ascii c2)%N); intro H_lt; simpl.
    + apply Bool.ReflectT.
      apply Lt.StringStringLt.
      now apply N.ltb_lt.
    + case_eq ((N_of_ascii c1 =? N_of_ascii c2)%N); intro H_eq; simpl.
      * destruct (ltb_spec s1 s2); constructor.
        -- apply Lt.StringStringEq; trivial.
            apply Char.Lt.N_of_ascii_inj.
            now apply N.eqb_eq.
        -- intro H; inversion H; try tauto.
            assert ((N_of_ascii c1 <? N_of_ascii c2)%N = true) by
              now apply N.ltb_lt.
            congruence.
      * apply Bool.ReflectF.
        intro H; inversion H.
        -- assert ((N_of_ascii c1 <? N_of_ascii c2)%N = true) by
              now apply N.ltb_lt.
            congruence.
        -- assert ((N_of_ascii c1 =? N_of_ascii c2)%N = true) by
              (apply N.eqb_eq; congruence).
            congruence.
Qed.

Fixpoint ltb_or_eqb_or_gtb
  (s1 s2 : string)
  (H_nltb : ltb s1 s2 = false)
  (H_neqb : String.eqb s1 s2 = false)
  : ltb s2 s1 = true.
  destruct s1 as [| c1 s1]; destruct s2 as [| c2 s2]; simpl in *; try congruence.
  destruct (Bool.orb_false_elim _ _ H_nltb) as [H_c1c2 H].
  case_eq ((N_of_ascii c1 ?= N_of_ascii c2)%N); intro H_comp_c1c2.
  - assert (H_eq_c1c2 : N_of_ascii c1 = N_of_ascii c2) by
      now apply N.compare_eq_iff.
    replace ((N_of_ascii c2 =? N_of_ascii c1)%N) with true by (
      symmetry;
      apply N.eqb_eq;
      congruence
    ).
    rewrite ltb_or_eqb_or_gtb.
    + apply Bool.orb_true_r.
    + destruct (proj1 (Bool.andb_false_iff _ _) H); trivial.
      assert (H_eq_c1c2_bis := proj2 (N.eqb_eq _ _) H_eq_c1c2).
      congruence.
    + assert (H_eqb_c1c2 : (c1 =? c2)%char = true) by (
        apply Ascii.eqb_eq;
        now apply Char.Lt.N_of_ascii_inj
      ).
      now rewrite H_eqb_c1c2 in H_neqb.
  - assert ((N_of_ascii c1 <? N_of_ascii c2)%N = true) by (
      apply N.ltb_lt;
      now apply N.compare_lt_iff
    ).
    congruence.
  - assert (H_gt_c1c2 : (N_of_ascii c2 < N_of_ascii c1) % N) by
      now apply N.compare_gt_iff.
    now rewrite (proj2 (N.ltb_lt _ _) H_gt_c1c2).
Qed.

#[global]
Instance strict_order : StrictOrder Lt.t := {|
    StrictOrder_Irreflexive := Lt.irreflexivity;
    StrictOrder_Transitive := Lt.transitivity;
  |}.

#[global]
Instance order_dec : OrderDec strict_order.
  refine {|
    compare := fun s1 s2 =>
      if String.eqb s1 s2 then
        Eq
      else if ltb s1 s2 then
        Lt
      else
        Gt;
    compare_is_sound := fun s1 s2 => _;
  |}.
  case_eq (String.eqb s1 s2); intro H_eq.
  - apply CompEq.
    now apply String.eqb_eq.
  - case_eq (ltb s1 s2); intro H_lt.
    + apply CompLt.
      admit.
    + apply CompGt.
      admit.
Admitted.
