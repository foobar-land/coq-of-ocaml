Require Import CoqOfOCaml.CoqOfOCaml.
Require Import CoqOfOCaml.Settings.

Definition n_value : int := 12.

Definition c1 : ascii := "a" % char.

Definition c2 : ascii := "010" % char.

Definition c3 : ascii := "009" % char.

Definition c4 : ascii := """" % char.

Definition s_value : string := "hi\n\t:)\""".

Definition b1 : bool := false.

Definition b2 : bool := true.

Definition u_value : unit := tt.

Definition l1 {A : Set} : list A := nil.

Definition l2 : list int := [ 0; 1; 2; 3 ].

Definition o_value : option int :=
  if b1 then
    None
  else
    Some n_value.
