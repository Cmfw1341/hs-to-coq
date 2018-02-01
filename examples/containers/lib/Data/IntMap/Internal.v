(* Default settings (from HsToCoq.Coq.Preamble) *)

Generalizable All Variables.

Unset Implicit Arguments.
Set Maximal Implicit Insertion.
Unset Strict Implicit.
Unset Printing Implicit Defensive.

Require Coq.Program.Tactics.
Require Coq.Program.Wf.

(* Converted imports: *)

Require Data.Bits.
Require Data.Either.
Require Data.Foldable.
Require Data.Functor.
Require Data.Functor.Identity.
Require Data.IntSet.Internal.
Require Data.Maybe.
Require Data.Traversable.
Require GHC.Base.
Require GHC.Num.
Require GHC.Real.
Require Utils.Containers.Internal.BitUtil.
Import Data.Bits.Notations.
Import Data.Functor.Notations.
Import GHC.Base.Notations.
Import GHC.Num.Notations.

(* Converted type declarations: *)

Inductive WhenMatched f x y z : Type := Mk_WhenMatched
                                       : (Data.IntSet.Internal.Key -> x -> y -> f (option z)) -> WhenMatched f x y z.

Definition SimpleWhenMatched :=
  (WhenMatched Data.Functor.Identity.Identity)%type.

Definition Prefix :=
  GHC.Num.Int%type.

Definition Nat :=
  GHC.Num.Word%type.

Definition Mask :=
  GHC.Num.Int%type.

Definition IntSetPrefix :=
  GHC.Num.Int%type.

Definition IntSetBitMap :=
  GHC.Num.Word%type.

Inductive IntMap a : Type := Bin : Prefix -> Mask -> (IntMap a) -> (IntMap
                                   a) -> IntMap a
                          |  Tip : Data.IntSet.Internal.Key -> a -> IntMap a
                          |  Nil : IntMap a.

Inductive SplitLookup a : Type := Mk_SplitLookup : (IntMap a) -> (option
                                                   a) -> (IntMap a) -> SplitLookup a.

Inductive Stack a : Type := Push : Prefix -> (IntMap a) -> (Stack a) -> Stack a
                         |  Nada : Stack a.

Inductive View a : Type := Mk_View : Data.IntSet.Internal.Key -> a -> (IntMap
                                     a) -> View a.

Inductive WhenMissing f x y : Type := Mk_WhenMissing : (IntMap x -> f (IntMap
                                                                      y)) -> (Data.IntSet.Internal.Key -> x -> f (option
                                                                                                                 y)) -> WhenMissing
                                                       f x y.

Definition SimpleWhenMissing :=
  (WhenMissing Data.Functor.Identity.Identity)%type.

Arguments Mk_WhenMatched {_} {_} {_} {_} _.

Arguments Bin {_} _ _ _ _.

Arguments Tip {_} _ _.

Arguments Nil {_}.

Arguments Mk_SplitLookup {_} _ _ _.

Arguments Push {_} _ _ _.

Arguments Nada {_}.

Arguments Mk_View {_} _ _ _.

Arguments Mk_WhenMissing {_} {_} {_} _ _.

Definition matchedKey {f} {x} {y} {z} (arg_0__ : WhenMatched f x y z) :=
  match arg_0__ with
    | Mk_WhenMatched matchedKey => matchedKey
  end.

Definition missingKey {f} {x} {y} (arg_1__ : WhenMissing f x y) :=
  match arg_1__ with
    | Mk_WhenMissing _ missingKey => missingKey
  end.

Definition missingSubtree {f} {x} {y} (arg_2__ : WhenMissing f x y) :=
  match arg_2__ with
    | Mk_WhenMissing missingSubtree _ => missingSubtree
  end.

(* The Haskell code containes partial or untranslateable code, which needs the
   following *)

Axiom missingValue : forall {a}, a.

Axiom patternFailure : forall {a}, a.

Axiom unsafeFix : forall {a}, (a -> a) -> a.
(* Midamble *)

Require GHC.Err.

Instance Default_Map {a} : Err.Default (IntMap a) := {| Err.default := Nil |}.

Fixpoint IntMap_op_zlzd__ {a} {b} (x: a) (m: IntMap b): IntMap a :=
      match x , m with
        | a , Bin p m l r => Bin p m (IntMap_op_zlzd__ a l)
                                (IntMap_op_zlzd__ a r)
        | a , Tip k _ => Tip k a
        | _ , Nil => Nil
      end.

(* Converted value declarations: *)

(* Skipping instance Monoid__IntMap *)

(* Translating `instance forall {a}, Data.Semigroup.Semigroup
   (Data.IntMap.Internal.IntMap a)' failed: OOPS! Cannot find information for class
   Qualified "Data.Semigroup" "Semigroup" unsupported *)

Local Definition Foldable__IntMap_elem : forall {a},
                                           forall `{GHC.Base.Eq_ a}, a -> IntMap a -> bool :=
  fun {a} `{GHC.Base.Eq_ a} =>
    let fix go arg_0__ arg_1__
              := match arg_0__ , arg_1__ with
                   | _ , Nil => false
                   | x , Tip _ y => x GHC.Base.== y
                   | x , Bin _ _ l r => orb (go x l) (go x r)
                 end in
    go.

Local Definition Foldable__IntMap_fold : forall {m},
                                           forall `{GHC.Base.Monoid m}, IntMap m -> m :=
  fun {m} `{GHC.Base.Monoid m} =>
    let fix go arg_0__
              := match arg_0__ with
                   | Nil => GHC.Base.mempty
                   | Tip _ v => v
                   | Bin _ _ l r => GHC.Base.mappend (go l) (go r)
                 end in
    go.

Local Definition Foldable__IntMap_foldMap : forall {m} {a},
                                              forall `{GHC.Base.Monoid m}, (a -> m) -> IntMap a -> m :=
  fun {m} {a} `{GHC.Base.Monoid m} =>
    fun f t =>
      let fix go arg_0__
                := match arg_0__ with
                     | Nil => GHC.Base.mempty
                     | Tip _ v => f v
                     | Bin _ _ l r => GHC.Base.mappend (go l) (go r)
                   end in
      go t.

(* Translating `instance forall {a}, forall `{Control.DeepSeq.NFData a},
   Control.DeepSeq.NFData (Data.IntMap.Internal.IntMap a)' failed: OOPS! Cannot
   find information for class Qualified "Control.DeepSeq" "NFData" unsupported *)

(* Translating `instance forall {a}, forall `{Data.Data.Data a}, Data.Data.Data
   (Data.IntMap.Internal.IntMap a)' failed: OOPS! Cannot find information for class
   Qualified "Data.Data" "Data" unsupported *)

(* Skipping instance Functor__WhenMissing *)

(* Skipping instance Category__WhenMissing *)

(* Skipping instance Applicative__WhenMissing *)

(* Skipping instance Monad__WhenMissing *)

(* Skipping instance Functor__WhenMatched *)

(* Skipping instance Category__WhenMatched *)

(* Skipping instance Applicative__WhenMatched *)

(* Skipping instance Monad__WhenMatched *)

(* Translating `instance forall {a}, GHC.Exts.IsList
   (Data.IntMap.Internal.IntMap a)' failed: OOPS! Cannot find information for class
   Qualified "GHC.Exts" "IsList" unsupported *)

(* Translating `instance Data.Functor.Classes.Eq1 Data.IntMap.Internal.IntMap'
   failed: OOPS! Cannot find information for class Qualified "Data.Functor.Classes"
   "Eq1" unsupported *)

(* Translating `instance Data.Functor.Classes.Ord1 Data.IntMap.Internal.IntMap'
   failed: OOPS! Cannot find information for class Qualified "Data.Functor.Classes"
   "Ord1" unsupported *)

Definition Functor__IntMap_op_zlzd__ {a} {b} :=
  (@IntMap_op_zlzd__ a b).

(* Translating `instance forall {a}, forall `{GHC.Show.Show a}, GHC.Show.Show
   (Data.IntMap.Internal.IntMap a)' failed: OOPS! Cannot find information for class
   Qualified "GHC.Show" "Show" unsupported *)

(* Translating `instance Data.Functor.Classes.Show1 Data.IntMap.Internal.IntMap'
   failed: OOPS! Cannot find information for class Qualified "Data.Functor.Classes"
   "Show1" unsupported *)

(* Translating `instance forall {e}, forall `{(GHC.Read.Read e)}, GHC.Read.Read
   (Data.IntMap.Internal.IntMap e)' failed: OOPS! Cannot find information for class
   Qualified "GHC.Read" "Read" unsupported *)

(* Translating `instance Data.Functor.Classes.Read1 Data.IntMap.Internal.IntMap'
   failed: OOPS! Cannot find information for class Qualified "Data.Functor.Classes"
   "Read1" unsupported *)

Definition bin {a} : Prefix -> Mask -> IntMap a -> IntMap a -> IntMap a :=
  fun arg_0__ arg_1__ arg_2__ arg_3__ =>
    match arg_0__ , arg_1__ , arg_2__ , arg_3__ with
      | _ , _ , l , Nil => l
      | _ , _ , Nil , r => r
      | p , m , l , r => Bin p m l r
    end.

Definition filterWithKey {a} : (Data.IntSet.Internal.Key -> a -> bool) -> IntMap
                               a -> IntMap a :=
  fun predicate =>
    let fix go arg_0__
              := match arg_0__ with
                   | Nil => Nil
                   | (Tip k x as t) => if predicate k x : bool
                                       then t
                                       else Nil
                   | Bin p m l r => bin p m (go l) (go r)
                 end in
    go.

Definition filter {a} : (a -> bool) -> IntMap a -> IntMap a :=
  fun p m =>
    filterWithKey (fun arg_0__ arg_1__ =>
                    match arg_0__ , arg_1__ with
                      | _ , x => p x
                    end) m.

Definition filterWithKeyA {f} {a} `{GHC.Base.Applicative f}
    : (Data.IntSet.Internal.Key -> a -> f bool) -> IntMap a -> f (IntMap a) :=
  fix filterWithKeyA arg_0__ arg_1__
        := match arg_0__ , arg_1__ with
             | _ , Nil => GHC.Base.pure Nil
             | f , (Tip k x as t) => (fun b => if b : bool then t else Nil) Data.Functor.<$>
                                     f k x
             | f , Bin p m l r => GHC.Base.liftA2 (bin p m) (filterWithKeyA f l)
                                  (filterWithKeyA f r)
           end.

Definition mapEitherWithKey {a} {b} {c}
    : (Data.IntSet.Internal.Key -> a -> Data.Either.Either b c) -> IntMap
      a -> (IntMap b * IntMap c)%type :=
  fun f0 t0 =>
    let fix go arg_0__ arg_1__
              := match arg_0__ , arg_1__ with
                   | f , Bin p m l r => match go f r with
                                          | pair r1 r2 => match go f l with
                                                            | pair l1 l2 => pair (bin p m l1 r1) (bin p m l2 r2)
                                                          end
                                        end
                   | f , Tip k x => match f k x with
                                      | Data.Either.Left y => (pair (Tip k y) Nil)
                                      | Data.Either.Right z => (pair Nil (Tip k z))
                                    end
                   | _ , Nil => (pair Nil Nil)
                 end in
    id GHC.Base.$ go f0 t0.

Definition mapEither {a} {b} {c} : (a -> Data.Either.Either b c) -> IntMap
                                   a -> (IntMap b * IntMap c)%type :=
  fun f m =>
    mapEitherWithKey (fun arg_0__ arg_1__ =>
                       match arg_0__ , arg_1__ with
                         | _ , x => f x
                       end) m.

Definition mapMaybeWithKey {a} {b} : (Data.IntSet.Internal.Key -> a -> option
                                     b) -> IntMap a -> IntMap b :=
  fix mapMaybeWithKey arg_0__ arg_1__
        := match arg_0__ , arg_1__ with
             | f , Bin p m l r => bin p m (mapMaybeWithKey f l) (mapMaybeWithKey f r)
             | f , Tip k x => match f k x with
                                | Some y => Tip k y
                                | None => Nil
                              end
             | _ , Nil => Nil
           end.

Definition mapMaybe {a} {b} : (a -> option b) -> IntMap a -> IntMap b :=
  fun f =>
    mapMaybeWithKey (fun arg_0__ arg_1__ =>
                      match arg_0__ , arg_1__ with
                        | _ , x => f x
                      end).

Definition partitionWithKey {a}
    : (Data.IntSet.Internal.Key -> a -> bool) -> IntMap a -> (IntMap a * IntMap
      a)%type :=
  fun predicate0 t0 =>
    let fix go predicate t
              := match t with
                   | Bin p m l r => match go predicate r with
                                      | pair r1 r2 => match go predicate l with
                                                        | pair l1 l2 => pair (bin p m l1 r1) (bin p m l2 r2)
                                                      end
                                    end
                   | Tip k x => if predicate k x : bool
                                then (pair t Nil)
                                else (pair Nil t)
                   | Nil => (pair Nil Nil)
                 end in
    id GHC.Base.$ go predicate0 t0.

Definition partition {a} : (a -> bool) -> IntMap a -> (IntMap a * IntMap
                           a)%type :=
  fun p m =>
    partitionWithKey (fun arg_0__ arg_1__ =>
                       match arg_0__ , arg_1__ with
                         | _ , x => p x
                       end) m.

Definition traverseMaybeWithKey {f} {a} {b} `{GHC.Base.Applicative f}
    : (Data.IntSet.Internal.Key -> a -> f (option b)) -> IntMap a -> f (IntMap b) :=
  fun f =>
    let fix go arg_0__
              := match arg_0__ with
                   | Nil => GHC.Base.pure Nil
                   | Tip k x => Data.Maybe.maybe Nil (Tip k) Data.Functor.<$> f k x
                   | Bin p m l r => GHC.Base.liftA2 (bin p m) (go l) (go r)
                 end in
    go.

Definition binCheckLeft {a} : Prefix -> Mask -> IntMap a -> IntMap a -> IntMap
                              a :=
  fun arg_0__ arg_1__ arg_2__ arg_3__ =>
    match arg_0__ , arg_1__ , arg_2__ , arg_3__ with
      | _ , _ , Nil , r => r
      | p , m , l , r => Bin p m l r
    end.

Definition binCheckRight {a} : Prefix -> Mask -> IntMap a -> IntMap a -> IntMap
                               a :=
  fun arg_0__ arg_1__ arg_2__ arg_3__ =>
    match arg_0__ , arg_1__ , arg_2__ , arg_3__ with
      | _ , _ , l , Nil => l
      | p , m , l , r => Bin p m l r
    end.

Definition bitmapOf : GHC.Num.Int -> IntSetBitMap :=
  fun x =>
    Utils.Containers.Internal.BitUtil.shiftLL (GHC.Num.fromInteger 1) (x
                                                                      Data.Bits..&.(**)
                                                                      Data.IntSet.Internal.suffixBitMask).

Definition boolITE {a} : a -> a -> bool -> a :=
  fun arg_0__ arg_1__ arg_2__ =>
    match arg_0__ , arg_1__ , arg_2__ with
      | f , _ , false => f
      | _ , t , true => t
    end.

Definition dropMissing {f} {x} {y} `{GHC.Base.Applicative f} : WhenMissing f x
                                                               y :=
  Mk_WhenMissing missingValue missingValue.

Definition empty {a} : IntMap a :=
  Nil.

Definition equal {a} `{GHC.Base.Eq_ a} : IntMap a -> IntMap a -> bool :=
  fix equal arg_0__ arg_1__
        := match arg_0__ , arg_1__ with
             | Bin p1 m1 l1 r1 , Bin p2 m2 l2 r2 => andb (m1 GHC.Base.== m2) (andb (p1
                                                                                   GHC.Base.== p2) (andb (equal l1 l2)
                                                                                                         (equal r1 r2)))
             | Tip kx x , Tip ky y => andb (kx GHC.Base.== ky) (x GHC.Base.== y)
             | Nil , Nil => true
             | _ , _ => false
           end.

Local Definition Eq___IntMap_op_zeze__ {inst_a} `{GHC.Base.Eq_ inst_a} : (IntMap
                                                                         inst_a) -> (IntMap inst_a) -> bool :=
  fun t1 t2 => equal t1 t2.

Definition filterAMissing {f} {x} `{GHC.Base.Applicative f}
    : (Data.IntSet.Internal.Key -> x -> f bool) -> WhenMissing f x x :=
  fun f => Mk_WhenMissing missingValue missingValue.

Definition filterMissing {f} {x} `{GHC.Base.Applicative f}
    : (Data.IntSet.Internal.Key -> x -> bool) -> WhenMissing f x x :=
  fun f => Mk_WhenMissing missingValue missingValue.

Definition foldMapWithKey {m} {a} `{GHC.Base.Monoid m}
    : (Data.IntSet.Internal.Key -> a -> m) -> IntMap a -> m :=
  fun f =>
    let fix go arg_0__
              := match arg_0__ with
                   | Nil => GHC.Base.mempty
                   | Tip kx x => f kx x
                   | Bin _ _ l r => GHC.Base.mappend (go l) (go r)
                 end in
    go.

Definition foldl {a} {b} : (a -> b -> a) -> a -> IntMap b -> a :=
  fun f z =>
    let fix go arg_0__ arg_1__
              := match arg_0__ , arg_1__ with
                   | z' , Nil => z'
                   | z' , Tip _ x => f z' x
                   | z' , Bin _ _ l r => go (go z' l) r
                 end in
    fun t =>
      let j_6__ := go z t in
      match t with
        | Bin _ m l r => if m GHC.Base.< GHC.Num.fromInteger 0 : bool
                         then go (go z r) l
                         else go (go z l) r
        | _ => j_6__
      end.

Local Definition Foldable__IntMap_foldl : forall {b} {a},
                                            (b -> a -> b) -> b -> IntMap a -> b :=
  fun {b} {a} => foldl.

Definition foldl' {a} {b} : (a -> b -> a) -> a -> IntMap b -> a :=
  fun f z =>
    let fix go arg_0__ arg_1__
              := match arg_0__ , arg_1__ with
                   | z' , Nil => z'
                   | z' , Tip _ x => f z' x
                   | z' , Bin _ _ l r => go (go z' l) r
                 end in
    fun t =>
      let j_6__ := go z t in
      match t with
        | Bin _ m l r => if m GHC.Base.< GHC.Num.fromInteger 0 : bool
                         then go (go z r) l
                         else go (go z l) r
        | _ => j_6__
      end.

Local Definition Foldable__IntMap_sum : forall {a},
                                          forall `{GHC.Num.Num a}, IntMap a -> a :=
  fun {a} `{GHC.Num.Num a} => foldl' _GHC.Num.+_ (GHC.Num.fromInteger 0).

Local Definition Foldable__IntMap_product : forall {a},
                                              forall `{GHC.Num.Num a}, IntMap a -> a :=
  fun {a} `{GHC.Num.Num a} => foldl' _GHC.Num.*_ (GHC.Num.fromInteger 1).

Local Definition Foldable__IntMap_foldl' : forall {b} {a},
                                             (b -> a -> b) -> b -> IntMap a -> b :=
  fun {b} {a} => foldl'.

Definition foldlWithKey {a} {b}
    : (a -> Data.IntSet.Internal.Key -> b -> a) -> a -> IntMap b -> a :=
  fun f z =>
    let fix go arg_0__ arg_1__
              := match arg_0__ , arg_1__ with
                   | z' , Nil => z'
                   | z' , Tip kx x => f z' kx x
                   | z' , Bin _ _ l r => go (go z' l) r
                 end in
    fun t =>
      let j_6__ := go z t in
      match t with
        | Bin _ m l r => if m GHC.Base.< GHC.Num.fromInteger 0 : bool
                         then go (go z r) l
                         else go (go z l) r
        | _ => j_6__
      end.

Definition toDescList {a} : IntMap a -> list (Data.IntSet.Internal.Key *
                                             a)%type :=
  foldlWithKey (fun xs k x => cons (pair k x) xs) nil.

Definition foldlFB {a} {b}
    : (a -> Data.IntSet.Internal.Key -> b -> a) -> a -> IntMap b -> a :=
  foldlWithKey.

Definition foldlWithKey' {a} {b}
    : (a -> Data.IntSet.Internal.Key -> b -> a) -> a -> IntMap b -> a :=
  fun f z =>
    let fix go arg_0__ arg_1__
              := match arg_0__ , arg_1__ with
                   | z' , Nil => z'
                   | z' , Tip kx x => f z' kx x
                   | z' , Bin _ _ l r => go (go z' l) r
                 end in
    fun t =>
      let j_6__ := go z t in
      match t with
        | Bin _ m l r => if m GHC.Base.< GHC.Num.fromInteger 0 : bool
                         then go (go z r) l
                         else go (go z l) r
        | _ => j_6__
      end.

Definition foldr {a} {b} : (a -> b -> b) -> b -> IntMap a -> b :=
  fun f z =>
    let fix go arg_0__ arg_1__
              := match arg_0__ , arg_1__ with
                   | z' , Nil => z'
                   | z' , Tip _ x => f x z'
                   | z' , Bin _ _ l r => go (go z' r) l
                 end in
    fun t =>
      let j_6__ := go z t in
      match t with
        | Bin _ m l r => if m GHC.Base.< GHC.Num.fromInteger 0 : bool
                         then go (go z l) r
                         else go (go z r) l
        | _ => j_6__
      end.

Definition elems {a} : IntMap a -> list a :=
  foldr cons nil.

Local Definition Foldable__IntMap_toList : forall {a}, IntMap a -> list a :=
  fun {a} => elems.

Local Definition Foldable__IntMap_foldr : forall {a} {b},
                                            (a -> b -> b) -> b -> IntMap a -> b :=
  fun {a} {b} => foldr.

Definition foldr' {a} {b} : (a -> b -> b) -> b -> IntMap a -> b :=
  fun f z =>
    let fix go arg_0__ arg_1__
              := match arg_0__ , arg_1__ with
                   | z' , Nil => z'
                   | z' , Tip _ x => f x z'
                   | z' , Bin _ _ l r => go (go z' r) l
                 end in
    fun t =>
      let j_6__ := go z t in
      match t with
        | Bin _ m l r => if m GHC.Base.< GHC.Num.fromInteger 0 : bool
                         then go (go z l) r
                         else go (go z r) l
        | _ => j_6__
      end.

Local Definition Foldable__IntMap_foldr' : forall {a} {b},
                                             (a -> b -> b) -> b -> IntMap a -> b :=
  fun {a} {b} => foldr'.

Definition foldrWithKey {a} {b}
    : (Data.IntSet.Internal.Key -> a -> b -> b) -> b -> IntMap a -> b :=
  fun f z =>
    let fix go arg_0__ arg_1__
              := match arg_0__ , arg_1__ with
                   | z' , Nil => z'
                   | z' , Tip kx x => f kx x z'
                   | z' , Bin _ _ l r => go (go z' r) l
                 end in
    fun t =>
      let j_6__ := go z t in
      match t with
        | Bin _ m l r => if m GHC.Base.< GHC.Num.fromInteger 0 : bool
                         then go (go z l) r
                         else go (go z r) l
        | _ => j_6__
      end.

Definition keys {a} : IntMap a -> list Data.IntSet.Internal.Key :=
  foldrWithKey (fun arg_0__ arg_1__ arg_2__ =>
                 match arg_0__ , arg_1__ , arg_2__ with
                   | k , _ , ks => cons k ks
                 end) nil.

Definition toAscList {a} : IntMap a -> list (Data.IntSet.Internal.Key *
                                            a)%type :=
  foldrWithKey (fun k x xs => cons (pair k x) xs) nil.

Definition toList {a} : IntMap a -> list (Data.IntSet.Internal.Key * a)%type :=
  toAscList.

Local Definition Ord__IntMap_compare {inst_a} `{GHC.Base.Ord inst_a} : (IntMap
                                                                       inst_a) -> (IntMap inst_a) -> comparison :=
  fun m1 m2 => GHC.Base.compare (toList m1) (toList m2).

Local Definition Ord__IntMap_op_zg__ {inst_a} `{GHC.Base.Ord inst_a} : (IntMap
                                                                       inst_a) -> (IntMap inst_a) -> bool :=
  fun x y => _GHC.Base.==_ (Ord__IntMap_compare x y) Gt.

Local Definition Ord__IntMap_op_zgze__ {inst_a} `{GHC.Base.Ord inst_a} : (IntMap
                                                                         inst_a) -> (IntMap inst_a) -> bool :=
  fun x y => _GHC.Base./=_ (Ord__IntMap_compare x y) Lt.

Local Definition Ord__IntMap_op_zl__ {inst_a} `{GHC.Base.Ord inst_a} : (IntMap
                                                                       inst_a) -> (IntMap inst_a) -> bool :=
  fun x y => _GHC.Base.==_ (Ord__IntMap_compare x y) Lt.

Local Definition Ord__IntMap_op_zlze__ {inst_a} `{GHC.Base.Ord inst_a} : (IntMap
                                                                         inst_a) -> (IntMap inst_a) -> bool :=
  fun x y => _GHC.Base./=_ (Ord__IntMap_compare x y) Gt.

Local Definition Ord__IntMap_max {inst_a} `{GHC.Base.Ord inst_a} : (IntMap
                                                                   inst_a) -> (IntMap inst_a) -> (IntMap inst_a) :=
  fun x y => if Ord__IntMap_op_zlze__ x y : bool then y else x.

Local Definition Ord__IntMap_min {inst_a} `{GHC.Base.Ord inst_a} : (IntMap
                                                                   inst_a) -> (IntMap inst_a) -> (IntMap inst_a) :=
  fun x y => if Ord__IntMap_op_zlze__ x y : bool then x else y.

Definition assocs {a} : IntMap a -> list (Data.IntSet.Internal.Key * a)%type :=
  toAscList.

Definition foldrFB {a} {b}
    : (Data.IntSet.Internal.Key -> a -> b -> b) -> b -> IntMap a -> b :=
  foldrWithKey.

Definition foldrWithKey' {a} {b}
    : (Data.IntSet.Internal.Key -> a -> b -> b) -> b -> IntMap a -> b :=
  fun f z =>
    let fix go arg_0__ arg_1__
              := match arg_0__ , arg_1__ with
                   | z' , Nil => z'
                   | z' , Tip kx x => f kx x z'
                   | z' , Bin _ _ l r => go (go z' r) l
                 end in
    fun t =>
      let j_6__ := go z t in
      match t with
        | Bin _ m l r => if m GHC.Base.< GHC.Num.fromInteger 0 : bool
                         then go (go z l) r
                         else go (go z r) l
        | _ => j_6__
      end.

Definition keysSet {a} : IntMap a -> Data.IntSet.Internal.IntSet :=
  fix keysSet arg_0__
        := match arg_0__ with
             | Nil => Data.IntSet.Internal.Nil
             | Tip kx _ => Data.IntSet.Internal.singleton kx
             | Bin p m l r => let fix computeBm arg_2__ arg_3__
                                        := match arg_2__ , arg_3__ with
                                             | acc , Bin _ _ l' r' => computeBm (computeBm acc l') r'
                                             | acc , Tip kx _ => acc Data.Bits..|.(**) Data.IntSet.Internal.bitmapOf kx
                                             | _ , Nil => GHC.Err.error (GHC.Base.hs_string__
                                                                        "Data.IntSet.keysSet: Nil")
                                           end in
                              if (m Data.Bits..&.(**) Data.IntSet.Internal.suffixBitMask) GHC.Base.==
                                 GHC.Num.fromInteger 0 : bool
                              then Data.IntSet.Internal.Bin p m (keysSet l) (keysSet r)
                              else Data.IntSet.Internal.Tip (p Data.Bits..&.(**)
                                                            Data.IntSet.Internal.prefixBitMask) (computeBm (computeBm
                                                                                                           (GHC.Num.fromInteger
                                                                                                           0) l) r)
           end.

Definition lmapWhenMissing {b} {a} {f} {x} : (b -> a) -> WhenMissing f a
                                             x -> WhenMissing f b x :=
  fun f t => Mk_WhenMissing missingValue missingValue.

Definition lookupMax {a} : IntMap a -> option (Data.IntSet.Internal.Key *
                                              a)%type :=
  fun arg_0__ =>
    match arg_0__ with
      | Nil => None
      | Tip k v => Some (pair k v)
      | Bin _ m l r => let fix go arg_2__
                                 := match arg_2__ with
                                      | Tip k v => Some (pair k v)
                                      | Bin _ _ _ r' => go r'
                                      | Nil => None
                                    end in
                       if m GHC.Base.< GHC.Num.fromInteger 0 : bool
                       then go l
                       else go r
    end.

Definition lookupMin {a} : IntMap a -> option (Data.IntSet.Internal.Key *
                                              a)%type :=
  fun arg_0__ =>
    match arg_0__ with
      | Nil => None
      | Tip k v => Some (pair k v)
      | Bin _ m l r => let fix go arg_2__
                                 := match arg_2__ with
                                      | Tip k v => Some (pair k v)
                                      | Bin _ _ l' _ => go l'
                                      | Nil => None
                                    end in
                       if m GHC.Base.< GHC.Num.fromInteger 0 : bool
                       then go r
                       else go l
    end.

Definition map {a} {b} : (a -> b) -> IntMap a -> IntMap b :=
  fun f =>
    let fix go arg_0__
              := match arg_0__ with
                   | Bin p m l r => Bin p m (go l) (go r)
                   | Tip k x => Tip k (f x)
                   | Nil => Nil
                 end in
    go.

Local Definition Functor__IntMap_fmap : forall {a} {b},
                                          (a -> b) -> IntMap a -> IntMap b :=
  fun {a} {b} => map.

Program Instance Functor__IntMap : GHC.Base.Functor IntMap := fun _ k =>
    k {|GHC.Base.op_zlzd____ := fun {a} {b} => Functor__IntMap_op_zlzd__ ;
      GHC.Base.fmap__ := fun {a} {b} => Functor__IntMap_fmap |}.
Admit Obligations.

Definition mapAccumL {a} {b} {c} : (a -> Data.IntSet.Internal.Key -> b -> (a *
                                   c)%type) -> a -> IntMap b -> (a * IntMap c)%type :=
  fix mapAccumL f a t
        := match t with
             | Bin p m l r => match mapAccumL f a l with
                                | pair a1 l' => match mapAccumL f a1 r with
                                                  | pair a2 r' => pair a2 (Bin p m l' r')
                                                end
                              end
             | Tip k x => match f a k x with
                            | pair a' x' => pair a' (Tip k x')
                          end
             | Nil => pair a Nil
           end.

Definition mapAccumWithKey {a} {b} {c}
    : (a -> Data.IntSet.Internal.Key -> b -> (a * c)%type) -> a -> IntMap b -> (a *
      IntMap c)%type :=
  fun f a t => mapAccumL f a t.

Definition mapAccum {a} {b} {c} : (a -> b -> (a * c)%type) -> a -> IntMap
                                  b -> (a * IntMap c)%type :=
  fun f =>
    mapAccumWithKey (fun arg_0__ arg_1__ arg_2__ =>
                      match arg_0__ , arg_1__ , arg_2__ with
                        | a' , _ , x => f a' x
                      end).

Definition mapAccumRWithKey {a} {b} {c}
    : (a -> Data.IntSet.Internal.Key -> b -> (a * c)%type) -> a -> IntMap b -> (a *
      IntMap c)%type :=
  fix mapAccumRWithKey f a t
        := match t with
             | Bin p m l r => match mapAccumRWithKey f a r with
                                | pair a1 r' => match mapAccumRWithKey f a1 l with
                                                  | pair a2 l' => pair a2 (Bin p m l' r')
                                                end
                              end
             | Tip k x => match f a k x with
                            | pair a' x' => pair a' (Tip k x')
                          end
             | Nil => pair a Nil
           end.

Definition mapGT {a} : (IntMap a -> IntMap a) -> SplitLookup a -> SplitLookup
                       a :=
  fun arg_0__ arg_1__ =>
    match arg_0__ , arg_1__ with
      | f , Mk_SplitLookup lt fnd gt => Mk_SplitLookup lt fnd (f gt)
    end.

Definition mapGentlyWhenMissing {f} {a} {b} {x} `{GHC.Base.Functor f}
    : (a -> b) -> WhenMissing f x a -> WhenMissing f x b :=
  fun f t => Mk_WhenMissing missingValue missingValue.

Definition mapLT {a} : (IntMap a -> IntMap a) -> SplitLookup a -> SplitLookup
                       a :=
  fun arg_0__ arg_1__ =>
    match arg_0__ , arg_1__ with
      | f , Mk_SplitLookup lt fnd gt => Mk_SplitLookup (f lt) fnd gt
    end.

Definition mapMaybeMissing {f} {x} {y} `{GHC.Base.Applicative f}
    : (Data.IntSet.Internal.Key -> x -> option y) -> WhenMissing f x y :=
  fun f => Mk_WhenMissing missingValue missingValue.

Definition mapMissing {f} {x} {y} `{GHC.Base.Applicative f}
    : (Data.IntSet.Internal.Key -> x -> y) -> WhenMissing f x y :=
  fun f => Mk_WhenMissing missingValue missingValue.

Definition mapWhenMatched {f} {a} {b} {x} {y} `{GHC.Base.Functor f}
    : (a -> b) -> WhenMatched f x y a -> WhenMatched f x y b :=
  fun arg_0__ arg_1__ =>
    match arg_0__ , arg_1__ with
      | f , Mk_WhenMatched g => Mk_WhenMatched GHC.Base.$ (fun k x y =>
                                  GHC.Base.fmap (GHC.Base.fmap f) (g k x y))
    end.

Definition mapWhenMissing {f} {a} {b} {x} `{GHC.Base.Applicative f}
                          `{GHC.Base.Monad f} : (a -> b) -> WhenMissing f x a -> WhenMissing f x b :=
  fun f t => Mk_WhenMissing missingValue missingValue.

Definition mapWithKey {a} {b} : (Data.IntSet.Internal.Key -> a -> b) -> IntMap
                                a -> IntMap b :=
  fix mapWithKey f t
        := match t with
             | Bin p m l r => Bin p m (mapWithKey f l) (mapWithKey f r)
             | Tip k x => Tip k (f k x)
             | Nil => Nil
           end.

Definition maskW : Nat -> Nat -> Prefix :=
  fun i m =>
    Coq.ZArith.BinInt.Z.of_N (i Data.Bits..&.(**) (Data.Bits.xor
                             (Data.Bits.complement (m GHC.Num.- GHC.Num.fromInteger 1)) m)).

Definition natFromInt : Data.IntSet.Internal.Key -> Nat :=
  GHC.Real.fromIntegral.

Definition shorter : Mask -> Mask -> bool :=
  fun m1 m2 => (natFromInt m1) GHC.Base.> (natFromInt m2).

Definition zero : Data.IntSet.Internal.Key -> Mask -> bool :=
  fun i m =>
    ((natFromInt i) Data.Bits..&.(**) (natFromInt m)) GHC.Base.==
    GHC.Num.fromInteger 0.

Definition mask : Data.IntSet.Internal.Key -> Mask -> Prefix :=
  fun i m => maskW (natFromInt i) (natFromInt m).

Definition match_ : Data.IntSet.Internal.Key -> Prefix -> Mask -> bool :=
  fun i p m => (mask i m) GHC.Base.== p.

Definition nomatch : Data.IntSet.Internal.Key -> Prefix -> Mask -> bool :=
  fun i p m => (mask i m) GHC.Base./= p.

Definition member {a} : Data.IntSet.Internal.Key -> IntMap a -> bool :=
  fun k =>
    let fix go arg_0__
              := match arg_0__ with
                   | Bin p m l r => if nomatch k p m : bool
                                    then false
                                    else if zero k m : bool
                                         then go l
                                         else go r
                   | Tip kx _ => k GHC.Base.== kx
                   | Nil => false
                 end in
    go.

Definition notMember {a} : Data.IntSet.Internal.Key -> IntMap a -> bool :=
  fun k m => negb GHC.Base.$ member k m.

Definition lookupPrefix {a} : IntSetPrefix -> IntMap a -> IntMap a :=
  fix lookupPrefix arg_0__ arg_1__
        := match arg_0__ , arg_1__ with
             | kp , (Bin p m l r as t) => if (m Data.Bits..&.(**)
                                             Data.IntSet.Internal.suffixBitMask) GHC.Base./= GHC.Num.fromInteger
                                             0 : bool
                                          then if (p Data.Bits..&.(**) Data.IntSet.Internal.prefixBitMask) GHC.Base.==
                                                  kp : bool
                                               then t
                                               else Nil
                                          else if nomatch kp p m : bool
                                               then Nil
                                               else if zero kp m : bool
                                                    then lookupPrefix kp l
                                                    else lookupPrefix kp r
             | kp , (Tip kx _ as t) => if (kx Data.Bits..&.(**)
                                          Data.IntSet.Internal.prefixBitMask) GHC.Base.== kp : bool
                                       then t
                                       else Nil
             | _ , Nil => Nil
           end.

Definition lookup {a} : Data.IntSet.Internal.Key -> IntMap a -> option a :=
  fun k =>
    let fix go arg_0__
              := match arg_0__ with
                   | Bin p m l r => if nomatch k p m : bool
                                    then None
                                    else if zero k m : bool
                                         then go l
                                         else go r
                   | Tip kx x => if k GHC.Base.== kx : bool
                                 then Some x
                                 else None
                   | Nil => None
                 end in
    go.

Definition op_znz3fU__ {a} : IntMap a -> Data.IntSet.Internal.Key -> option a :=
  fun m k => lookup k m.

Notation "'_!?_'" := (op_znz3fU__).

Infix "!?" := (_!?_) (at level 99).

Definition isSubmapOfBy {a} {b} : (a -> b -> bool) -> IntMap a -> IntMap
                                  b -> bool :=
  fix isSubmapOfBy arg_0__ arg_1__ arg_2__
        := let j_7__ :=
             match arg_0__ , arg_1__ , arg_2__ with
               | _ , Bin _ _ _ _ , _ => false
               | predicate , Tip k x , t => match lookup k t with
                                              | Some y => predicate x y
                                              | None => false
                                            end
               | _ , Nil , _ => true
             end in
           match arg_0__ , arg_1__ , arg_2__ with
             | predicate , (Bin p1 m1 l1 r1 as t1) , Bin p2 m2 l2 r2 => if shorter m1
                                                                           m2 : bool
                                                                        then false
                                                                        else if shorter m2 m1 : bool
                                                                             then andb (match_ p1 p2 m2) (if zero p1
                                                                                                             m2 : bool
                                                                                       then isSubmapOfBy predicate t1 l2
                                                                                       else isSubmapOfBy predicate t1
                                                                                            r2)
                                                                             else andb (p1 GHC.Base.== p2) (andb
                                                                                       (isSubmapOfBy predicate l1 l2)
                                                                                       (isSubmapOfBy predicate r1 r2))
             | _ , _ , _ => j_7__
           end.

Definition isSubmapOf {a} `{GHC.Base.Eq_ a} : IntMap a -> IntMap a -> bool :=
  fun m1 m2 => isSubmapOfBy _GHC.Base.==_ m1 m2.

Definition submapCmp {a} {b} : (a -> b -> bool) -> IntMap a -> IntMap
                               b -> comparison :=
  fix submapCmp arg_0__ arg_1__ arg_2__
        := let j_7__ :=
             match arg_0__ , arg_1__ , arg_2__ with
               | predicate , Tip k x , t => match lookup k t with
                                              | Some y => if predicate x y : bool
                                                          then Lt
                                                          else Gt
                                              | _ => Gt
                                            end
               | _ , Nil , Nil => Eq
               | _ , Nil , _ => Lt
               | _ , _ , _ => patternFailure
             end in
           let j_9__ :=
             match arg_0__ , arg_1__ , arg_2__ with
               | _ , Bin _ _ _ _ , _ => Gt
               | predicate , Tip kx x , Tip ky y => if andb (kx GHC.Base.== ky) (predicate x
                                                            y) : bool
                                                    then Eq
                                                    else Gt
               | _ , _ , _ => j_7__
             end in
           match arg_0__ , arg_1__ , arg_2__ with
             | predicate , (Bin p1 m1 l1 r1 as t1) , Bin p2 m2 l2 r2 => let submapCmpEq :=
                                                                          match pair (submapCmp predicate l1 l2)
                                                                                     (submapCmp predicate r1 r2) with
                                                                            | pair Gt _ => Gt
                                                                            | pair _ Gt => Gt
                                                                            | pair Eq Eq => Eq
                                                                            | _ => Lt
                                                                          end in
                                                                        let submapCmpLt :=
                                                                          if nomatch p1 p2 m2 : bool
                                                                          then Gt
                                                                          else if zero p1 m2 : bool
                                                                               then submapCmp predicate t1 l2
                                                                               else submapCmp predicate t1 r2 in
                                                                        if shorter m1 m2 : bool
                                                                        then Gt
                                                                        else if shorter m2 m1 : bool
                                                                             then submapCmpLt
                                                                             else if p1 GHC.Base.== p2 : bool
                                                                                  then submapCmpEq
                                                                                  else Gt
             | _ , _ , _ => j_9__
           end.

Definition isProperSubmapOfBy {a} {b} : (a -> b -> bool) -> IntMap a -> IntMap
                                        b -> bool :=
  fun predicate t1 t2 =>
    match submapCmp predicate t1 t2 with
      | Lt => true
      | _ => false
    end.

Definition isProperSubmapOf {a} `{GHC.Base.Eq_ a} : IntMap a -> IntMap
                                                    a -> bool :=
  fun m1 m2 => isProperSubmapOfBy _GHC.Base.==_ m1 m2.

Definition findWithDefault {a} : a -> Data.IntSet.Internal.Key -> IntMap
                                 a -> a :=
  fun def k =>
    let fix go arg_0__
              := match arg_0__ with
                   | Bin p m l r => if nomatch k p m : bool
                                    then def
                                    else if zero k m : bool
                                         then go l
                                         else go r
                   | Tip kx x => if k GHC.Base.== kx : bool
                                 then x
                                 else def
                   | Nil => def
                 end in
    go.

Definition delete {a} : Data.IntSet.Internal.Key -> IntMap a -> IntMap a :=
  fix delete arg_0__ arg_1__
        := match arg_0__ , arg_1__ with
             | k , (Bin p m l r as t) => if nomatch k p m : bool
                                         then t
                                         else if zero k m : bool
                                              then binCheckLeft p m (delete k l) r
                                              else binCheckRight p m l (delete k r)
             | k , (Tip ky _ as t) => if k GHC.Base.== ky : bool
                                      then Nil
                                      else t
             | _k , Nil => Nil
           end.

Definition updateLookupWithKey {a} : (Data.IntSet.Internal.Key -> a -> option
                                     a) -> Data.IntSet.Internal.Key -> IntMap a -> (option a * IntMap a)%type :=
  fix updateLookupWithKey arg_0__ arg_1__ arg_2__
        := match arg_0__ , arg_1__ , arg_2__ with
             | f , k , (Bin p m l r as t) => if nomatch k p m : bool
                                             then pair None t
                                             else if zero k m : bool
                                                  then match updateLookupWithKey f k l with
                                                         | pair found l' => pair found (binCheckLeft p m l' r)
                                                       end
                                                  else match updateLookupWithKey f k r with
                                                         | pair found r' => pair found (binCheckRight p m l r')
                                                       end
             | f , k , (Tip ky y as t) => if k GHC.Base.== ky : bool
                                          then match (f k y) with
                                                 | Some y' => pair (Some y) (Tip ky y')
                                                 | None => pair (Some y) Nil
                                               end
                                          else pair None t
             | _ , _ , Nil => pair None Nil
           end.

Definition updatePrefix {a} : IntSetPrefix -> IntMap a -> (IntMap a -> IntMap
                              a) -> IntMap a :=
  fix updatePrefix arg_0__ arg_1__ arg_2__
        := match arg_0__ , arg_1__ , arg_2__ with
             | kp , (Bin p m l r as t) , f => if (m Data.Bits..&.(**)
                                                 Data.IntSet.Internal.suffixBitMask) GHC.Base./= GHC.Num.fromInteger
                                                 0 : bool
                                              then if (p Data.Bits..&.(**) Data.IntSet.Internal.prefixBitMask)
                                                      GHC.Base.== kp : bool
                                                   then f t
                                                   else t
                                              else if nomatch kp p m : bool
                                                   then t
                                                   else if zero kp m : bool
                                                        then binCheckLeft p m (updatePrefix kp l f) r
                                                        else binCheckRight p m l (updatePrefix kp r f)
             | kp , (Tip kx _ as t) , f => if (kx Data.Bits..&.(**)
                                              Data.IntSet.Internal.prefixBitMask) GHC.Base.== kp : bool
                                           then f t
                                           else t
             | _ , Nil , _ => Nil
           end.

Definition updateWithKey {a} : (Data.IntSet.Internal.Key -> a -> option
                               a) -> Data.IntSet.Internal.Key -> IntMap a -> IntMap a :=
  fix updateWithKey arg_0__ arg_1__ arg_2__
        := match arg_0__ , arg_1__ , arg_2__ with
             | f , k , (Bin p m l r as t) => if nomatch k p m : bool
                                             then t
                                             else if zero k m : bool
                                                  then binCheckLeft p m (updateWithKey f k l) r
                                                  else binCheckRight p m l (updateWithKey f k r)
             | f , k , (Tip ky y as t) => if k GHC.Base.== ky : bool
                                          then match (f k y) with
                                                 | Some y' => Tip ky y'
                                                 | None => Nil
                                               end
                                          else t
             | _ , _ , Nil => Nil
           end.

Definition update {a} : (a -> option a) -> Data.IntSet.Internal.Key -> IntMap
                        a -> IntMap a :=
  fun f =>
    updateWithKey (fun arg_0__ arg_1__ =>
                    match arg_0__ , arg_1__ with
                      | _ , x => f x
                    end).

Definition adjustWithKey {a}
    : (Data.IntSet.Internal.Key -> a -> a) -> Data.IntSet.Internal.Key -> IntMap
      a -> IntMap a :=
  fix adjustWithKey arg_0__ arg_1__ arg_2__
        := match arg_0__ , arg_1__ , arg_2__ with
             | f , k , (Bin p m l r as t) => if nomatch k p m : bool
                                             then t
                                             else if zero k m : bool
                                                  then Bin p m (adjustWithKey f k l) r
                                                  else Bin p m l (adjustWithKey f k r)
             | f , k , (Tip ky y as t) => if k GHC.Base.== ky : bool
                                          then Tip ky (f k y)
                                          else t
             | _ , _ , Nil => Nil
           end.

Definition adjust {a} : (a -> a) -> Data.IntSet.Internal.Key -> IntMap
                        a -> IntMap a :=
  fun f k m =>
    adjustWithKey (fun arg_0__ arg_1__ =>
                    match arg_0__ , arg_1__ with
                      | _ , x => f x
                    end) k m.

Definition branchMask : Prefix -> Prefix -> Mask :=
  fun p1 p2 =>
    Coq.ZArith.BinInt.Z.of_N (Utils.Containers.Internal.BitUtil.highestBitMask
                             (Data.Bits.xor (natFromInt p1) (natFromInt p2))).

Definition link {a} : Prefix -> IntMap a -> Prefix -> IntMap a -> IntMap a :=
  fun p1 t1 p2 t2 =>
    let m := branchMask p1 p2 in
    let p := mask p1 m in if zero p1 m : bool then Bin p m t1 t2 else Bin p m t2 t1.

Definition insert {a} : Data.IntSet.Internal.Key -> a -> IntMap a -> IntMap a :=
  fix insert arg_0__ arg_1__ arg_2__
        := match arg_0__ , arg_1__ , arg_2__ with
             | k , x , (Bin p m l r as t) => if nomatch k p m : bool
                                             then link k (Tip k x) p t
                                             else if zero k m : bool
                                                  then Bin p m (insert k x l) r
                                                  else Bin p m l (insert k x r)
             | k , x , (Tip ky _ as t) => if k GHC.Base.== ky : bool
                                          then Tip k x
                                          else link k (Tip k x) ky t
             | k , x , Nil => Tip k x
           end.

Definition fromList {a} : list (Data.IntSet.Internal.Key * a)%type -> IntMap
                          a :=
  fun xs =>
    let ins :=
      fun arg_0__ arg_1__ =>
        match arg_0__ , arg_1__ with
          | t , pair k x => insert k x t
        end in
    Data.Foldable.foldl ins empty xs.

Definition mapKeys {a}
    : (Data.IntSet.Internal.Key -> Data.IntSet.Internal.Key) -> IntMap a -> IntMap
      a :=
  fun f =>
    fromList GHC.Base.∘ foldrWithKey (fun k x xs => cons (pair (f k) x) xs) nil.

Definition alterF {f} {a} `{GHC.Base.Functor f} : (option a -> f (option
                                                                 a)) -> Data.IntSet.Internal.Key -> IntMap a -> f
                                                  (IntMap a) :=
  fun f k m =>
    let mv := lookup k m in
    (fun arg_1__ => arg_1__ Data.Functor.<$> f mv) GHC.Base.$ (fun fres =>
      match fres with
        | None => Data.Maybe.maybe m (GHC.Base.const (delete k m)) mv
        | Some v' => insert k v' m
      end).

Definition insertLookupWithKey {a}
    : (Data.IntSet.Internal.Key -> a -> a -> a) -> Data.IntSet.Internal.Key -> a -> IntMap
      a -> (option a * IntMap a)%type :=
  fix insertLookupWithKey arg_0__ arg_1__ arg_2__ arg_3__
        := match arg_0__ , arg_1__ , arg_2__ , arg_3__ with
             | f , k , x , (Bin p m l r as t) => if nomatch k p m : bool
                                                 then pair None (link k (Tip k x) p t)
                                                 else if zero k m : bool
                                                      then match insertLookupWithKey f k x l with
                                                             | pair found l' => pair found (Bin p m l' r)
                                                           end
                                                      else match insertLookupWithKey f k x r with
                                                             | pair found r' => pair found (Bin p m l r')
                                                           end
             | f , k , x , (Tip ky y as t) => if k GHC.Base.== ky : bool
                                              then pair (Some y) (Tip k (f k x y))
                                              else pair None (link k (Tip k x) ky t)
             | _ , k , x , Nil => pair None (Tip k x)
           end.

Definition insertWithKey {a}
    : (Data.IntSet.Internal.Key -> a -> a -> a) -> Data.IntSet.Internal.Key -> a -> IntMap
      a -> IntMap a :=
  fix insertWithKey arg_0__ arg_1__ arg_2__ arg_3__
        := match arg_0__ , arg_1__ , arg_2__ , arg_3__ with
             | f , k , x , (Bin p m l r as t) => if nomatch k p m : bool
                                                 then link k (Tip k x) p t
                                                 else if zero k m : bool
                                                      then Bin p m (insertWithKey f k x l) r
                                                      else Bin p m l (insertWithKey f k x r)
             | f , k , x , (Tip ky y as t) => if k GHC.Base.== ky : bool
                                              then Tip k (f k x y)
                                              else link k (Tip k x) ky t
             | _ , k , x , Nil => Tip k x
           end.

Definition fromListWithKey {a}
    : (Data.IntSet.Internal.Key -> a -> a -> a) -> list (Data.IntSet.Internal.Key *
                                                        a)%type -> IntMap a :=
  fun f xs =>
    let ins :=
      fun arg_0__ arg_1__ =>
        match arg_0__ , arg_1__ with
          | t , pair k x => insertWithKey f k x t
        end in
    Data.Foldable.foldl ins empty xs.

Definition fromListWith {a} : (a -> a -> a) -> list (Data.IntSet.Internal.Key *
                                                    a)%type -> IntMap a :=
  fun f xs =>
    fromListWithKey (fun arg_0__ arg_1__ arg_2__ =>
                      match arg_0__ , arg_1__ , arg_2__ with
                        | _ , x , y => f x y
                      end) xs.

Definition mapKeysWith {a}
    : (a -> a -> a) -> (Data.IntSet.Internal.Key -> Data.IntSet.Internal.Key) -> IntMap
      a -> IntMap a :=
  fun c f =>
    fromListWith c GHC.Base.∘ foldrWithKey (fun k x xs => cons (pair (f k) x) xs)
    nil.

Definition insertWith {a}
    : (a -> a -> a) -> Data.IntSet.Internal.Key -> a -> IntMap a -> IntMap a :=
  fun f k x t =>
    insertWithKey (fun arg_0__ arg_1__ arg_2__ =>
                    match arg_0__ , arg_1__ , arg_2__ with
                      | _ , x' , y' => f x' y'
                    end) k x t.

Definition mergeWithKey' {c} {a} {b} : (Prefix -> Mask -> IntMap c -> IntMap
                                       c -> IntMap c) -> (IntMap a -> IntMap b -> IntMap c) -> (IntMap a -> IntMap
                                       c) -> (IntMap b -> IntMap c) -> IntMap a -> IntMap b -> IntMap c :=
  fun bin' f g1 g2 =>
    let maybe_link :=
      fun arg_0__ arg_1__ arg_2__ arg_3__ =>
        match arg_0__ , arg_1__ , arg_2__ , arg_3__ with
          | _ , Nil , _ , t2 => t2
          | _ , t1 , _ , Nil => t1
          | p1 , t1 , p2 , t2 => link p1 t1 p2 t2
        end in
    let go :=
      unsafeFix (fun go arg_6__ arg_7__ =>
                  match arg_6__ , arg_7__ with
                    | (Bin p1 m1 l1 r1 as t1) , (Bin p2 m2 l2 r2 as t2) => let merge2 :=
                                                                             if nomatch p1 p2 m2 : bool
                                                                             then maybe_link p1 (g1 t1) p2 (g2 t2)
                                                                             else if zero p1 m2 : bool
                                                                                  then bin' p2 m2 (go t1 l2) (g2 r2)
                                                                                  else bin' p2 m2 (g2 l2) (go t1 r2) in
                                                                           let merge1 :=
                                                                             if nomatch p2 p1 m1 : bool
                                                                             then maybe_link p1 (g1 t1) p2 (g2 t2)
                                                                             else if zero p2 m1 : bool
                                                                                  then bin' p1 m1 (go l1 t2) (g1 r1)
                                                                                  else bin' p1 m1 (g1 l1) (go r1 t2) in
                                                                           if shorter m1 m2 : bool
                                                                           then merge1
                                                                           else if shorter m2 m1 : bool
                                                                                then merge2
                                                                                else if p1 GHC.Base.== p2 : bool
                                                                                     then bin' p1 m1 (go l1 l2) (go r1
                                                                                                                r2)
                                                                                     else maybe_link p1 (g1 t1) p2 (g2
                                                                                                                   t2)
                    | (Bin _ _ _ _ as t1') , (Tip k2' _ as t2') => let merge0 :=
                                                                     unsafeFix (fun merge0 arg_18__ arg_19__ arg_20__ =>
                                                                                 match arg_18__
                                                                                     , arg_19__
                                                                                     , arg_20__ with
                                                                                   | t2 , k2 , (Bin p1 m1 l1
                                                                                                    r1 as t1) =>
                                                                                     if nomatch k2 p1 m1 : bool
                                                                                     then maybe_link p1 (g1 t1) k2 (g2
                                                                                                                   t2)
                                                                                     else if zero k2 m1 : bool
                                                                                          then bin' p1 m1 (merge0 t2 k2
                                                                                                          l1) (g1 r1)
                                                                                          else bin' p1 m1 (g1 l1)
                                                                                               (merge0 t2 k2 r1)
                                                                                   | t2 , k2 , (Tip k1 _ as t1) => if k1
                                                                                                                      GHC.Base.==
                                                                                                                      k2 : bool
                                                                                                                   then f
                                                                                                                        t1
                                                                                                                        t2
                                                                                                                   else maybe_link
                                                                                                                        k1
                                                                                                                        (g1
                                                                                                                        t1)
                                                                                                                        k2
                                                                                                                        (g2
                                                                                                                        t2)
                                                                                   | t2 , _ , Nil => g2 t2
                                                                                 end) in
                                                                   merge0 t2' k2' t1'
                    | (Bin _ _ _ _ as t1) , Nil => g1 t1
                    | (Tip k1' _ as t1') , t2' => let merge0 :=
                                                    unsafeFix (fun merge0 arg_30__ arg_31__ arg_32__ =>
                                                                match arg_30__ , arg_31__ , arg_32__ with
                                                                  | t1 , k1 , (Bin p2 m2 l2 r2 as t2) => if nomatch k1
                                                                                                            p2 m2 : bool
                                                                                                         then maybe_link
                                                                                                              k1 (g1 t1)
                                                                                                              p2 (g2 t2)
                                                                                                         else if zero k1
                                                                                                                 m2 : bool
                                                                                                              then bin'
                                                                                                                   p2 m2
                                                                                                                   (merge0
                                                                                                                   t1 k1
                                                                                                                   l2)
                                                                                                                   (g2
                                                                                                                   r2)
                                                                                                              else bin'
                                                                                                                   p2 m2
                                                                                                                   (g2
                                                                                                                   l2)
                                                                                                                   (merge0
                                                                                                                   t1 k1
                                                                                                                   r2)
                                                                  | t1 , k1 , (Tip k2 _ as t2) => if k1 GHC.Base.==
                                                                                                     k2 : bool
                                                                                                  then f t1 t2
                                                                                                  else maybe_link k1 (g1
                                                                                                                     t1)
                                                                                                       k2 (g2 t2)
                                                                  | t1 , _ , Nil => g1 t1
                                                                end) in
                                                  merge0 t1' k1' t2'
                    | Nil , t2 => g2 t2
                  end) in
    go.

Definition union {a} : IntMap a -> IntMap a -> IntMap a :=
  fun m1 m2 => mergeWithKey' Bin GHC.Base.const GHC.Base.id GHC.Base.id m1 m2.

Definition split {a} : Data.IntSet.Internal.Key -> IntMap a -> (IntMap a *
                       IntMap a)%type :=
  fun k t =>
    let fix go arg_0__ arg_1__
              := match arg_0__ , arg_1__ with
                   | k' , (Bin p m l r as t') => if nomatch k' p m : bool
                                                 then if k' GHC.Base.> p : bool
                                                      then pair t' Nil
                                                      else pair Nil t'
                                                 else if zero k' m : bool
                                                      then match go k' l with
                                                             | pair lt gt => pair lt (union gt r)
                                                           end
                                                      else match go k' r with
                                                             | pair lt gt => pair (union l lt) gt
                                                           end
                   | k' , (Tip ky _ as t') => if k' GHC.Base.> ky : bool
                                              then (pair t' Nil)
                                              else if k' GHC.Base.< ky : bool
                                                   then (pair Nil t')
                                                   else (pair Nil Nil)
                   | _ , Nil => (pair Nil Nil)
                 end in
    let j_20__ := match go k t with | pair lt gt => pair lt gt end in
    match t with
      | Bin _ m l r => if m GHC.Base.< GHC.Num.fromInteger 0 : bool
                       then if k GHC.Base.>= GHC.Num.fromInteger 0 : bool
                            then match go k l with
                                   | pair lt gt => match union r lt with
                                                     | lt' => pair lt' gt
                                                   end
                                 end
                            else match go k r with
                                   | pair lt gt => match union gt l with
                                                     | gt' => pair lt gt'
                                                   end
                                 end
                       else j_20__
      | _ => j_20__
    end.

Definition splitLookup {a} : Data.IntSet.Internal.Key -> IntMap a -> (IntMap a *
                             option a * IntMap a)%type :=
  fun k t =>
    let fix go arg_0__ arg_1__
              := match arg_0__ , arg_1__ with
                   | k' , (Bin p m l r as t') => if nomatch k' p m : bool
                                                 then if k' GHC.Base.> p : bool
                                                      then Mk_SplitLookup t' None Nil
                                                      else Mk_SplitLookup Nil None t'
                                                 else if zero k' m : bool
                                                      then mapGT (fun arg_3__ => union arg_3__ r) (go k' l)
                                                      else mapLT (union l) (go k' r)
                   | k' , (Tip ky y as t') => if k' GHC.Base.> ky : bool
                                              then Mk_SplitLookup t' None Nil
                                              else if k' GHC.Base.< ky : bool
                                                   then Mk_SplitLookup Nil None t'
                                                   else Mk_SplitLookup Nil (Some y) Nil
                   | _ , Nil => Mk_SplitLookup Nil None Nil
                 end in
    match (let j_12__ := go k t in
            match t with
              | Bin _ m l r => if m GHC.Base.< GHC.Num.fromInteger 0 : bool
                               then if k GHC.Base.>= GHC.Num.fromInteger 0 : bool
                                    then mapLT (union r) (go k l)
                                    else mapGT (fun arg_13__ => union arg_13__ l) (go k r)
                               else j_12__
              | _ => j_12__
            end) with
      | Mk_SplitLookup lt fnd gt => pair (pair lt fnd) gt
    end.

Definition unions {a} : list (IntMap a) -> IntMap a :=
  fun xs => Data.Foldable.foldl union empty xs.

Definition unionWithKey {a}
    : (Data.IntSet.Internal.Key -> a -> a -> a) -> IntMap a -> IntMap a -> IntMap
      a :=
  fun f m1 m2 =>
    mergeWithKey' Bin (fun arg_0__ arg_1__ =>
                        match arg_0__ , arg_1__ with
                          | Tip k1 x1 , Tip _k2 x2 => Tip k1 (f k1 x1 x2)
                          | _ , _ => patternFailure
                        end) GHC.Base.id GHC.Base.id m1 m2.

Definition unionWith {a} : (a -> a -> a) -> IntMap a -> IntMap a -> IntMap a :=
  fun f m1 m2 =>
    unionWithKey (fun arg_0__ arg_1__ arg_2__ =>
                   match arg_0__ , arg_1__ , arg_2__ with
                     | _ , x , y => f x y
                   end) m1 m2.

Definition unionsWith {a} : (a -> a -> a) -> list (IntMap a) -> IntMap a :=
  fun f ts => Data.Foldable.foldl (unionWith f) empty ts.

Definition intersection {a} {b} : IntMap a -> IntMap b -> IntMap a :=
  fun m1 m2 =>
    mergeWithKey' bin GHC.Base.const (GHC.Base.const Nil) (GHC.Base.const Nil) m1
    m2.

Definition intersectionWithKey {a} {b} {c}
    : (Data.IntSet.Internal.Key -> a -> b -> c) -> IntMap a -> IntMap b -> IntMap
      c :=
  fun f m1 m2 =>
    mergeWithKey' bin (fun arg_0__ arg_1__ =>
                        match arg_0__ , arg_1__ with
                          | Tip k1 x1 , Tip _k2 x2 => Tip k1 (f k1 x1 x2)
                          | _ , _ => patternFailure
                        end) (GHC.Base.const Nil) (GHC.Base.const Nil) m1 m2.

Definition intersectionWith {a} {b} {c} : (a -> b -> c) -> IntMap a -> IntMap
                                          b -> IntMap c :=
  fun f m1 m2 =>
    intersectionWithKey (fun arg_0__ arg_1__ arg_2__ =>
                          match arg_0__ , arg_1__ , arg_2__ with
                            | _ , x , y => f x y
                          end) m1 m2.

Definition mergeWithKey {a} {b} {c}
    : (Data.IntSet.Internal.Key -> a -> b -> option c) -> (IntMap a -> IntMap
      c) -> (IntMap b -> IntMap c) -> IntMap a -> IntMap b -> IntMap c :=
  fun f g1 g2 =>
    let combine :=
      fun arg_0__ arg_1__ =>
        match arg_0__ , arg_1__ with
          | Tip k1 x1 , Tip _k2 x2 => match f k1 x1 x2 with
                                        | None => Nil
                                        | Some x => Tip k1 x
                                      end
          | _ , _ => patternFailure
        end in
    mergeWithKey' bin combine g1 g2.

Definition difference {a} {b} : IntMap a -> IntMap b -> IntMap a :=
  fun m1 m2 =>
    mergeWithKey (fun arg_0__ arg_1__ arg_2__ => None) GHC.Base.id (GHC.Base.const
                                                                   Nil) m1 m2.

Definition op_zrzr__ {a} {b} : IntMap a -> IntMap b -> IntMap a :=
  fun m1 m2 => difference m1 m2.

Notation "'_\\_'" := (op_zrzr__).

Infix "\\" := (_\\_) (at level 99).

Definition differenceWithKey {a} {b}
    : (Data.IntSet.Internal.Key -> a -> b -> option a) -> IntMap a -> IntMap
      b -> IntMap a :=
  fun f m1 m2 => mergeWithKey f GHC.Base.id (GHC.Base.const Nil) m1 m2.

Definition differenceWith {a} {b} : (a -> b -> option a) -> IntMap a -> IntMap
                                    b -> IntMap a :=
  fun f m1 m2 =>
    differenceWithKey (fun arg_0__ arg_1__ arg_2__ =>
                        match arg_0__ , arg_1__ , arg_2__ with
                          | _ , x , y => f x y
                        end) m1 m2.

Definition alter {a} : (option a -> option
                       a) -> Data.IntSet.Internal.Key -> IntMap a -> IntMap a :=
  fix alter arg_0__ arg_1__ arg_2__
        := match arg_0__ , arg_1__ , arg_2__ with
             | f , k , (Bin p m l r as t) => if nomatch k p m : bool
                                             then match f None with
                                                    | None => t
                                                    | Some x => link k (Tip k x) p t
                                                  end
                                             else if zero k m : bool
                                                  then binCheckLeft p m (alter f k l) r
                                                  else binCheckRight p m l (alter f k r)
             | f , k , (Tip ky y as t) => if k GHC.Base.== ky : bool
                                          then match f (Some y) with
                                                 | Some x => Tip ky x
                                                 | None => Nil
                                               end
                                          else match f None with
                                                 | Some x => link k (Tip k x) ky t
                                                 | None => Tip ky y
                                               end
             | f , k , Nil => match f None with
                                | Some x => Tip k x
                                | None => Nil
                              end
           end.

Definition nequal {a} `{GHC.Base.Eq_ a} : IntMap a -> IntMap a -> bool :=
  fix nequal arg_0__ arg_1__
        := match arg_0__ , arg_1__ with
             | Bin p1 m1 l1 r1 , Bin p2 m2 l2 r2 => orb (m1 GHC.Base./= m2) (orb (p1
                                                                                 GHC.Base./= p2) (orb (nequal l1 l2)
                                                                                                      (nequal r1 r2)))
             | Tip kx x , Tip ky y => orb (kx GHC.Base./= ky) (x GHC.Base./= y)
             | Nil , Nil => false
             | _ , _ => true
           end.

Local Definition Eq___IntMap_op_zsze__ {inst_a} `{GHC.Base.Eq_ inst_a} : (IntMap
                                                                         inst_a) -> (IntMap inst_a) -> bool :=
  fun t1 t2 => nequal t1 t2.

Program Instance Eq___IntMap {a} `{GHC.Base.Eq_ a} : GHC.Base.Eq_ (IntMap a) :=
  fun _ k =>
    k {|GHC.Base.op_zeze____ := Eq___IntMap_op_zeze__ ;
      GHC.Base.op_zsze____ := Eq___IntMap_op_zsze__ |}.
Admit Obligations.

Program Instance Ord__IntMap {a} `{GHC.Base.Ord a} : GHC.Base.Ord (IntMap a) :=
  fun _ k =>
    k {|GHC.Base.op_zl____ := Ord__IntMap_op_zl__ ;
      GHC.Base.op_zlze____ := Ord__IntMap_op_zlze__ ;
      GHC.Base.op_zg____ := Ord__IntMap_op_zg__ ;
      GHC.Base.op_zgze____ := Ord__IntMap_op_zgze__ ;
      GHC.Base.compare__ := Ord__IntMap_compare ;
      GHC.Base.max__ := Ord__IntMap_max ;
      GHC.Base.min__ := Ord__IntMap_min |}.
Admit Obligations.

Definition node : GHC.Base.String :=
  GHC.Base.hs_string__ "+--".

Definition null {a} : IntMap a -> bool :=
  fun arg_0__ => match arg_0__ with | Nil => true | _ => false end.

Local Definition Foldable__IntMap_null : forall {a}, IntMap a -> bool :=
  fun {a} => null.

Definition preserveMissing {f} {x} `{GHC.Base.Applicative f} : WhenMissing f x
                                                               x :=
  Mk_WhenMissing missingValue missingValue.

Definition runWhenMatched {f} {x} {y} {z} : WhenMatched f x y
                                            z -> Data.IntSet.Internal.Key -> x -> y -> f (option z) :=
  matchedKey.

Definition contramapSecondWhenMatched {b} {a} {f} {x} {z}
    : (b -> a) -> WhenMatched f x a z -> WhenMatched f x b z :=
  fun f t => Mk_WhenMatched GHC.Base.$ (fun k x y => runWhenMatched t k x (f y)).

Definition contramapFirstWhenMatched {b} {a} {f} {y} {z}
    : (b -> a) -> WhenMatched f a y z -> WhenMatched f b y z :=
  fun f t => Mk_WhenMatched GHC.Base.$ (fun k x y => runWhenMatched t k (f x) y).

Definition runWhenMissing {f} {x} {y} : WhenMissing f x
                                        y -> Data.IntSet.Internal.Key -> x -> f (option y) :=
  missingKey.

Definition singleton {a} : Data.IntSet.Internal.Key -> a -> IntMap a :=
  fun k x => Tip k x.

Definition size {a} : IntMap a -> GHC.Num.Int :=
  let fix go arg_0__ arg_1__
            := match arg_0__ , arg_1__ with
                 | acc , Bin _ _ l r => go (go acc l) r
                 | acc , Tip _ _ => GHC.Num.fromInteger 1 GHC.Num.+ acc
                 | acc , Nil => acc
               end in
  go (GHC.Num.fromInteger 0).

Local Definition Foldable__IntMap_length : forall {a},
                                             IntMap a -> GHC.Num.Int :=
  fun {a} => size.

Program Instance Foldable__IntMap : Data.Foldable.Foldable IntMap := fun _ k =>
    k {|Data.Foldable.elem__ := fun {a} `{GHC.Base.Eq_ a} => Foldable__IntMap_elem ;
      Data.Foldable.fold__ := fun {m} `{GHC.Base.Monoid m} => Foldable__IntMap_fold ;
      Data.Foldable.foldMap__ := fun {m} {a} `{GHC.Base.Monoid m} =>
        Foldable__IntMap_foldMap ;
      Data.Foldable.foldl__ := fun {b} {a} => Foldable__IntMap_foldl ;
      Data.Foldable.foldl'__ := fun {b} {a} => Foldable__IntMap_foldl' ;
      Data.Foldable.foldr__ := fun {a} {b} => Foldable__IntMap_foldr ;
      Data.Foldable.foldr'__ := fun {a} {b} => Foldable__IntMap_foldr' ;
      Data.Foldable.length__ := fun {a} => Foldable__IntMap_length ;
      Data.Foldable.null__ := fun {a} => Foldable__IntMap_null ;
      Data.Foldable.product__ := fun {a} `{GHC.Num.Num a} =>
        Foldable__IntMap_product ;
      Data.Foldable.sum__ := fun {a} `{GHC.Num.Num a} => Foldable__IntMap_sum ;
      Data.Foldable.toList__ := fun {a} => Foldable__IntMap_toList |}.
Admit Obligations.

Definition splitRoot {a} : IntMap a -> list (IntMap a) :=
  fun orig =>
    match orig with
      | Nil => nil
      | (Tip _ _ as x) => cons x nil
      | Bin _ m l r => if m GHC.Base.< GHC.Num.fromInteger 0 : bool
                       then cons r (cons l nil)
                       else cons l (cons r nil)
    end.

Definition traverseMaybeMissing {f} {x} {y} `{GHC.Base.Applicative f}
    : (Data.IntSet.Internal.Key -> x -> f (option y)) -> WhenMissing f x y :=
  fun f => Mk_WhenMissing missingValue missingValue.

Definition traverseMissing {f} {x} {y} `{GHC.Base.Applicative f}
    : (Data.IntSet.Internal.Key -> x -> f y) -> WhenMissing f x y :=
  fun f => Mk_WhenMissing missingValue missingValue.

Definition traverseWithKey {t} {a} {b} `{GHC.Base.Applicative t}
    : (Data.IntSet.Internal.Key -> a -> t b) -> IntMap a -> t (IntMap b) :=
  fun f =>
    let fix go arg_0__
              := match arg_0__ with
                   | Nil => GHC.Base.pure Nil
                   | Tip k v => Tip k Data.Functor.<$> f k v
                   | Bin p m l r => GHC.Base.liftA2 (Bin p m) (go l) (go r)
                 end in
    go.

Local Definition Traversable__IntMap_traverse : forall {f} {a} {b},
                                                  forall `{GHC.Base.Applicative f},
                                                    (a -> f b) -> IntMap a -> f (IntMap b) :=
  fun {f} {a} {b} `{GHC.Base.Applicative f} =>
    fun f => traverseWithKey (fun arg_0__ => f).

Local Definition Traversable__IntMap_sequenceA : forall {f} {a},
                                                   forall `{GHC.Base.Applicative f}, IntMap (f a) -> f (IntMap a) :=
  fun {f} {a} `{GHC.Base.Applicative f} =>
    Traversable__IntMap_traverse GHC.Base.id.

Local Definition Traversable__IntMap_sequence : forall {m} {a},
                                                  forall `{GHC.Base.Monad m}, IntMap (m a) -> m (IntMap a) :=
  fun {m} {a} `{GHC.Base.Monad m} => Traversable__IntMap_sequenceA.

Local Definition Traversable__IntMap_mapM : forall {m} {a} {b},
                                              forall `{GHC.Base.Monad m}, (a -> m b) -> IntMap a -> m (IntMap b) :=
  fun {m} {a} {b} `{GHC.Base.Monad m} => Traversable__IntMap_traverse.

Program Instance Traversable__IntMap : Data.Traversable.Traversable IntMap :=
  fun _ k =>
    k {|Data.Traversable.mapM__ := fun {m} {a} {b} `{GHC.Base.Monad m} =>
        Traversable__IntMap_mapM ;
      Data.Traversable.sequence__ := fun {m} {a} `{GHC.Base.Monad m} =>
        Traversable__IntMap_sequence ;
      Data.Traversable.sequenceA__ := fun {f} {a} `{GHC.Base.Applicative f} =>
        Traversable__IntMap_sequenceA ;
      Data.Traversable.traverse__ := fun {f} {a} {b} `{GHC.Base.Applicative f} =>
        Traversable__IntMap_traverse |}.
Admit Obligations.

Definition unsafeFindMax {a} : IntMap a -> option (Data.IntSet.Internal.Key *
                                                  a)%type :=
  fix unsafeFindMax arg_0__
        := match arg_0__ with
             | Nil => None
             | Tip ky y => Some (pair ky y)
             | Bin _ _ _ r => unsafeFindMax r
           end.

Definition lookupLT {a} : Data.IntSet.Internal.Key -> IntMap a -> option
                          (Data.IntSet.Internal.Key * a)%type :=
  fun k t =>
    let fix go arg_0__ arg_1__
              := match arg_0__ , arg_1__ with
                   | def , Bin p m l r => if nomatch k p m : bool
                                          then if k GHC.Base.< p : bool
                                               then unsafeFindMax def
                                               else unsafeFindMax r
                                          else if zero k m : bool
                                               then go def l
                                               else go l r
                   | def , Tip ky y => if k GHC.Base.<= ky : bool
                                       then unsafeFindMax def
                                       else Some (pair ky y)
                   | def , Nil => unsafeFindMax def
                 end in
    let j_10__ := go Nil t in
    match t with
      | Bin _ m l r => if m GHC.Base.< GHC.Num.fromInteger 0 : bool
                       then if k GHC.Base.>= GHC.Num.fromInteger 0 : bool
                            then go r l
                            else go Nil r
                       else j_10__
      | _ => j_10__
    end.

Definition lookupLE {a} : Data.IntSet.Internal.Key -> IntMap a -> option
                          (Data.IntSet.Internal.Key * a)%type :=
  fun k t =>
    let fix go arg_0__ arg_1__
              := match arg_0__ , arg_1__ with
                   | def , Bin p m l r => if nomatch k p m : bool
                                          then if k GHC.Base.< p : bool
                                               then unsafeFindMax def
                                               else unsafeFindMax r
                                          else if zero k m : bool
                                               then go def l
                                               else go l r
                   | def , Tip ky y => if k GHC.Base.< ky : bool
                                       then unsafeFindMax def
                                       else Some (pair ky y)
                   | def , Nil => unsafeFindMax def
                 end in
    let j_10__ := go Nil t in
    match t with
      | Bin _ m l r => if m GHC.Base.< GHC.Num.fromInteger 0 : bool
                       then if k GHC.Base.>= GHC.Num.fromInteger 0 : bool
                            then go r l
                            else go Nil r
                       else j_10__
      | _ => j_10__
    end.

Definition unsafeFindMin {a} : IntMap a -> option (Data.IntSet.Internal.Key *
                                                  a)%type :=
  fix unsafeFindMin arg_0__
        := match arg_0__ with
             | Nil => None
             | Tip ky y => Some (pair ky y)
             | Bin _ _ l _ => unsafeFindMin l
           end.

Definition lookupGT {a} : Data.IntSet.Internal.Key -> IntMap a -> option
                          (Data.IntSet.Internal.Key * a)%type :=
  fun k t =>
    let fix go arg_0__ arg_1__
              := match arg_0__ , arg_1__ with
                   | def , Bin p m l r => if nomatch k p m : bool
                                          then if k GHC.Base.< p : bool
                                               then unsafeFindMin l
                                               else unsafeFindMin def
                                          else if zero k m : bool
                                               then go r l
                                               else go def r
                   | def , Tip ky y => if k GHC.Base.>= ky : bool
                                       then unsafeFindMin def
                                       else Some (pair ky y)
                   | def , Nil => unsafeFindMin def
                 end in
    let j_10__ := go Nil t in
    match t with
      | Bin _ m l r => if m GHC.Base.< GHC.Num.fromInteger 0 : bool
                       then if k GHC.Base.>= GHC.Num.fromInteger 0 : bool
                            then go Nil l
                            else go l r
                       else j_10__
      | _ => j_10__
    end.

Definition lookupGE {a} : Data.IntSet.Internal.Key -> IntMap a -> option
                          (Data.IntSet.Internal.Key * a)%type :=
  fun k t =>
    let fix go arg_0__ arg_1__
              := match arg_0__ , arg_1__ with
                   | def , Bin p m l r => if nomatch k p m : bool
                                          then if k GHC.Base.< p : bool
                                               then unsafeFindMin l
                                               else unsafeFindMin def
                                          else if zero k m : bool
                                               then go r l
                                               else go def r
                   | def , Tip ky y => if k GHC.Base.> ky : bool
                                       then unsafeFindMin def
                                       else Some (pair ky y)
                   | def , Nil => unsafeFindMin def
                 end in
    let j_10__ := go Nil t in
    match t with
      | Bin _ m l r => if m GHC.Base.< GHC.Num.fromInteger 0 : bool
                       then if k GHC.Base.>= GHC.Num.fromInteger 0 : bool
                            then go Nil l
                            else go l r
                       else j_10__
      | _ => j_10__
    end.

Definition zipWithAMatched {f} {x} {y} {z} `{GHC.Base.Applicative f}
    : (Data.IntSet.Internal.Key -> x -> y -> f z) -> WhenMatched f x y z :=
  fun f => Mk_WhenMatched GHC.Base.$ (fun k x y => Some Data.Functor.<$> f k x y).

Definition zipWithMatched {f} {x} {y} {z} `{GHC.Base.Applicative f}
    : (Data.IntSet.Internal.Key -> x -> y -> z) -> WhenMatched f x y z :=
  fun f =>
    Mk_WhenMatched GHC.Base.$ (fun k x y =>
      (GHC.Base.pure GHC.Base.∘ Some) GHC.Base.$ f k x y).

Definition zipWithMaybeAMatched {x} {y} {f} {z}
    : (Data.IntSet.Internal.Key -> x -> y -> f (option z)) -> WhenMatched f x y z :=
  fun f => Mk_WhenMatched GHC.Base.$ (fun k x y => f k x y).

Definition mapGentlyWhenMatched {f} {a} {b} {x} {y} `{GHC.Base.Functor f}
    : (a -> b) -> WhenMatched f x y a -> WhenMatched f x y b :=
  fun f t =>
    zipWithMaybeAMatched GHC.Base.$ (fun k x y =>
      GHC.Base.fmap f Data.Functor.<$> runWhenMatched t k x y).

Definition zipWithMaybeMatched {f} {x} {y} {z} `{GHC.Base.Applicative f}
    : (Data.IntSet.Internal.Key -> x -> y -> option z) -> WhenMatched f x y z :=
  fun f =>
    Mk_WhenMatched GHC.Base.$ (fun k x y => GHC.Base.pure GHC.Base.$ f k x y).

Module Notations.
Notation "'_Data.IntMap.Internal.!?_'" := (op_znz3fU__).
Infix "Data.IntMap.Internal.!?" := (_!?_) (at level 99).
Notation "'_Data.IntMap.Internal.\\_'" := (op_zrzr__).
Infix "Data.IntMap.Internal.\\" := (_\\_) (at level 99).
End Notations.

(* Unbound variables:
     Eq Gt IntMap_op_zlzd__ Lt None Some andb bool comparison cons false id list negb
     nil op_zt__ option orb pair true Coq.ZArith.BinInt.Z.of_N Data.Bits.complement
     Data.Bits.op_zizazi__ Data.Bits.op_zizbzi__ Data.Bits.xor Data.Either.Either
     Data.Either.Left Data.Either.Right Data.Foldable.Foldable Data.Foldable.foldl
     Data.Functor.op_zlzdzg__ Data.Functor.Identity.Identity Data.IntSet.Internal.Bin
     Data.IntSet.Internal.IntSet Data.IntSet.Internal.Key Data.IntSet.Internal.Nil
     Data.IntSet.Internal.Tip Data.IntSet.Internal.bitmapOf
     Data.IntSet.Internal.prefixBitMask Data.IntSet.Internal.singleton
     Data.IntSet.Internal.suffixBitMask Data.Maybe.maybe Data.Traversable.Traversable
     GHC.Base.Applicative GHC.Base.Eq_ GHC.Base.Functor GHC.Base.Monad
     GHC.Base.Monoid GHC.Base.Ord GHC.Base.String GHC.Base.compare GHC.Base.const
     GHC.Base.fmap GHC.Base.id GHC.Base.liftA2 GHC.Base.mappend GHC.Base.mempty
     GHC.Base.op_z2218U__ GHC.Base.op_zd__ GHC.Base.op_zeze__ GHC.Base.op_zg__
     GHC.Base.op_zgze__ GHC.Base.op_zl__ GHC.Base.op_zlze__ GHC.Base.op_zsze__
     GHC.Base.pure GHC.Err.error GHC.Num.Int GHC.Num.Num GHC.Num.Word GHC.Num.op_zm__
     GHC.Num.op_zp__ GHC.Num.op_zt__ GHC.Real.fromIntegral
     Utils.Containers.Internal.BitUtil.highestBitMask
     Utils.Containers.Internal.BitUtil.shiftLL
*)
