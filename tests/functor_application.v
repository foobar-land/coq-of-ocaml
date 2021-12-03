Require Import CoqOfOCaml.CoqOfOCaml.
Require Import CoqOfOCaml.Settings.

(** Some documentation *)
Module Source.
  Record signature {t : Set} : Set := {
    t := t;
    (** The description of [x] *)
    x_value : t;
    id : forall {a : Set}, a -> a;
  }.
End Source.
Definition Source := @Source.signature.
Arguments Source {_}.

Module Target.
  Record signature {t : Set} : Set := {
    t := t;
    y_value : t;
  }.
End Target.
Definition Target := @Target.signature.
Arguments Target {_}.

Module M.
  Definition t : Set := int.
  
  Definition x_value : int := 12.
  
  Definition id {A : Set} (x_value : A) : A := x_value.
  
  Definition module :=
    {|
      Source.x_value := x_value;
      Source.id _ := id
    |}.
End M.
Definition M : Source (t := _) := M.module.

Module F.
  Class FArgs {X_t : Set} := {
    X : Source (t := X_t);
  }.
  Arguments Build_FArgs {_}.
  
  Definition t `{FArgs} : Set := X.(Source.t).
  
  Definition y_value `{FArgs} : X.(Source.t) := X.(Source.x_value).
  
  Definition functor `{FArgs} :=
    {|
      Target.y_value := y_value
    |}.
End F.
Definition F {X_t : Set} (X : Source (t := X_t)) : Target (t := X.(Source.t)) :=
  let '_ := F.Build_FArgs X in
  F.functor.

Definition FM := F M.

Module FSubst.
  Class FArgs {X_t : Set} := {
    X : Source (t := X_t);
  }.
  Arguments Build_FArgs {_}.
  
  Definition y_value `{FArgs} : X.(Source.t) := X.(Source.x_value).
  
  Definition functor `{FArgs} :=
    {|
      Target.y_value := y_value
    |}.
End FSubst.
Definition FSubst {X_t : Set} (X : Source (t := X_t))
  : Target (t := X.(Source.t)) :=
  let '_ := FSubst.Build_FArgs X in
  FSubst.functor.

Module Sum.
  Class FArgs := {
    X : Source (t := int);
    Y : Source (t := int);
  }.
  
  Definition t `{FArgs} : Set := int.
  
  Definition y_value `{FArgs} : int :=
    Z.add X.(Source.x_value) Y.(Source.x_value).
  
  Definition functor `{FArgs} :=
    {|
      Target.y_value := y_value
    |}.
End Sum.
Definition Sum (X : Source (t := int)) (Y : Source (t := int)) : Target (t := _)
  :=
  let '_ := Sum.Build_FArgs X Y in
  Sum.functor.

Module WithM.
  (** Inclusion of the module [M] *)
  Definition t := M.(Source.t).
  
  Definition x_value := M.(Source.x_value).
  
  Definition id {a : Set} := M.(Source.id) (a := a).
  
  Definition z_value : int := 0.
End WithM.

Module WithSum.
  Definition F_include := F M.
  
  (** Inclusion of the module [F_include] *)
  Definition t := F_include.(Target.t).
  
  Definition y_value := F_include.(Target.y_value).
  
  Definition z_value : int := 0.
End WithSum.

Module GenFun.
  Definition t : Set := int.
  
  Definition y_value : int := 23.
  
  Definition module :=
    {|
      Target.y_value := y_value
    |}.
End GenFun.
Definition GenFun : Target (t := _) := GenFun.module.

Definition AppliedGenFun : Target (t := _) := GenFun.

Module LargeTarget.
  Record signature {t : Set} : Set := {
    t := t;
    y_value : t;
    z_value : t;
  }.
End LargeTarget.
Definition LargeTarget := @LargeTarget.signature.
Arguments LargeTarget {_}.

Module LargeF.
  Class FArgs {X_t : Set} := {
    X : Source (t := X_t);
  }.
  Arguments Build_FArgs {_}.
  
  Definition t `{FArgs} : Set := X.(Source.t).
  
  Definition y_value `{FArgs} : X.(Source.t) := X.(Source.x_value).
  
  Definition z_value `{FArgs} : X.(Source.t) := y_value.
  
  Definition functor `{FArgs} :=
    {|
      LargeTarget.y_value := y_value;
      LargeTarget.z_value := z_value
    |}.
End LargeF.
Definition LargeF {X_t : Set} (X : Source (t := X_t)) : LargeTarget (t := _) :=
  let '_ := LargeF.Build_FArgs X in
  LargeF.functor.

Definition CastedLarge : Target (t := _) :=
  let functor_result := LargeF M in
  {|
    Target.y_value := functor_result.(LargeTarget.y_value)
  |}.
