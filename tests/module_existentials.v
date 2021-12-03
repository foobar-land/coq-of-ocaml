Require Import CoqOfOCaml.CoqOfOCaml.
Require Import CoqOfOCaml.Settings.

Module S.
  Record signature {t : Set} : Set := {
    t := t;
    v_value : t;
  }.
End S.
Definition S := @S.signature.
Arguments S {_}.

Module M_infer.
  Definition t : Set := int.
  
  Definition v_value : int := 12.
  
  Definition module :=
    {|
      S.v_value := v_value
    |}.
End M_infer.
Definition M_infer := M_infer.module.

Module M_definition.
  Definition t : Set := int.
  
  Definition v_value : int := 12.
  
  Definition module :=
    {|
      S.v_value := v_value
    |}.
End M_definition.
Definition M_definition : S (t := int) := M_definition.module.

Module M_abstract.
  Definition t : Set := int.
  
  Definition v_value : int := 12.
  
  Definition module :=
    {|
      S.v_value := v_value
    |}.
End M_abstract.
Definition M_abstract : S (t := _) := M_abstract.module.

Module F_definition.
  Class FArgs {M1_t M2_t : Set} := {
    M1 : S (t := M1_t);
    M2 : S (t := M2_t);
  }.
  Arguments Build_FArgs {_ _}.
  
  Definition t `{FArgs} : Set := M1.(S.t) * M2.(S.t) * string.
  
  Definition v_value `{FArgs} : M1.(S.t) * M2.(S.t) * string :=
    (M1.(S.v_value), M2.(S.v_value), "foo").
  
  Definition functor `{FArgs} :=
    {|
      S.v_value := v_value
    |}.
End F_definition.
Definition F_definition {M1_t M2_t : Set}
  (M1 : S (t := M1_t)) (M2 : S (t := M2_t))
  : S (t := M1.(S.t) * M2.(S.t) * string) :=
  let '_ := F_definition.Build_FArgs M1 M2 in
  F_definition.functor.

Module F_abstract.
  Class FArgs {M1_t M2_t : Set} := {
    M1 : S (t := M1_t);
    M2 : S (t := M2_t);
  }.
  Arguments Build_FArgs {_ _}.
  
  Definition t `{FArgs} : Set := M1.(S.t) * M2.(S.t) * string.
  
  Definition v_value `{FArgs} : M1.(S.t) * M2.(S.t) * string :=
    (M1.(S.v_value), M2.(S.v_value), "foo").
  
  Definition functor `{FArgs} :=
    {|
      S.v_value := v_value
    |}.
End F_abstract.
Definition F_abstract {M1_t M2_t : Set}
  (M1 : S (t := M1_t)) (M2 : S (t := M2_t)) : S (t := _) :=
  let '_ := F_abstract.Build_FArgs M1 M2 in
  F_abstract.functor.

Module S_with_functor.
  Record signature : Set := {
    F : forall {M_t : Set}, forall (M : S (t := M_t)), S (t := M.(S.t) * int);
  }.
End S_with_functor.
Definition S_with_functor := S_with_functor.signature.

Module M_with_functor.
  Module F.
    Class FArgs {M_t : Set} := {
      M : S (t := M_t);
    }.
    Arguments Build_FArgs {_}.
    
    Definition t `{FArgs} : Set := M.(S.t) * int.
    
    Definition v_value `{FArgs} : M.(S.t) * int := (M.(S.v_value), 12).
    
    Definition functor `{FArgs} :=
      {|
        S.v_value := v_value
      |}.
  End F.
  Definition F {M_t : Set} (M : S (t := M_t)) :=
    let '_ := F.Build_FArgs M in
    F.functor.
  
  Definition module :=
    {|
      S_with_functor.F _ := F
    |}.
End M_with_functor.
Definition M_with_functor : S_with_functor := M_with_functor.module.

Module S_without_abstract.
  Record signature : Set := {
    s_value : string;
  }.
End S_without_abstract.
Definition S_without_abstract := S_without_abstract.signature.

Module M_without_abstract.
  Definition s_value : string := "foo".
  
  Definition module :=
    {|
      S_without_abstract.s_value := s_value
    |}.
End M_without_abstract.
Definition M_without_abstract := M_without_abstract.module.
