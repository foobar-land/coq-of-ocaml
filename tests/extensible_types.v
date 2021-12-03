Require Import CoqOfOCaml.CoqOfOCaml.
Require Import CoqOfOCaml.Settings.

Definition ex := extensible_type.

Module Re.
  Record record : Set := Build {
    v : string;
    n : int }.
  Definition with_v v (r : record) :=
    Build v r.(n).
  Definition with_n n (r : record) :=
    Build r.(v) n.
End Re.
Definition Re := Re.record.

Definition v0 : ex := Build_extensible "Empty" unit tt.

Definition v1 : ex := Build_extensible "Int" int 12.

Definition v2 : ex := Build_extensible "String" (string * bool) ("hi", true).

Definition v3 : ex :=
  Build_extensible "Re" Re {| Re.v := "message"; Re.n := 10 |}.

Module Bar.
  Record record : Set := Build {
    message : string }.
  Definition with_message message (r : record) :=
    Build message.
End Bar.
Definition Bar := Bar.record.

Definition match_ex (x_value : ex) : int :=
  match x_value with
  | Build_extensible tag _ payload =>
    if String.eqb tag "Empty" then
      0
    else if String.eqb tag "Int" then
      let 'n_value := cast int payload in
      n_value
    else if String.eqb tag "String" then
      let '(m_value, b_value) := cast (string * bool) payload in
      if b_value then
        CoqOfOCaml.String.length m_value
      else
        0
    else if String.eqb tag "Re" then
      let '{| Re.v := v_value; Re.n := n_value |} := cast Re payload in
      Z.add n_value (CoqOfOCaml.String.length v_value)
    else (-1)
  end.
