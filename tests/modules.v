Require Import CoqOfOCaml.CoqOfOCaml.
Require Import CoqOfOCaml.Settings.

Module List2.
  Inductive t (a : Set) : Set :=
  | Nil : t a
  | Cons : a -> t a -> t a.
  
  Arguments Nil {_}.
  Arguments Cons {_}.
  
  Fixpoint sum (l_value : t int) : int :=
    match l_value with
    | Nil => 0
    | Cons x_value xs => Z.add x_value (sum xs)
    end.
  
  Fixpoint of_list {A : Set} (function_parameter : list A) : t A :=
    match function_parameter with
    | [] => Nil
    | cons x_value xs => Cons x_value (of_list xs)
    end.
  
  Module Inside.
    Definition x_value : int := 12.
  End Inside.
End List2.

Definition n_value {A : Set} (function_parameter : A) : int :=
  let '_ := function_parameter in
  List2.sum (List2.of_list [ 5; 7; 6; List2.Inside.x_value ]).

Module Syn := List2.Inside.

Definition xx : int := Syn.x_value.
