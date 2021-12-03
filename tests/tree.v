Require Import CoqOfOCaml.CoqOfOCaml.
Require Import CoqOfOCaml.Settings.

Inductive tree : Set :=
| Leaf : tree
| Node : tree -> int -> tree -> tree.

Fixpoint find (x_value : int) (t_value : tree) : bool :=
  match t_value with
  | Leaf => false
  | Node t1 x' t2 =>
    if CoqOfOCaml.Stdlib.lt x_value x' then
      find x_value t1
    else
      if CoqOfOCaml.Stdlib.lt x' x_value then
        find x_value t2
      else
        true
  end.
