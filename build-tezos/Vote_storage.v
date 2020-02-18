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
Require Tezos.Constants_storage.
Require Tezos.Raw_context.
Require Tezos.Roll_storage.
Require Tezos.Storage_mli. Module Storage := Storage_mli.
Require Tezos.Storage_sigs.
Require Tezos.Vote_repr.
Require Tezos.Voting_period_repr.

Definition recorded_proposal_count_for_delegate
  (ctxt :
    (|Storage.Vote.Proposals_count|).(Storage_sigs.Indexed_data_storage.context))
  (proposer :
    (|Storage.Vote.Proposals_count|).(Storage_sigs.Indexed_data_storage.key))
  : Lwt.t
    (Error_monad.tzresult
      (|Storage.Vote.Proposals_count|).(Storage_sigs.Indexed_data_storage.value)) :=
  let!? function_parameter :=
    (|Storage.Vote.Proposals_count|).(Storage_sigs.Indexed_data_storage.get_option)
      ctxt proposer in
  match function_parameter with
  | None => Error_monad.__return 0
  | Some count => Error_monad.__return count
  end.

Definition record_proposal
  (ctxt :
    (|Storage.Vote.Proposals_count|).(Storage_sigs.Indexed_data_storage.context))
  (proposal : (|Protocol_hash|).(S.HASH.t))
  (proposer :
    (|Storage.Vote.Proposals_count|).(Storage_sigs.Indexed_data_storage.key))
  : Lwt.t (Error_monad.tzresult Raw_context.t) :=
  let!? count := recorded_proposal_count_for_delegate ctxt proposer in
  Error_monad.op_gtgteq
    ((|Storage.Vote.Proposals_count|).(Storage_sigs.Indexed_data_storage.init_set)
      ctxt proposer (Pervasives.op_plus count 1))
    (fun ctxt =>
      Error_monad.op_gtgteq
        ((|Storage.Vote.Proposals|).(Storage_sigs.Data_set_storage.add) ctxt
          (proposal, proposer)) (fun ctxt => Error_monad.__return ctxt)).

Definition get_proposals
  (ctxt : (|Storage.Vote.Proposals|).(Storage_sigs.Data_set_storage.context))
  : Lwt.t
    (Error_monad.tzresult
      ((|Protocol_hash|).(S.HASH.Map).(S.INDEXES_Map.t) int32)) :=
  (|Storage.Vote.Proposals|).(Storage_sigs.Data_set_storage.fold) ctxt
    (Error_monad.ok (|Protocol_hash|).(S.HASH.Map).(S.INDEXES_Map.empty))
    (fun function_parameter =>
      let '(proposal, delegate) := function_parameter in
      fun acc =>
        let!? weight :=
          (|Storage.Vote.Listings|).(Storage_sigs.Indexed_data_storage.get) ctxt
            delegate in
        Lwt.__return
          (Error_monad.op_gtgtquestion acc
            (fun acc =>
              let previous :=
                match
                  (|Protocol_hash|).(S.HASH.Map).(S.INDEXES_Map.find_opt)
                    proposal acc with
                | None =>
                  (* ❌ Constant of type int32 is converted to int *)
                  0
                | Some x => x
                end in
              Error_monad.ok
                ((|Protocol_hash|).(S.HASH.Map).(S.INDEXES_Map.add) proposal
                  (Int32.add weight previous) acc)))).

Definition clear_proposals
  (ctxt :
    (|Storage.Vote.Proposals_count|).(Storage_sigs.Indexed_data_storage.context))
  : Lwt.t Raw_context.t :=
  Error_monad.op_gtgteq
    ((|Storage.Vote.Proposals_count|).(Storage_sigs.Indexed_data_storage.clear)
      ctxt)
    (fun ctxt =>
      (|Storage.Vote.Proposals|).(Storage_sigs.Data_set_storage.clear) ctxt).

Module ballots.
  Record record : Set := Build {
    yay : int32;
    nay : int32;
    pass : int32 }.
  Definition with_yay yay (r : record) :=
    Build yay r.(nay) r.(pass).
  Definition with_nay nay (r : record) :=
    Build r.(yay) nay r.(pass).
  Definition with_pass pass (r : record) :=
    Build r.(yay) r.(nay) pass.
End ballots.
Definition ballots := ballots.record.

Definition ballots_encoding : Data_encoding.encoding ballots :=
  (let arg :=
    Data_encoding.conv
      (fun function_parameter =>
        let '{|
          ballots.yay := yay; ballots.nay := nay; ballots.pass := pass |} :=
          function_parameter in
        (yay, nay, pass))
      (fun function_parameter =>
        let '(yay, nay, pass) := function_parameter in
        {| ballots.yay := yay; ballots.nay := nay; ballots.pass := pass |}) in
  fun eta => arg None eta)
    (Data_encoding.obj3
      (Data_encoding.req None None "yay" Data_encoding.__int32_value)
      (Data_encoding.req None None "nay" Data_encoding.__int32_value)
      (Data_encoding.req None None "pass" Data_encoding.__int32_value)).

Definition has_recorded_ballot
  : (|Storage.Vote.Ballots|).(Storage_sigs.Indexed_data_storage.context) ->
  (|Storage.Vote.Ballots|).(Storage_sigs.Indexed_data_storage.key) -> Lwt.t bool :=
  (|Storage.Vote.Ballots|).(Storage_sigs.Indexed_data_storage.mem).

Definition record_ballot
  : (|Storage.Vote.Ballots|).(Storage_sigs.Indexed_data_storage.context) ->
  (|Storage.Vote.Ballots|).(Storage_sigs.Indexed_data_storage.key) ->
  (|Storage.Vote.Ballots|).(Storage_sigs.Indexed_data_storage.value) ->
  Lwt.t (Error_monad.tzresult Raw_context.t) :=
  (|Storage.Vote.Ballots|).(Storage_sigs.Indexed_data_storage.init).

Definition get_ballots
  (ctxt : (|Storage.Vote.Ballots|).(Storage_sigs.Indexed_data_storage.context))
  : Lwt.t (Error_monad.tzresult ballots) :=
  (|Storage.Vote.Ballots|).(Storage_sigs.Indexed_data_storage.fold) ctxt
    (Error_monad.ok
      {|
        ballots.yay :=
          (* ❌ Constant of type int32 is converted to int *)
          0;
        ballots.nay :=
          (* ❌ Constant of type int32 is converted to int *)
          0;
        ballots.pass :=
          (* ❌ Constant of type int32 is converted to int *)
          0 |})
    (fun delegate =>
      fun ballot =>
        fun ballots =>
          let!? weight :=
            (|Storage.Vote.Listings|).(Storage_sigs.Indexed_data_storage.get)
              ctxt delegate in
          let count := Int32.add weight in
          Lwt.__return
            (Error_monad.op_gtgtquestion ballots
              (fun ballots =>
                match ballot with
                | Vote_repr.Yay =>
                  Error_monad.ok
                    (ballots.with_yay (count ballots.(ballots.yay)) ballots)
                | Vote_repr.Nay =>
                  Error_monad.ok
                    (ballots.with_nay (count ballots.(ballots.nay)) ballots)
                | Vote_repr.Pass =>
                  Error_monad.ok
                    (ballots.with_pass (count ballots.(ballots.pass)) ballots)
                end))).

Definition get_ballot_list
  : (|Storage.Vote.Ballots|).(Storage_sigs.Indexed_data_storage.context) ->
  Lwt.t
    (list
      ((|Storage.Vote.Ballots|).(Storage_sigs.Indexed_data_storage.key) *
        (|Storage.Vote.Ballots|).(Storage_sigs.Indexed_data_storage.value))) :=
  (|Storage.Vote.Ballots|).(Storage_sigs.Indexed_data_storage.bindings).

Definition clear_ballots
  : (|Storage.Vote.Ballots|).(Storage_sigs.Indexed_data_storage.context) ->
  Lwt.t Raw_context.t :=
  (|Storage.Vote.Ballots|).(Storage_sigs.Indexed_data_storage.clear).

Definition listings_encoding
  : Data_encoding.encoding
    (list ((|Signature.Public_key_hash|).(S.SPublic_key_hash.t) * int32)) :=
  Data_encoding.__list_value None
    (Data_encoding.obj2
      (Data_encoding.req None None "pkh"
        (|Signature.Public_key_hash|).(S.SPublic_key_hash.encoding))
      (Data_encoding.req None None "rolls" Data_encoding.__int32_value)).

Definition freeze_listings (ctxt : Raw_context.t)
  : Lwt.t (Error_monad.tzresult Raw_context.t) :=
  let!? '(ctxt, total) :=
    Roll_storage.fold ctxt
      (fun _roll =>
        fun delegate =>
          fun function_parameter =>
            let '(ctxt, total) := function_parameter in
            let delegate :=
              (|Signature.Public_key|).(S.SPublic_key.__hash_value) delegate in
            let!? count :=
              let!? function_parameter :=
                (|Storage.Vote.Listings|).(Storage_sigs.Indexed_data_storage.get_option)
                  ctxt delegate in
              match function_parameter with
              | None =>
                Error_monad.__return
                  (* ❌ Constant of type int32 is converted to int *)
                  0
              | Some count => Error_monad.__return count
              end in
            Error_monad.op_gtgteq
              ((|Storage.Vote.Listings|).(Storage_sigs.Indexed_data_storage.init_set)
                ctxt delegate (Int32.succ count))
              (fun ctxt => Error_monad.__return (ctxt, (Int32.succ total))))
      (ctxt,
        (* ❌ Constant of type int32 is converted to int *)
        0) in
  let!? ctxt :=
    (|Storage.Vote.Listings_size|).(Storage_sigs.Single_data_storage.init) ctxt
      total in
  Error_monad.__return ctxt.

Definition listing_size
  : (|Storage.Vote.Listings_size|).(Storage_sigs.Single_data_storage.context) ->
  Lwt.t
    (Error_monad.tzresult
      (|Storage.Vote.Listings_size|).(Storage_sigs.Single_data_storage.value)) :=
  (|Storage.Vote.Listings_size|).(Storage_sigs.Single_data_storage.get).

Definition in_listings
  : (|Storage.Vote.Listings|).(Storage_sigs.Indexed_data_storage.context) ->
  (|Storage.Vote.Listings|).(Storage_sigs.Indexed_data_storage.key) ->
  Lwt.t bool :=
  (|Storage.Vote.Listings|).(Storage_sigs.Indexed_data_storage.mem).

Definition get_listings
  : (|Storage.Vote.Listings|).(Storage_sigs.Indexed_data_storage.context) ->
  Lwt.t
    (list
      ((|Storage.Vote.Listings|).(Storage_sigs.Indexed_data_storage.key) *
        (|Storage.Vote.Listings|).(Storage_sigs.Indexed_data_storage.value))) :=
  (|Storage.Vote.Listings|).(Storage_sigs.Indexed_data_storage.bindings).

Definition clear_listings
  (ctxt : (|Storage.Vote.Listings|).(Storage_sigs.Indexed_data_storage.context))
  : Lwt.t (Error_monad.tzresult Raw_context.t) :=
  Error_monad.op_gtgteq
    ((|Storage.Vote.Listings|).(Storage_sigs.Indexed_data_storage.clear) ctxt)
    (fun ctxt =>
      Error_monad.op_gtgteq
        ((|Storage.Vote.Listings_size|).(Storage_sigs.Single_data_storage.remove)
          ctxt) (fun ctxt => Error_monad.__return ctxt)).

Definition get_current_period_kind
  : (|Storage.Vote.Current_period_kind|).(Storage_sigs.Single_data_storage.context)
  ->
  Lwt.t
    (Error_monad.tzresult
      (|Storage.Vote.Current_period_kind|).(Storage_sigs.Single_data_storage.value)) :=
  (|Storage.Vote.Current_period_kind|).(Storage_sigs.Single_data_storage.get).

Definition set_current_period_kind
  : (|Storage.Vote.Current_period_kind|).(Storage_sigs.Single_data_storage.context)
  ->
  (|Storage.Vote.Current_period_kind|).(Storage_sigs.Single_data_storage.value)
  -> Lwt.t (Error_monad.tzresult Raw_context.t) :=
  (|Storage.Vote.Current_period_kind|).(Storage_sigs.Single_data_storage.set).

Definition get_current_quorum
  (ctxt :
    (|Storage.Vote.Participation_ema|).(Storage_sigs.Single_data_storage.context))
  : Lwt.t (Error_monad.tzresult int32) :=
  let!? participation_ema :=
    (|Storage.Vote.Participation_ema|).(Storage_sigs.Single_data_storage.get)
      ctxt in
  let quorum_min := Constants_storage.quorum_min ctxt in
  let quorum_max := Constants_storage.quorum_max ctxt in
  let quorum_diff := Int32.sub quorum_max quorum_min in
  Error_monad.__return
    (Int32.add quorum_min
      (Int32.div (Int32.mul participation_ema quorum_diff)
        (* ❌ Constant of type int32 is converted to int *)
        10000)).

Definition get_participation_ema
  : (|Storage.Vote.Participation_ema|).(Storage_sigs.Single_data_storage.context)
  ->
  Lwt.t
    (Error_monad.tzresult
      (|Storage.Vote.Participation_ema|).(Storage_sigs.Single_data_storage.value)) :=
  (|Storage.Vote.Participation_ema|).(Storage_sigs.Single_data_storage.get).

Definition set_participation_ema
  : (|Storage.Vote.Participation_ema|).(Storage_sigs.Single_data_storage.context)
  ->
  (|Storage.Vote.Participation_ema|).(Storage_sigs.Single_data_storage.value) ->
  Lwt.t (Error_monad.tzresult Raw_context.t) :=
  (|Storage.Vote.Participation_ema|).(Storage_sigs.Single_data_storage.set).

Definition get_current_proposal
  : (|Storage.Vote.Current_proposal|).(Storage_sigs.Single_data_storage.context)
  ->
  Lwt.t
    (Error_monad.tzresult
      (|Storage.Vote.Current_proposal|).(Storage_sigs.Single_data_storage.value)) :=
  (|Storage.Vote.Current_proposal|).(Storage_sigs.Single_data_storage.get).

Definition init_current_proposal
  : (|Storage.Vote.Current_proposal|).(Storage_sigs.Single_data_storage.context)
  ->
  (|Storage.Vote.Current_proposal|).(Storage_sigs.Single_data_storage.value) ->
  Lwt.t (Error_monad.tzresult Raw_context.t) :=
  (|Storage.Vote.Current_proposal|).(Storage_sigs.Single_data_storage.init).

Definition clear_current_proposal
  : (|Storage.Vote.Current_proposal|).(Storage_sigs.Single_data_storage.context)
  -> Lwt.t (Error_monad.tzresult Raw_context.t) :=
  (|Storage.Vote.Current_proposal|).(Storage_sigs.Single_data_storage.delete).

Definition init (ctxt : Raw_context.context)
  : Lwt.t (Error_monad.tzresult Raw_context.t) :=
  let participation_ema := Constants_storage.quorum_max ctxt in
  let!? ctxt :=
    (|Storage.Vote.Participation_ema|).(Storage_sigs.Single_data_storage.init)
      ctxt participation_ema in
  let!? ctxt :=
    (|Storage.Vote.Current_period_kind|).(Storage_sigs.Single_data_storage.init)
      ctxt Voting_period_repr.Proposal in
  Error_monad.__return ctxt.
