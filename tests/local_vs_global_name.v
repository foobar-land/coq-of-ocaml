Require Import CoqOfOCaml.CoqOfOCaml.
Require Import CoqOfOCaml.Settings.

Module M.
  Definition b_value : bool := false.
  
  Definition n_value : int := 12.
End M.

Definition n_value : int := Z.add M.n_value 2.
