Require Import CoqOfOCaml.CoqOfOCaml.
Require Import CoqOfOCaml.Settings.

Module Sig1.
  Record signature {t : Set} : Set := {
    t := t;
    f_value : t -> t -> t * t;
  }.
End Sig1.
Definition Sig1 := @Sig1.signature.
Arguments Sig1 {_}.

Module Sig2.
  Record signature {t : Set} : Set := {
    t := t;
    f_value : t -> list t;
  }.
End Sig2.
Definition Sig2 := @Sig2.signature.
Arguments Sig2 {_}.

Module M1.
  Definition t : Set := int.
  
  Definition f_value {A : Set} (n_value : t) (m_value : A) : t * A :=
    (n_value, m_value).
  
  Definition module :=
    {|
      Sig1.f_value := f_value
    |}.
End M1.
Definition M1 : Sig1 (t := _) := M1.module.

Module M2.
  Definition t : Set := int.
  
  Definition f_value {A : Set} (n_value : t) : list A := nil.
  
  Definition module :=
    {|
      Sig2.f_value := f_value
    |}.
End M2.
Definition M2 : Sig2 (t := _) := M2.module.
