Require Import CoqOfOCaml.CoqOfOCaml.
Require Import CoqOfOCaml.Settings.

Module Notations.
  Definition keep_same {A : Set} (x_value : A) : A := x_value.
  
  Definition op_plus (s1 : string) (s2 : string) : string :=
    String.append s1 s2.
End Notations.

Definition concat (s1 : string) (s2 : string) : string :=
  Notations.keep_same (Notations.op_plus s1 s2).
