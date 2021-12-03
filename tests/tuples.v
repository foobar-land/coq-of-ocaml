Require Import CoqOfOCaml.CoqOfOCaml.
Require Import CoqOfOCaml.Settings.

Definition t0 : unit := tt.

Definition t1 : ascii * string := ("c" % char, "one").

Definition t2 : int * int * int * bool * bool := (1, 2, 3, false, true).

Definition f_value {A : Set} (x_value : A) : A * A := (x_value, x_value).

Definition t3 : int * int := f_value 12.
