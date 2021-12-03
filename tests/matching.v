Require Import CoqOfOCaml.CoqOfOCaml.
Require Import CoqOfOCaml.Settings.

Definition n_value : int :=
  match ([ 1; 2 ], false) with
  | (cons x_value (cons _ []), true) => x_value
  | (cons _ (cons y_value []), false) => y_value
  | _ => 0
  end.

Inductive t : Set :=
| Bar : int -> t
| Foo : bool -> string -> t.

Definition m_value (x_value : t) : int :=
  match
    (x_value,
      (let '_ := x_value in
      equiv_decb 1 2),
      match x_value with
      | Bar n_value => CoqOfOCaml.Stdlib.gt n_value 12
      | _ => false
      end,
      match x_value with
      | Bar k_value => equiv_decb k_value 0
      | _ => false
      end) with
  | (_, true, _, _) => 3
  | (Bar n_value, _, true, _) => n_value
  | (Bar k_value, _, _, true) => k_value
  | (Bar n_value, _, _, _) => Z.opp n_value
  | (Foo _ _, _, _, _) => 0
  end.
