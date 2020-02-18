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
Require Tezos.Cycle_repr.
Require Tezos.Level_repr.
Require Tezos.Raw_context.
Require Tezos.Roll_repr.
Require Tezos.Tez_repr.

(* extensible_type_definition `error` *)

Parameter init : Raw_context.t -> Lwt.t (Error_monad.tzresult Raw_context.t).

Parameter init_first_cycles :
  Raw_context.t -> Lwt.t (Error_monad.tzresult Raw_context.t).

Parameter cycle_end :
  Raw_context.t -> Cycle_repr.t -> Lwt.t (Error_monad.tzresult Raw_context.t).

Parameter snapshot_rolls :
  Raw_context.t -> Lwt.t (Error_monad.tzresult Raw_context.t).

Parameter fold : forall {a : Set},
  Raw_context.t ->
  (Roll_repr.roll -> (|Signature.Public_key|).(S.SPublic_key.t) -> a ->
  Lwt.t (Error_monad.tzresult a)) -> a -> Lwt.t (Error_monad.tzresult a).

Parameter baking_rights_owner :
  Raw_context.t -> Level_repr.t -> Z ->
  Lwt.t (Error_monad.tzresult (|Signature.Public_key|).(S.SPublic_key.t)).

Parameter endorsement_rights_owner :
  Raw_context.t -> Level_repr.t -> Z ->
  Lwt.t (Error_monad.tzresult (|Signature.Public_key|).(S.SPublic_key.t)).

Module Delegate.
  Parameter is_inactive :
    Raw_context.t -> (|Signature.Public_key_hash|).(S.SPublic_key_hash.t) ->
    Lwt.t (Error_monad.tzresult bool).
  
  Parameter add_amount :
    Raw_context.t -> (|Signature.Public_key_hash|).(S.SPublic_key_hash.t) ->
    Tez_repr.t -> Lwt.t (Error_monad.tzresult Raw_context.t).
  
  Parameter remove_amount :
    Raw_context.t -> (|Signature.Public_key_hash|).(S.SPublic_key_hash.t) ->
    Tez_repr.t -> Lwt.t (Error_monad.tzresult Raw_context.t).
  
  Parameter set_inactive :
    Raw_context.t -> (|Signature.Public_key_hash|).(S.SPublic_key_hash.t) ->
    Lwt.t (Error_monad.tzresult Raw_context.t).
  
  Parameter set_active :
    Raw_context.t -> (|Signature.Public_key_hash|).(S.SPublic_key_hash.t) ->
    Lwt.t (Error_monad.tzresult Raw_context.t).
End Delegate.

Module Contract.
  Parameter add_amount :
    Raw_context.t -> Contract_repr.t -> Tez_repr.t ->
    Lwt.t (Error_monad.tzresult Raw_context.t).
  
  Parameter remove_amount :
    Raw_context.t -> Contract_repr.t -> Tez_repr.t ->
    Lwt.t (Error_monad.tzresult Raw_context.t).
End Contract.

Parameter delegate_pubkey :
  Raw_context.t -> (|Signature.Public_key_hash|).(S.SPublic_key_hash.t) ->
  Lwt.t (Error_monad.tzresult (|Signature.Public_key|).(S.SPublic_key.t)).

Parameter get_rolls :
  Raw_context.t -> (|Signature.Public_key_hash|).(S.SPublic_key_hash.t) ->
  Lwt.t (Error_monad.tzresult (list Roll_repr.t)).

Parameter get_change :
  Raw_context.t -> (|Signature.Public_key_hash|).(S.SPublic_key_hash.t) ->
  Lwt.t (Error_monad.tzresult Tez_repr.t).

Parameter update_tokens_per_roll :
  Raw_context.t -> Tez_repr.t -> Lwt.t (Error_monad.tzresult Raw_context.t).

Parameter get_contract_delegate :
  Raw_context.t -> Contract_repr.t ->
  Lwt.t
    (Error_monad.tzresult
      (option (|Signature.Public_key_hash|).(S.SPublic_key_hash.t))).
