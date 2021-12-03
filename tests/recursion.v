Require Import CoqOfOCaml.CoqOfOCaml.
Require Import CoqOfOCaml.Settings.

Fixpoint map {A B : Set} (f_value : A -> B) (l_value : list A) : list B :=
  match l_value with
  | [] => nil
  | cons x_value xs => cons (f_value x_value) (map f_value xs)
  end.

Fixpoint fold {A B : Set}
  (f_value : A -> B -> A) (a_value : A) (l_value : list B) : A :=
  match l_value with
  | [] => a_value
  | cons x_value xs => fold f_value (f_value a_value x_value) xs
  end.

Definition l_value : list int := [ 5; 6; 7; 2 ].

Definition n_value {A : Set} (incr : int -> A) (plus : int -> A -> int) : int :=
  fold (fun (x_value : int) => fun (y_value : A) => plus x_value y_value) 0
    (map incr l_value).
