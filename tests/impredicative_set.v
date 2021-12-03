Require Import CoqOfOCaml.CoqOfOCaml.
Require Import CoqOfOCaml.Settings.

Inductive t : Set :=
| Empty : t
| Node : forall {a : Set}, a -> t.

Fixpoint t_of_list {a : Set} (l_value : list a) : t :=
  match l_value with
  | [] => Empty
  | cons _ l_value => Node (t_of_list l_value)
  end.
