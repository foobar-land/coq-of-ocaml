(** Generated by coq-of-ocaml *)
Require Import OCaml.OCaml.

Local Open Scope string_scope.
Local Open Scope Z_scope.
Local Open Scope type_scope.
Import ListNotations.

Unset Positivity Checking.
Unset Guard Checking.

Require Import Tezos.Environment.
Import Notations.
Require Tezos.Period_repr.

Parameter t : Set.

Parameter op_eq : t -> t -> bool.

Parameter op_ltgt : t -> t -> bool.

Parameter op_lt : t -> t -> bool.

Parameter op_lteq : t -> t -> bool.

Parameter op_gteq : t -> t -> bool.

Parameter op_gt : t -> t -> bool.

Parameter compare : t -> t -> Z.

Parameter equal : t -> t -> bool.

Parameter max : t -> t -> t.

Parameter min : t -> t -> t.

Parameter add : t -> int64 -> t.

Parameter diff : t -> t -> int64.

Parameter of_seconds : int64 -> t.

Parameter to_seconds : t -> int64.

Parameter of_notation : string -> option t.

Parameter of_notation_exn : string -> t.

Parameter to_notation : t -> string.

Parameter encoding : Data_encoding.t t.

Parameter rfc_encoding : Data_encoding.t t.

Parameter pp_hum : Format.formatter -> t -> unit.

Definition time : Set := t.

Parameter pp : Format.formatter -> t -> unit.

Parameter of_seconds_string : string -> option time.

Parameter to_seconds_string : time -> string.

Parameter op_plusquestion : time -> Period_repr.t -> Error_monad.tzresult time.

Parameter op_minusquestion : time -> time -> Error_monad.tzresult Period_repr.t.
