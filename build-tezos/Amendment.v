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
Require Tezos.Alpha_context.

Import Alpha_context.

Definition select_winning_proposal (ctxt : Alpha_context.context)
  : Lwt.t
    (Error_monad.tzresult
      (option (|Protocol_hash|).(S.HASH.Map).(S.INDEXES_Map.key))) :=
  let!? proposals := Alpha_context.Vote.get_proposals ctxt in
  let merge {A : Set}
    (proposal : A) (vote : (|Compare.Int32|).(Compare.S.t))
    (winners : option (list A * (|Compare.Int32|).(Compare.S.t)))
    : option (list A * (|Compare.Int32|).(Compare.S.t)) :=
    match winners with
    | None => Some ([ proposal ], vote)
    | (Some (winners, winners_vote)) as previous =>
      if (|Compare.Int32|).(Compare.S.op_eq) vote winners_vote then
        Some ((cons proposal winners), winners_vote)
      else
        if (|Compare.Int32|).(Compare.S.op_gt) vote winners_vote then
          Some ([ proposal ], vote)
        else
          previous
    end in
  match (|Protocol_hash|).(S.HASH.Map).(S.INDEXES_Map.fold) merge proposals None
    with
  | Some (cons proposal [], vote) =>
    let!? max_vote := Alpha_context.Vote.listing_size ctxt in
    let min_proposal_quorum := Alpha_context.Constants.min_proposal_quorum ctxt
      in
    let min_vote_to_pass :=
      Int32.div (Int32.mul min_proposal_quorum max_vote)
        (* ❌ Constant of type int32 is converted to int *)
        10000 in
    if (|Compare.Int32|).(Compare.S.op_gteq) vote min_vote_to_pass then
      Error_monad.return_some proposal
    else
      Error_monad.return_none
  | _ => Error_monad.return_none
  end.

Definition check_approval_and_update_participation_ema
  (ctxt : Alpha_context.context)
  : Lwt.t (Error_monad.tzresult (Alpha_context.context * bool)) :=
  let!? ballots := Alpha_context.Vote.get_ballots ctxt in
  let!? maximum_vote := Alpha_context.Vote.listing_size ctxt in
  let!? participation_ema := Alpha_context.Vote.get_participation_ema ctxt in
  let!? expected_quorum := Alpha_context.Vote.get_current_quorum ctxt in
  let casted_votes :=
    Int32.add ballots.(Alpha_context.Vote.ballots.yay)
      ballots.(Alpha_context.Vote.ballots.nay) in
  let all_votes :=
    Int32.add casted_votes ballots.(Alpha_context.Vote.ballots.pass) in
  let supermajority :=
    Int32.div
      (Int32.mul
        (* ❌ Constant of type int32 is converted to int *)
        8 casted_votes)
      (* ❌ Constant of type int32 is converted to int *)
      10 in
  let participation :=
    Int64.to_int32
      (Int64.div
        (Int64.mul (Int64.of_int32 all_votes)
          (* ❌ Constant of type int64 is converted to int *)
          10000) (Int64.of_int32 maximum_vote)) in
  let outcome :=
    Pervasives.op_andand
      ((|Compare.Int32|).(Compare.S.op_gteq) participation expected_quorum)
      ((|Compare.Int32|).(Compare.S.op_gteq)
        ballots.(Alpha_context.Vote.ballots.yay) supermajority) in
  let new_participation_ema :=
    Int32.div
      (Int32.add
        (Int32.mul
          (* ❌ Constant of type int32 is converted to int *)
          8 participation_ema)
        (Int32.mul
          (* ❌ Constant of type int32 is converted to int *)
          2 participation))
      (* ❌ Constant of type int32 is converted to int *)
      10 in
  let!? ctxt :=
    Alpha_context.Vote.set_participation_ema ctxt new_participation_ema in
  Error_monad.__return (ctxt, outcome).

Definition start_new_voting_period (ctxt : Alpha_context.context)
  : Lwt.t (Error_monad.tzresult Alpha_context.context) :=
  let!? function_parameter := Alpha_context.Vote.get_current_period_kind ctxt in
  match function_parameter with
  | Alpha_context.Voting_period.Proposal =>
    let!? proposal := select_winning_proposal ctxt in
    Error_monad.op_gtgteq (Alpha_context.Vote.clear_proposals ctxt)
      (fun ctxt =>
        let!? ctxt := Alpha_context.Vote.clear_listings ctxt in
        match proposal with
        | None =>
          let!? ctxt := Alpha_context.Vote.freeze_listings ctxt in
          Error_monad.__return ctxt
        | Some proposal =>
          let!? ctxt := Alpha_context.Vote.init_current_proposal ctxt proposal
            in
          let!? ctxt := Alpha_context.Vote.freeze_listings ctxt in
          let!? ctxt :=
            Alpha_context.Vote.set_current_period_kind ctxt
              Alpha_context.Voting_period.Testing_vote in
          Error_monad.__return ctxt
        end)
  | Alpha_context.Voting_period.Testing_vote =>
    let!? '(ctxt, approved) := check_approval_and_update_participation_ema ctxt
      in
    Error_monad.op_gtgteq (Alpha_context.Vote.clear_ballots ctxt)
      (fun ctxt =>
        let!? ctxt := Alpha_context.Vote.clear_listings ctxt in
        if approved then
          let expiration :=
            Time.add (Alpha_context.Timestamp.current ctxt)
              (Alpha_context.Constants.test_chain_duration ctxt) in
          let!? proposal := Alpha_context.Vote.get_current_proposal ctxt in
          Error_monad.op_gtgteq
            (Alpha_context.fork_test_chain ctxt proposal expiration)
            (fun ctxt =>
              let!? ctxt :=
                Alpha_context.Vote.set_current_period_kind ctxt
                  Alpha_context.Voting_period.Testing in
              Error_monad.__return ctxt)
        else
          let!? ctxt := Alpha_context.Vote.clear_current_proposal ctxt in
          let!? ctxt := Alpha_context.Vote.freeze_listings ctxt in
          let!? ctxt :=
            Alpha_context.Vote.set_current_period_kind ctxt
              Alpha_context.Voting_period.Proposal in
          Error_monad.__return ctxt)
  | Alpha_context.Voting_period.Testing =>
    let!? ctxt := Alpha_context.Vote.freeze_listings ctxt in
    let!? ctxt :=
      Alpha_context.Vote.set_current_period_kind ctxt
        Alpha_context.Voting_period.Promotion_vote in
    Error_monad.__return ctxt
  | Alpha_context.Voting_period.Promotion_vote =>
    let!? '(ctxt, approved) := check_approval_and_update_participation_ema ctxt
      in
    let!? ctxt :=
      if approved then
        let!? proposal := Alpha_context.Vote.get_current_proposal ctxt in
        Error_monad.op_gtgteq (Alpha_context.activate ctxt proposal)
          (fun ctxt => Error_monad.__return ctxt)
      else
        Error_monad.__return ctxt in
    Error_monad.op_gtgteq (Alpha_context.Vote.clear_ballots ctxt)
      (fun ctxt =>
        let!? ctxt := Alpha_context.Vote.clear_listings ctxt in
        let!? ctxt := Alpha_context.Vote.clear_current_proposal ctxt in
        let!? ctxt := Alpha_context.Vote.freeze_listings ctxt in
        let!? ctxt :=
          Alpha_context.Vote.set_current_period_kind ctxt
            Alpha_context.Voting_period.Proposal in
        Error_monad.__return ctxt)
  end.

(* ❌ Structure item `typext` not handled. *)
(* type_extension *)

(* ❌ Top-level evaluations are ignored *)
(* top_level_evaluation *)

Fixpoint longer_than {A : Set} (l : list A) (n : (|Compare.Int|).(Compare.S.t))
  {struct l} : bool :=
  if (|Compare.Int|).(Compare.S.op_lt) n 0 then
    (* ❌ Assert instruction is not handled. *)
    assert false
  else
    match l with
    | [] => false
    | cons _ rest =>
      if (|Compare.Int|).(Compare.S.op_eq) n 0 then
        true
      else
        longer_than rest (Pervasives.op_minus n 1)
    end.

Definition record_proposals
  (ctxt : Alpha_context.context) (delegate : Alpha_context.public_key_hash)
  (proposals : list (|Protocol_hash|).(S.HASH.t))
  : Lwt.t (Error_monad.tzresult Alpha_context.context) :=
  let!? '_ :=
    match proposals with
    | [] => Error_monad.fail extensible_type_value
    | cons _ _ => Error_monad.return_unit
    end in
  let!? function_parameter := Alpha_context.Vote.get_current_period_kind ctxt in
  match function_parameter with
  | Alpha_context.Voting_period.Proposal =>
    Error_monad.op_gtgteq (Alpha_context.Vote.in_listings ctxt delegate)
      (fun in_listings =>
        if in_listings then
          let!? count :=
            Alpha_context.Vote.recorded_proposal_count_for_delegate ctxt
              delegate in
          let!? '_ :=
            Error_monad.fail_when
              (longer_than proposals
                (Pervasives.op_minus
                  Alpha_context.Constants.max_proposals_per_delegate count))
              extensible_type_value in
          let!? ctxt :=
            Error_monad.fold_left_s
              (fun ctxt =>
                fun proposal =>
                  Alpha_context.Vote.record_proposal ctxt proposal delegate)
              ctxt proposals in
          Error_monad.__return ctxt
        else
          Error_monad.fail extensible_type_value)
  |
    (Alpha_context.Voting_period.Testing_vote |
    Alpha_context.Voting_period.Testing |
    Alpha_context.Voting_period.Promotion_vote) =>
    Error_monad.fail extensible_type_value
  end.

Definition record_ballot
  (ctxt : Alpha_context.context) (delegate : Alpha_context.public_key_hash)
  (proposal : (|Protocol_hash|).(S.HASH.t)) (ballot : Alpha_context.Vote.ballot)
  : Lwt.t (Error_monad.tzresult Alpha_context.context) :=
  let!? function_parameter := Alpha_context.Vote.get_current_period_kind ctxt in
  match function_parameter with
  |
    (Alpha_context.Voting_period.Testing_vote |
    Alpha_context.Voting_period.Promotion_vote) =>
    let!? current_proposal := Alpha_context.Vote.get_current_proposal ctxt in
    let!? '_ :=
      Error_monad.fail_unless
        ((|Protocol_hash|).(S.HASH.equal) proposal current_proposal)
        extensible_type_value in
    Error_monad.op_gtgteq (Alpha_context.Vote.has_recorded_ballot ctxt delegate)
      (fun has_ballot =>
        let!? '_ := Error_monad.fail_when has_ballot extensible_type_value in
        Error_monad.op_gtgteq (Alpha_context.Vote.in_listings ctxt delegate)
          (fun in_listings =>
            if in_listings then
              Alpha_context.Vote.record_ballot ctxt delegate ballot
            else
              Error_monad.fail extensible_type_value))
  | (Alpha_context.Voting_period.Testing | Alpha_context.Voting_period.Proposal)
    => Error_monad.fail extensible_type_value
  end.

Definition last_of_a_voting_period
  (ctxt : Alpha_context.context) (l : Alpha_context.Level.t) : bool :=
  (|Compare.Int32|).(Compare.S.op_eq)
    (Int32.succ l.(Alpha_context.Level.t.voting_period_position))
    (Alpha_context.Constants.blocks_per_voting_period ctxt).

Definition may_start_new_voting_period (ctxt : Alpha_context.context)
  : Lwt.t (Error_monad.tzresult Alpha_context.context) :=
  let level := Alpha_context.Level.current ctxt in
  if last_of_a_voting_period ctxt level then
    start_new_voting_period ctxt
  else
    Error_monad.__return ctxt.
