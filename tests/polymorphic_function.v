Require Import CoqOfOCaml.CoqOfOCaml.
Require Import CoqOfOCaml.Settings.

Definition f_value {A B : Set} (x_value : A) (y_value : B) : A := x_value.

Definition n_value : int := f_value 12 3.
