Require Import CoqOfOCaml.CoqOfOCaml.
Require Import CoqOfOCaml.Settings.

Module M.
  Definition n_value : int := 12.
End M.

Module N.
  Definition n_value : bool := true.
  
  Definition x_value : bool := n_value.
  
  Definition y_value : int := M.n_value.
End N.

Definition b_value : bool := N.n_value.

Definition b' : bool := N.n_value.
