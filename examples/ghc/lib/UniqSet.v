(* Default settings (from HsToCoq.Coq.Preamble) *)

Generalizable All Variables.

Unset Implicit Arguments.
Set Maximal Implicit Insertion.
Unset Strict Implicit.
Unset Printing Implicit Defensive.

Require Coq.Program.Tactics.
Require Coq.Program.Wf.

(* Converted imports: *)

Require Data.Foldable.
Require GHC.Base.
Require GHC.Num.
Require GHC.Prim.
Require UniqFM.
Require Unique.
Import GHC.Base.Notations.

(* Converted type declarations: *)

Inductive UniqSet a : Type := UniqSet : UniqFM.UniqFM a -> UniqSet a.

Arguments UniqSet {_} _.

Definition getUniqSet' {a} (arg_0__ : UniqSet a) :=
  let 'UniqSet getUniqSet' := arg_0__ in
  getUniqSet'.
(* Converted value declarations: *)

Local Definition Eq___UniqSet_op_zeze__ {inst_a}
   : (UniqSet inst_a) -> (UniqSet inst_a) -> bool :=
  fun arg_0__ arg_1__ =>
    match arg_0__, arg_1__ with
    | UniqSet a, UniqSet b => UniqFM.equalKeysUFM a b
    end.

Local Definition Eq___UniqSet_op_zsze__ {inst_a}
   : (UniqSet inst_a) -> (UniqSet inst_a) -> bool :=
  fun x y => negb (Eq___UniqSet_op_zeze__ x y).

Program Instance Eq___UniqSet {a} : GHC.Base.Eq_ (UniqSet a) :=
  fun _ k =>
    k {| GHC.Base.op_zeze____ := Eq___UniqSet_op_zeze__ ;
         GHC.Base.op_zsze____ := Eq___UniqSet_op_zsze__ |}.

(* Translating `instance Outputable__UniqSet' failed: OOPS! Cannot find
   information for class Qualified "Outputable" "Outputable" unsupported *)

Local Definition Monoid__UniqSet_mappend {inst_a}
   : UniqSet inst_a -> UniqSet inst_a -> UniqSet inst_a :=
  GHC.Prim.coerce GHC.Base.mappend.

Local Definition Monoid__UniqSet_mconcat {inst_a}
   : list (UniqSet inst_a) -> UniqSet inst_a :=
  GHC.Prim.coerce GHC.Base.mconcat.

Local Definition Monoid__UniqSet_mempty {inst_a} : UniqSet inst_a :=
  GHC.Prim.coerce GHC.Base.mempty.

Program Instance Monoid__UniqSet {a} : GHC.Base.Monoid (UniqSet a) :=
  fun _ k =>
    k {| GHC.Base.mappend__ := Monoid__UniqSet_mappend ;
         GHC.Base.mconcat__ := Monoid__UniqSet_mconcat ;
         GHC.Base.mempty__ := Monoid__UniqSet_mempty |}.

Local Definition Semigroup__UniqSet_op_zlzlzgzg__ {inst_a}
   : UniqSet inst_a -> UniqSet inst_a -> UniqSet inst_a :=
  GHC.Prim.coerce _GHC.Base.<<>>_.

Program Instance Semigroup__UniqSet {a} : GHC.Base.Semigroup (UniqSet a) :=
  fun _ k => k {| GHC.Base.op_zlzlzgzg____ := Semigroup__UniqSet_op_zlzlzgzg__ |}.

(* Translating `instance Data__UniqSet' failed: OOPS! Cannot find information
   for class Qualified "Data.Data" "Data" unsupported *)

Definition addOneToUniqSet {a} `{Unique.Uniquable a}
   : UniqSet a -> a -> UniqSet a :=
  fun arg_0__ arg_1__ =>
    match arg_0__, arg_1__ with
    | UniqSet set, x => UniqSet (UniqFM.addToUFM set x x)
    end.

Definition addListToUniqSet {a} `{Unique.Uniquable a}
   : UniqSet a -> list a -> UniqSet a :=
  Data.Foldable.foldl' addOneToUniqSet.

Definition delListFromUniqSet {a} `{Unique.Uniquable a}
   : UniqSet a -> list a -> UniqSet a :=
  fun arg_0__ arg_1__ =>
    match arg_0__, arg_1__ with
    | UniqSet s, l => UniqSet (UniqFM.delListFromUFM s l)
    end.

Definition delListFromUniqSet_Directly {a}
   : UniqSet a -> list Unique.Unique -> UniqSet a :=
  fun arg_0__ arg_1__ =>
    match arg_0__, arg_1__ with
    | UniqSet s, l => UniqSet (UniqFM.delListFromUFM_Directly s l)
    end.

Definition delOneFromUniqSet {a} `{Unique.Uniquable a}
   : UniqSet a -> a -> UniqSet a :=
  fun arg_0__ arg_1__ =>
    match arg_0__, arg_1__ with
    | UniqSet s, a => UniqSet (UniqFM.delFromUFM s a)
    end.

Definition delOneFromUniqSet_Directly {a}
   : UniqSet a -> Unique.Unique -> UniqSet a :=
  fun arg_0__ arg_1__ =>
    match arg_0__, arg_1__ with
    | UniqSet s, u => UniqSet (UniqFM.delFromUFM_Directly s u)
    end.

Definition elemUniqSet_Directly {a} : Unique.Unique -> UniqSet a -> bool :=
  fun arg_0__ arg_1__ =>
    match arg_0__, arg_1__ with
    | a, UniqSet s => UniqFM.elemUFM_Directly a s
    end.

Definition elementOfUniqSet {a} `{Unique.Uniquable a}
   : a -> UniqSet a -> bool :=
  fun arg_0__ arg_1__ =>
    match arg_0__, arg_1__ with
    | a, UniqSet s => UniqFM.elemUFM a s
    end.

Definition emptyUniqSet {a} : UniqSet a :=
  UniqSet UniqFM.emptyUFM.

Definition mkUniqSet {a} `{Unique.Uniquable a} : list a -> UniqSet a :=
  Data.Foldable.foldl' addOneToUniqSet emptyUniqSet.

Definition filterUniqSet {a} : (a -> bool) -> UniqSet a -> UniqSet a :=
  fun arg_0__ arg_1__ =>
    match arg_0__, arg_1__ with
    | p, UniqSet s => UniqSet (UniqFM.filterUFM p s)
    end.

Definition filterUniqSet_Directly {elt}
   : (Unique.Unique -> elt -> bool) -> UniqSet elt -> UniqSet elt :=
  fun arg_0__ arg_1__ =>
    match arg_0__, arg_1__ with
    | f, UniqSet s => UniqSet (UniqFM.filterUFM_Directly f s)
    end.

Definition getUniqSet {a} : UniqSet a -> UniqFM.UniqFM a :=
  getUniqSet'.

Definition intersectUniqSets {a} : UniqSet a -> UniqSet a -> UniqSet a :=
  fun arg_0__ arg_1__ =>
    match arg_0__, arg_1__ with
    | UniqSet s, UniqSet t => UniqSet (UniqFM.intersectUFM s t)
    end.

Definition isEmptyUniqSet {a} : UniqSet a -> bool :=
  fun arg_0__ => let 'UniqSet s := arg_0__ in UniqFM.isNullUFM s.

Definition lookupUniqSet {a} {b} `{Unique.Uniquable a}
   : UniqSet b -> a -> option b :=
  fun arg_0__ arg_1__ =>
    match arg_0__, arg_1__ with
    | UniqSet s, k => UniqFM.lookupUFM s k
    end.

Definition lookupUniqSet_Directly {a}
   : UniqSet a -> Unique.Unique -> option a :=
  fun arg_0__ arg_1__ =>
    match arg_0__, arg_1__ with
    | UniqSet s, k => UniqFM.lookupUFM_Directly s k
    end.

Definition minusUniqSet {a} : UniqSet a -> UniqSet a -> UniqSet a :=
  fun arg_0__ arg_1__ =>
    match arg_0__, arg_1__ with
    | UniqSet s, UniqSet t => UniqSet (UniqFM.minusUFM s t)
    end.

Definition nonDetEltsUniqSet {elt} : UniqSet elt -> list elt :=
  UniqFM.nonDetEltsUFM GHC.Base.∘ getUniqSet'.

Definition mapUniqSet {b} {a} `{Unique.Uniquable b}
   : (a -> b) -> UniqSet a -> UniqSet b :=
  fun f => mkUniqSet GHC.Base.∘ (GHC.Base.map f GHC.Base.∘ nonDetEltsUniqSet).

Definition nonDetFoldUniqSet {elt} {a}
   : (elt -> a -> a) -> a -> UniqSet elt -> a :=
  fun arg_0__ arg_1__ arg_2__ =>
    match arg_0__, arg_1__, arg_2__ with
    | c, n, UniqSet s => UniqFM.nonDetFoldUFM c n s
    end.

Definition nonDetFoldUniqSet_Directly {elt} {a}
   : (Unique.Unique -> elt -> a -> a) -> a -> UniqSet elt -> a :=
  fun arg_0__ arg_1__ arg_2__ =>
    match arg_0__, arg_1__, arg_2__ with
    | f, n, UniqSet s => UniqFM.nonDetFoldUFM_Directly f n s
    end.

Definition nonDetKeysUniqSet {elt} : UniqSet elt -> list Unique.Unique :=
  UniqFM.nonDetKeysUFM GHC.Base.∘ getUniqSet'.

Definition partitionUniqSet {a}
   : (a -> bool) -> UniqSet a -> (UniqSet a * UniqSet a)%type :=
  fun arg_0__ arg_1__ =>
    match arg_0__, arg_1__ with
    | p, UniqSet s => GHC.Prim.coerce (UniqFM.partitionUFM p s)
    end.

Definition pprUniqSet {a}
   : (a -> GHC.Base.String) -> UniqSet a -> GHC.Base.String :=
  fun arg_0__ arg_1__ =>
    match arg_0__, arg_1__ with
    | f, UniqSet s => UniqFM.pprUniqFM f s
    end.

Definition restrictUniqSetToUFM {a} {b}
   : UniqSet a -> UniqFM.UniqFM b -> UniqSet a :=
  fun arg_0__ arg_1__ =>
    match arg_0__, arg_1__ with
    | UniqSet s, m => UniqSet (UniqFM.intersectUFM s m)
    end.

Definition sizeUniqSet {a} : UniqSet a -> GHC.Num.Int :=
  fun arg_0__ => let 'UniqSet s := arg_0__ in UniqFM.sizeUFM s.

Definition unionUniqSets {a} : UniqSet a -> UniqSet a -> UniqSet a :=
  fun arg_0__ arg_1__ =>
    match arg_0__, arg_1__ with
    | UniqSet s, UniqSet t => UniqSet (UniqFM.plusUFM s t)
    end.

Definition unionManyUniqSets {a} (xs : list (UniqSet a)) : UniqSet a :=
  match xs with
  | nil => emptyUniqSet
  | cons set sets => Data.Foldable.foldr unionUniqSets set sets
  end.

Definition uniqSetAll {a} : (a -> bool) -> UniqSet a -> bool :=
  fun arg_0__ arg_1__ =>
    match arg_0__, arg_1__ with
    | p, UniqSet s => UniqFM.allUFM p s
    end.

Definition uniqSetAny {a} : (a -> bool) -> UniqSet a -> bool :=
  fun arg_0__ arg_1__ =>
    match arg_0__, arg_1__ with
    | p, UniqSet s => UniqFM.anyUFM p s
    end.

Definition uniqSetMinusUFM {a} {b}
   : UniqSet a -> UniqFM.UniqFM b -> UniqSet a :=
  fun arg_0__ arg_1__ =>
    match arg_0__, arg_1__ with
    | UniqSet s, t => UniqSet (UniqFM.minusUFM s t)
    end.

Definition unitUniqSet {a} `{Unique.Uniquable a} : a -> UniqSet a :=
  fun x => UniqSet (UniqFM.unitUFM x x).

Definition unsafeUFMToUniqSet {a} : UniqFM.UniqFM a -> UniqSet a :=
  UniqSet.

(* External variables:
     bool cons list negb op_zt__ option Data.Foldable.foldl' Data.Foldable.foldr
     GHC.Base.Eq_ GHC.Base.Monoid GHC.Base.Semigroup GHC.Base.String GHC.Base.map
     GHC.Base.mappend GHC.Base.mconcat GHC.Base.mempty GHC.Base.op_z2218U__
     GHC.Base.op_zlzlzgzg__ GHC.Num.Int GHC.Prim.coerce UniqFM.UniqFM UniqFM.addToUFM
     UniqFM.allUFM UniqFM.anyUFM UniqFM.delFromUFM UniqFM.delFromUFM_Directly
     UniqFM.delListFromUFM UniqFM.delListFromUFM_Directly UniqFM.elemUFM
     UniqFM.elemUFM_Directly UniqFM.emptyUFM UniqFM.equalKeysUFM UniqFM.filterUFM
     UniqFM.filterUFM_Directly UniqFM.intersectUFM UniqFM.isNullUFM UniqFM.lookupUFM
     UniqFM.lookupUFM_Directly UniqFM.minusUFM UniqFM.nonDetEltsUFM
     UniqFM.nonDetFoldUFM UniqFM.nonDetFoldUFM_Directly UniqFM.nonDetKeysUFM
     UniqFM.partitionUFM UniqFM.plusUFM UniqFM.pprUniqFM UniqFM.sizeUFM
     UniqFM.unitUFM Unique.Uniquable Unique.Unique
*)
