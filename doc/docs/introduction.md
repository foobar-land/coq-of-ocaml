---
id: introduction
title: What is coq-of-ocaml
---

`coq-of-ocaml` is a compiler from the [OCaml](https://ocaml.org/) programming language to the [Coq](https://coq.inria.fr/) proof language. It aims generate *idiomatic* and *human readable* Coq code. Technically speaking, this is a [shallow embedding](https://cstheory.stackexchange.com/questions/1370/shallow-versus-deep-embeddings) of OCaml into Coq.

We can use `coq-of-ocaml` to:
* do formal proofs on OCaml programs;
* port OCaml projects to Coq. 

Starting from the following OCaml program:
```ocaml
type 'a tree =
  | Leaf of 'a
  | Node of 'a tree * 'a tree

let rec sum tree =
  match tree with
  | Leaf n -> n
  | Node (tree1, tree2) -> sum tree1 + sum tree2
```
we get the following Coq program:
```coq
(* Generated by coq-of-ocaml *)
Inductive tree (a : Set) : Set :=
| Leaf : a -> tree a
| Node : tree a -> tree a -> tree a.

Arguments Leaf {_}.
Arguments Node {_}.

Fixpoint sum (tree : tree int) : int :=
  match tree with
  | Leaf n => n
  | Node tree1 tree2 => Z.add (sum tree1) (sum tree2)
  end.
```
We map the algebraic datatype `tree` to an equivalent inductive type `tree` in Coq. With the `Arguments` command, we ask Coq to be able to infer the type parameter `a`, as it is done in OCaml. We translate the recursive function `sum` using the command `Fixpoint` in Coq. By default, we represent the `int` type of OCaml by `Z` in Coq, but this can be parametrized.

## Concepts
We can import to Coq the OCaml programs which are either purely functional or whose side-effects are in a [monad](https://caml.inria.fr/pub/docs/manual-ocaml/bindingops.html). We translate the primitive side-effects (references, exceptions, ...) to axioms. We may not completely preserve the semantics of the source code. One should do manual reviews to assert that the generated Coq code is a reasonable formalization of the sources. We produce a dummy Coq term and an explicit message in case of error. In particular, we always generate something and no errors are fatal.

We compile OCaml projects by pluging into [Merlin](https://github.com/ocaml/merlin). This means that if you are using Merlin then you can run `coq-of-ocaml` with no additional configurations.

We do not do special treatments for the termination of fixpoints. We disable termination checks using the Coq's flag [Guard Checking](https://coq.inria.fr/refman/proof-engine/vernacular-commands.html#coq:flag.Guard-Checking). We erase the type parameters for the [GADTs](https://caml.inria.fr/pub/docs/manual-ocaml/manual033.html). This makes sure that the type definitions are accepted, but can make the pattern matchings incomplete. In this case we offer the possibility to introduce dynamic casts guided by annotations in the OCaml code. We did not find a way to nicely represent GADTs in Coq yet. We think that this is hard because the dependent pattern matching works well on type indicies which are values, but does not with types.

We support modules, module types, functors and first-class modules. We generate either Coq modules or polymorphic records depending on the case. We generate axioms for `.mli` files to help formalizations, but importing `.mli` files should not be necessary for a project to compile in Coq.

## Status
`coq-of-ocaml` is under active development at [Nomadic Labs](https://www.nomadic-labs.com/) to get a [Coq formalization](https://gitlab.com/nomadic-labs/coq-tezos-of-ocaml) of the crypto-currency [Tezos](https://tezos.com/). To contact us, you can open an [issue](https://github.com/clarus/coq-of-ocaml/issues) on GitHub or send [an email](mailto:contact@nomadic-labs.com) to Nomadic Labs.

## Workflow
`coq-of-ocaml` works by compiling the OCaml files one by one. Thanks to Merlin, we get access to the typing environment of each file. Thus names referencing external definitions are properly interpreted.

In a typical project, we may want to translate some of the `.ml` files and keep the rest as axioms (for the libraries or non-critical files). To generate the axioms, we can run `coq-of-ocaml` on the `.mli` files for the parts we want to abstract. When something is not properly handled, `coq-of-ocaml` generates an error message. These errors do not necessarily need to be fixed. However, they are good warnings to help having a more extensive and reliable Coq formalization.

Generally, the generated Coq code for a project does not compile as it is. This can be due to unsupported OCaml features, or various small errors such as name collisions. In this case, you can:
* modify the OCaml input code, so that it fits what `coq-of-ocaml` handles or avoids Coq errors (follow the error messages);
* use the [attributes](attributes) or [configuration](configuration) mechanism to customize the translation of `coq-of-ocaml`;
* fork `coq-of-ocaml` to modify the code translation;
* post-process the output with a script;
* post-process the output by hand.

## Related
In the OCaml community:
* [Cameleer](https://github.com/mariojppereira/cameleer) (verify OCaml programs leveraging the [Why3](http://why3.lri.fr/)'s infrastructure)
* [CFML](http://chargueraud.org/softs/cfml/) (import OCaml to Coq using characteristic formulae)
* [coq-of-ocaml-mrmr1993](https://github.com/mrmr1993/coq-of-ocaml) (fork of `coq-of-ocaml` including side-effects, focusing on the compilation of the OCaml's stdlib)

In the JavaScript community:
* [coq-of-js](https://github.com/clarus/coq-of-js) (sister project; *currently on halt to support `coq-of-ocaml`*)

In the Haskell community:
* [hs-to-coq](https://github.com/antalsz/hs-to-coq) (import Haskell to Coq)
* [hs-to-gallina](https://github.com/gdijkstra/hs-to-gallina) (2012, by Gabe Dijkstra, first known project to do a shallow embedding of a mainstream functional programming language to Coq)

In the Go community;
* [goose](https://github.com/tchajed/goose) (import Go to Coq)

In the Rust community:
* [electrolysis](https://github.com/Kha/electrolysis) (import Rust to Lean)

## Credits
The `coq-of-ocaml` project started as part of a PhD directed by [Yann Regis-Gianas](http://yann.regis-gianas.org/) and [Hugo Herbelin
](http://pauillac.inria.fr/~herbelin/) as the university of [Paris 7](https://u-paris.fr/). Originally, the goal was to formalize real OCaml programs in Coq to study side-effects inference and proof techniques on functional programs. The project is now financed by [Nomadic Labs](https://www.nomadic-labs.com/), with the aim to be able to reason about the implementation of the crypto-currency [Tezos](https://tezos.com/).
