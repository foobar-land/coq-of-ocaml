Require Import CoqOfOCaml.CoqOfOCaml.
Require Import CoqOfOCaml.Settings.

Definition n1 : int :=
  let m_value := 12 in
  let n1 := (m_value : int) in
  n1.

Definition n2 : int :=
  let p1 {A B C : Set} (c_value : (A -> B -> A) -> C) : C :=
    c_value (fun (x_value : A) => fun (y_value : B) => x_value) in
  let c_value {A : Set} (f_value : int -> int -> A) : A :=
    f_value 12 23 in
  p1 c_value.
