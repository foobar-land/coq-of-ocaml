Require Import CoqOfOCaml.CoqOfOCaml.
Require Import CoqOfOCaml.Settings.

Module SizedString.
  Module t.
    Record record : Set := Build {
      name : string;
      size : int }.
    Definition with_name name (r : record) :=
      Build name r.(size).
    Definition with_size size (r : record) :=
      Build r.(name) size.
  End t.
  Definition t := t.record.
End SizedString.

Definition r_value : SizedString.t :=
  {| SizedString.t.name := "gre"; SizedString.t.size := 3 |}.

Definition r' : SizedString.t :=
  {| SizedString.t.name := "haha"; SizedString.t.size := 4 |}.

Definition s_value : int :=
  Z.add r_value.(SizedString.t.size) r'.(SizedString.t.size).

Definition f_value (function_parameter : SizedString.t) : bool :=
  match function_parameter with
  | {| SizedString.t.size := 3 |} => true
  | _ => false
  end.

Definition b_value : bool := f_value r_value.

Definition b' : bool := f_value r'.

Module Point.
  Module t.
    Record record : Set := Build {
      x : int;
      y : int;
      z : int }.
    Definition with_x x (r : record) :=
      Build x r.(y) r.(z).
    Definition with_y y (r : record) :=
      Build r.(x) y r.(z).
    Definition with_z z (r : record) :=
      Build r.(x) r.(y) z.
  End t.
  Definition t := t.record.
  
  Definition p_value : t := {| t.x := 5; t.y := (-3); t.z := 1 |}.
  
  Definition b_value : bool :=
    match p_value with
    | {| t.x := 5; t.z := 1 |} => true
    | _ => false
    end.
End Point.

Module poly.
  Record record {first second : Set} : Set := Build {
    first : first;
    second : second }.
  Arguments record : clear implicits.
  Definition with_first {t_first t_second} first
    (r : record t_first t_second) :=
    Build t_first t_second first r.(second).
  Definition with_second {t_first t_second} second
    (r : record t_first t_second) :=
    Build t_first t_second r.(first) second.
End poly.
Definition poly := poly.record.

Definition p_value : poly int bool :=
  {| poly.first := 12; poly.second := false |}.

Module ConstructorWithRecord.
  (** Records for the constructor parameters *)
  Module ConstructorRecords_t_exi.
    Module t.
      Module Foo.
        Record record {name size : Set} : Set := Build {
          name : name;
          size : size }.
        Arguments record : clear implicits.
        Definition with_name {t_name t_size} name (r : record t_name t_size) :=
          Build t_name t_size name r.(size).
        Definition with_size {t_name t_size} size (r : record t_name t_size) :=
          Build t_name t_size r.(name) size.
      End Foo.
      Definition Foo_skeleton := Foo.record.
    End t.
    Module exi.
      Module Ex.
        Record record {x : Set} : Set := Build {
          x : x }.
        Arguments record : clear implicits.
        Definition with_x {t_x} x (r : record t_x) :=
          Build t_x x.
      End Ex.
      Definition Ex_skeleton := Ex.record.
    End exi.
  End ConstructorRecords_t_exi.
  Import ConstructorRecords_t_exi.
  
  Module loc.
    Record record {x y : Set} : Set := Build {
      x : x;
      y : y }.
    Arguments record : clear implicits.
    Definition with_x {t_x t_y} x (r : record t_x t_y) :=
      Build t_x t_y x r.(y).
    Definition with_y {t_x t_y} y (r : record t_x t_y) :=
      Build t_x t_y r.(x) y.
  End loc.
  Definition loc_skeleton := loc.record.
  
  Reserved Notation "'t.Foo".
  Reserved Notation "'exi.Ex".
  Reserved Notation "'loc".
  
  Inductive t : Set :=
  | Foo : 't.Foo -> t
  | Bar : 'loc -> t
  
  with exi : Set :=
  | Ex : forall {a : Set}, 'exi.Ex a -> exi
  
  where "'loc" := (loc_skeleton int int)
  and "'t.Foo" := (t.Foo_skeleton string int)
  and "'exi.Ex" := (fun (t_a : Set) => exi.Ex_skeleton t_a).
  
  Module t.
    Include ConstructorRecords_t_exi.t.
    Definition Foo := 't.Foo.
  End t.
  Module exi.
    Include ConstructorRecords_t_exi.exi.
    Definition Ex := 'exi.Ex.
  End exi.
  
  Definition loc := 'loc.
  
  Definition l_value : loc := {| loc.x := 12; loc.y := 23 |}.
  
  Definition l_with : loc := loc.with_x 41 l_value.
  
  Definition foo : t := Foo {| t.Foo.name := "foo"; t.Foo.size := 12 |}.
  
  Definition f_value (x_value : t) : int :=
    match x_value with
    | Foo {| t.Foo.size := size |} => size
    | Bar {| loc.y := y_value |} => y_value
    end.
End ConstructorWithRecord.

Module ConstructorWithPolymorphicRecord.
  (** Records for the constructor parameters *)
  Module ConstructorRecords_t.
    Module t.
      Module Foo.
        Record record {location payload size : Set} : Set := Build {
          location : location;
          payload : payload;
          size : size }.
        Arguments record : clear implicits.
        Definition with_location {t_location t_payload t_size} location
          (r : record t_location t_payload t_size) :=
          Build t_location t_payload t_size location r.(payload) r.(size).
        Definition with_payload {t_location t_payload t_size} payload
          (r : record t_location t_payload t_size) :=
          Build t_location t_payload t_size r.(location) payload r.(size).
        Definition with_size {t_location t_payload t_size} size
          (r : record t_location t_payload t_size) :=
          Build t_location t_payload t_size r.(location) r.(payload) size.
      End Foo.
      Definition Foo_skeleton := Foo.record.
    End t.
  End ConstructorRecords_t.
  Import ConstructorRecords_t.
  
  Reserved Notation "'t.Foo".
  
  Inductive t (loc a : Set) : Set :=
  | Foo : 't.Foo loc a -> t loc a
  
  where "'t.Foo" := (fun (t_loc t_a : Set) => t.Foo_skeleton t_loc t_a int).
  
  Module t.
    Include ConstructorRecords_t.t.
    Definition Foo := 't.Foo.
  End t.
  
  Arguments Foo {_ _}.
  
  Definition foo : t int string :=
    Foo {| t.Foo.location := 12; t.Foo.payload := "hi"; t.Foo.size := 23 |}.
End ConstructorWithPolymorphicRecord.

Module RecordWithInnerPolymorphism.
  Module t.
    Record record : Set := Build {
      f : forall {a : Set}, list a -> list a }.
    Definition with_f f (r : record) :=
      Build f.
  End t.
  Definition t := t.record.
  
  Definition f_value {A : Set} (l_value : list A) : list A :=
    match l_value with
    | [] => l_value
    | cons _ l' => l'
    end.
  
  Definition r_value : t := {| t.f _ := f_value |}.
End RecordWithInnerPolymorphism.

Module RecordWithInnerAndOuterPolymorphism.
  Module t.
    Record record {a : Set} : Set := Build {
      f : forall {b : Set}, b -> b -> a }.
    Arguments record : clear implicits.
    Definition with_f {t_a} f (r : record t_a) :=
      Build t_a f.
  End t.
  Definition t := t.record.
End RecordWithInnerAndOuterPolymorphism.
