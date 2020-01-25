(** A signature represented by axioms for a [.mli] file. *)
open SmartPrint
open Monad.Notations

type item =
  | Error of string
  | IncludedField of Name.t * Name.t * PathName.t * bool
  | Module of Name.t * t
  | Signature of Name.t * Signature.t
  | TypDefinition of TypeDefinition.t
  | Value of Name.t * Name.t list * Type.t

and t = item list

let rec flatten_single_include (module_typ_desc : Typedtree.module_type_desc)
  : Typedtree.module_type_desc =
  match module_typ_desc with
  | Tmty_signature {
      sig_items = [{
        sig_desc = Tsig_include { incl_mod = { mty_desc; _ }; _ };
        _
      }];
      _
    } -> flatten_single_include mty_desc
  | _ -> module_typ_desc

let rec string_of_included_module_typ (module_typ : Typedtree.module_type)
  : string =
  match module_typ.mty_desc with
  | Tmty_ident (path, _) | Tmty_alias (path, _) -> Path.last path
  | Tmty_signature _ -> "signature"
  | Tmty_functor (ident, _, _, _) -> Ident.name ident
  | Tmty_with (module_typ, _) -> string_of_included_module_typ module_typ
  | Tmty_typeof _ -> "typedof"

let name_of_included_module_typ (module_typ : Typedtree.module_type)
  : Name.t =
  Name.of_string false ("Included_" ^ string_of_included_module_typ module_typ)

let of_top_level_typ_signature
  (module_name : Name.t)
  (signature_path : Path.t)
  (signature : Types.signature)
  : t Monad.t =
  let field_path_name name =
    PathName.of_path_and_name_with_convert signature_path name in
  signature |> Monad.List.filter_map (function
    | Types.Sig_value (ident, _) ->
      let name = Name.of_ident true ident in
      return (Some (
        IncludedField (name, module_name, field_path_name name, false)
      ))
    | Sig_type (ident, _, _) ->
      let name = Name.of_ident false ident in
      return (Some (
        IncludedField (name, module_name, field_path_name name, false)
      ))
    | Sig_typext _ ->
      raise None NotSupported "Type extension not handled"
    | Sig_module (ident, _, _) ->
      let name = Name.of_ident false ident in
      return (Some (
        IncludedField (name, module_name, field_path_name name, true)
      ))
    | Sig_modtype _ ->
      raise None NotSupported "Module type not handled in included signature"
    | Sig_class _ ->
      raise None NotSupported "Class not handled"
    | Sig_class_type _ ->
      raise None NotSupported "Class type not handled"
  )

let rec of_signature (signature : Typedtree.signature) : t Monad.t =
  let of_signature_item (signature_item : Typedtree.signature_item)
    : item list Monad.t =
    set_env signature_item.sig_env (
    set_loc (Loc.of_location signature_item.sig_loc) (
    match signature_item.sig_desc with
    | Tsig_attribute _ ->
      raise
        [Error "attribute"]
        NotSupported
        "Signature item `attribute` not handled"
    | Tsig_class _ ->
      raise
        [Error "class"]
        NotSupported
        "Signature item `class` not handled"
    | Tsig_class_type _ ->
      raise
        [Error "class_type"]
        NotSupported
        "Signature item `class_type` not handled"
    | Tsig_exception { ext_id; _ } ->
      raise
        [Error ("exception " ^ Ident.name ext_id)]
        SideEffect
        "Signature item `exception` not handled"
    | Tsig_include { incl_mod; incl_type; _} ->
      let module_name = name_of_included_module_typ incl_mod in
      let signature_path = ModuleTyp.get_module_typ_path_name incl_mod in
      ModuleTyp.of_ocaml incl_mod >>= fun module_typ ->
      let typ = ModuleTyp.to_typ module_typ in
      begin match signature_path with
      | None ->
        raise [] FirstClassModule "Name for the included signature not found"
      | Some signature_path ->
        of_top_level_typ_signature
          module_name signature_path incl_type >>= fun fields ->
        return (Value (module_name, [], typ) :: fields)
      end
    | Tsig_modtype { mtd_type = None; _ } ->
      raise
        [Error "abstract_module_type"]
        NotSupported
        "Abstract module type not handled"
    | Tsig_modtype { mtd_id; mtd_type = Some { mty_desc; _ }; _ } ->
      let name = Name.of_ident false mtd_id in
      begin match mty_desc with
      | Tmty_signature signature ->
        Signature.of_signature signature >>= fun signature ->
        return [Signature (name, signature)]
      | _ ->
        raise
          [Error "unhandled_module_type"]
          NotSupported
          "Unhandled kind of module type"
      end
    | Tsig_module { md_id; md_type = { mty_desc; _ }; _ } ->
      let name = Name.of_ident false md_id in
      let mty_desc = flatten_single_include mty_desc in
      begin match mty_desc with
      | Tmty_signature signature ->
        of_signature signature >>= fun signature ->
        return [Module (name, signature)]
      | _ ->
        ModuleTyp.of_ocaml_desc mty_desc >>= fun module_typ ->
        let typ = ModuleTyp.to_typ module_typ in
        return [Value (name, [], typ)]
      end
    | Tsig_open _ -> return []
    | Tsig_recmodule _ ->
      raise
        [Error "recursive_module"]
        NotSupported
        "Recursive module signatures are not handled"
    | Tsig_type (_, typs) ->
      TypeDefinition.of_ocaml typs >>= fun typ_definition ->
      return [TypDefinition typ_definition]
    | Tsig_typext { tyext_path; _ } ->
      raise
        [Error ("extensible_type " ^ Path.last tyext_path)]
        NotSupported
        "Extensible types are not handled."
    | Tsig_value { val_id; val_desc = { ctyp_type; _ }; _ } ->
      let name = Name.of_ident true val_id in
      Type.of_typ_expr true Name.Map.empty ctyp_type >>= fun (typ, _, _) ->
      let typ_vars = Name.Set.elements (Type.typ_args typ) in
      return [Value (name, typ_vars, typ)])) in
  signature.sig_items |> Monad.List.flatten_map of_signature_item

let rec to_coq (signature : t) : SmartPrint.t =
  let to_coq_item (signature_item : item) : SmartPrint.t =
    match signature_item with
    | Error message -> !^ ("(* " ^ message ^ " *)")
    | IncludedField (name, module_name, field_name, is_module) ->
      let field =
        MixedPath.to_coq (
          MixedPath.Access (MixedPath.of_name module_name, field_name, false)
        ) in
      let field_as_module =
        if is_module then
          nest (!^ "existT" ^^ !^ "(fun _ => _)" ^^ !^ "tt" ^^ field)
        else
          field in
      !^ "Definition" ^^ Name.to_coq name ^^ !^ ":=" ^^
      field_as_module ^-^ !^ "."
    | Module (name, signature) ->
      !^ "Module" ^^ Name.to_coq name ^-^ !^ "." ^^ newline ^^
      indent (to_coq signature) ^^ newline ^^
      !^ "End" ^^ Name.to_coq name ^-^ !^ "."
    | Signature (name, signature) -> Signature.to_coq_definition name signature
    | TypDefinition typ_definition -> TypeDefinition.to_coq typ_definition
    | Value (name, typ_vars, typ) ->
      nest (
        !^ "Parameter" ^^ Name.to_coq name ^^ !^ ":" ^^
        (match typ_vars with
        | [] -> empty
        | _ :: _ ->
          !^ "forall" ^^ braces (group (
            separate space (List.map Name.to_coq typ_vars) ^^
            !^ ":" ^^ Pp.set)) ^-^ !^ ",") ^^
        Type.to_coq None None typ ^-^ !^ "."
      ) in
  separate (newline ^^ newline) (signature |> List.map to_coq_item)
