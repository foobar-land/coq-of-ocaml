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
Require Tezos.Contract_repr.
Require Tezos.Raw_context.
Require Tezos.Tez_repr.

(* extensible_type_definition `error` *)

(* extensible_type_definition `error` *)

(* extensible_type_definition `error` *)

Parameter origination_burn :
  Raw_context.t -> Lwt.t (Error_monad.tzresult (Raw_context.t * Tez_repr.t)).

Parameter record_paid_storage_space :
  Raw_context.t -> Contract_repr.t ->
  Lwt.t (Error_monad.tzresult (Raw_context.t * Z.t * Z.t * Tez_repr.t)).

Parameter check_storage_limit :
  Raw_context.t -> Z.t -> Error_monad.tzresult unit.

Parameter start_counting_storage_fees : Raw_context.t -> Raw_context.t.

Parameter burn_storage_fees :
  Raw_context.t -> Z.t -> Contract_repr.t ->
  Lwt.t (Error_monad.tzresult Raw_context.t).
