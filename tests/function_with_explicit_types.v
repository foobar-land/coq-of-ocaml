Require Import CoqOfOCaml.CoqOfOCaml.
Require Import CoqOfOCaml.Settings.

Definition f_value (n_value : int) (b_value : bool) : int :=
  if b_value then
    Z.add n_value 1
  else
    Z.sub n_value 1.

Definition id {a : Set} (x_value : a) : a := x_value.
