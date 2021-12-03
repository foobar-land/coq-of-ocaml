Require Import CoqOfOCaml.CoqOfOCaml.
Require Import CoqOfOCaml.Settings.

Definition f_value (x_value : int) : int := Z.add (cast int x_value) 1.

Inductive t : Set :=
| Int : t.

Definition g_value {a : Set} (kind : t) (x_value : a) : int :=
  let 'Int := kind in
  Z.add (cast int x_value) 1.
