(* Default settings (from HsToCoq.Coq.Preamble) *)

Generalizable All Variables.

Unset Implicit Arguments.
Set Maximal Implicit Insertion.
Unset Strict Implicit.
Unset Printing Implicit Defensive.

Require Coq.Program.Tactics.
Require Coq.Program.Wf.

(* Preamble *)

Require compcert.lib.Integers.
(* Lets import _only_ the Int64 module, otherwise we get an unwanted
   [comparison] into scope. *)
Module Int64 := compcert.lib.Integers.Int64.

(* Converted imports: *)

Require Data.Bits.
Require Data.Foldable.
Require GHC.Base.
Require GHC.Num.
Require GHC.Real.
Import Data.Bits.Notations.
Import GHC.Base.Notations.
Import GHC.Num.Notations.

(* Converted type declarations: *)

Definition Prefix :=
  GHC.Num.Int%type.

Definition Key :=
  GHC.Num.Int%type.

Inductive IntSet : Type := Bin
                          : Prefix -> GHC.Num.Int -> IntSet -> IntSet -> IntSet
                        |  Tip : Prefix -> Int64.int -> IntSet
                        |  Nil : IntSet.

Inductive Stack : Type := Push : Prefix -> IntSet -> Stack -> Stack
                       |  Nada : Stack.

(* The Haskell code containes partial or untranslateable code, which needs the
   following *)

Axiom unsafeFix : forall {a}, (a -> a) -> a.
(* Midamble *)

Require Coq.ZArith.Zcomplements.
Require Import Coq.ZArith.Zpower.
Require Import Coq.Numbers.BinNums.

Require Import NArith.
Definition bit_N := fun s => Coq.NArith.BinNat.N.shiftl 1%N (Coq.ZArith.BinInt.Z.to_N s).

Definition popCount_N : N -> Z := unsafeFix (fun popCount x =>
  if Coq.NArith.BinNat.N.eqb x 0
  then 0%Z
  else Coq.ZArith.BinInt.Z.succ (popCount (Coq.NArith.BinNat.N.ldiff x (Coq.NArith.BinNat.N.pow 2 (Coq.NArith.BinNat.N.log2 x))))).

Instance Bits__N : Data.Bits.Bits N :=  {
  op_zizazi__   := N.land ;
  op_zizbzi__   := N.lor ;
  bit           := bit_N;
  bitSizeMaybe  := fun _ => None ;
  clearBit      := fun n i => N.clearbit n (Coq.ZArith.BinInt.Z.to_N i) ;
  complement    := fun _ => 0%N  ; (* Not legally possible with N *)
  complementBit := fun x i => N.lxor x (bit_N i) ;
  isSigned      := fun x => true ;
  popCount      := popCount_N ;
  rotate        := fun n s => Coq.NArith.BinNat.N.shiftl n (Coq.ZArith.BinInt.Z.to_N s);
  rotateL       := fun n s => Coq.NArith.BinNat.N.shiftl n (Coq.ZArith.BinInt.Z.to_N s);
  rotateR       := fun n s => Coq.NArith.BinNat.N.shiftr n (Coq.ZArith.BinInt.Z.to_N s);
  setBit        := fun x i => N.lor x (bit_N i);
  shift         := fun n s => Coq.NArith.BinNat.N.shiftl n (Coq.ZArith.BinInt.Z.to_N s);
  shiftL        := fun n s => Coq.NArith.BinNat.N.shiftl n (Coq.ZArith.BinInt.Z.to_N s);
  shiftR        := fun n s => Coq.NArith.BinNat.N.shiftr n (Coq.ZArith.BinInt.Z.to_N s);
  testBit       := fun x i => N.testbit x (Coq.ZArith.BinInt.Z.to_N i);
  unsafeShiftL  := fun n s => Coq.NArith.BinNat.N.shiftl n (Coq.ZArith.BinInt.Z.to_N s);
  unsafeShiftR  := fun n s => Coq.NArith.BinNat.N.shiftr n (Coq.ZArith.BinInt.Z.to_N s);
  xor           := N.lxor;
  zeroBits      := 0;
}.


Fixpoint size_nat (t : IntSet) : nat :=
  match t with
  | Bin _ _ l r => S (size_nat l + size_nat r)%nat
  | Tip _ bm => 0
  | Nil => 0
  end.

Require Omega.
Ltac termination_by_omega :=
  Coq.Program.Tactics.program_simpl;
  simpl;Omega.omega.


(* Z.ones 6 = 64-1 *)
Definition suffixBitMask : GHC.Num.Int := (Coq.ZArith.BinInt.Z.ones 6)%Z.


(** ** [Int64] *)

Definition shiftLL (n: Int64.int) (s : BinInt.Z) : Int64.int :=
	Int64.shl n (Int64.repr s).
Definition shiftRL (n: Int64.int) (s : BinInt.Z) : Int64.int :=
	Int64.shr n (Int64.repr s).

(*  indexOfTheOnlyBit uses pointers and ugly stuff *)
Definition indexOfTheOnlyBit : Int64.int -> BinInt.Z :=
 fun x => match Int64.is_power2 x with
	| Some i => Int64.unsigned i
	| None => 0%Z
        end.

Fixpoint last_or_0 (l : list Z) : Z := match l with
  | nil        => 0
  | cons i nil => i
  | cons i xs  => last_or_0 xs
  end.

Definition highestBitPos (x: Int64.int) : Z :=
  last_or_0 (Int64.Z_one_bits Int64.wordsize (Int64.unsigned x) 0).

Definition highestBitMask (x: Int64.int) : Int64.int :=
  Int64.repr (two_p (highestBitPos x)).

Definition popCount_64 (x : Int64.int) :=
  BinInt.Z.of_nat (length (Int64.Z_one_bits Int64.wordsize (Int64.unsigned x) 0)).

Definition bit_64 (x : Z) := Int64.repr (two_p x).

(* We treat the Int64.int as unsigned here *)
Instance Num__Int64 : GHC.Num.Num Int64.int  := {
    op_zp__ := Int64.add;
    op_zm__ := Int64.sub;
    op_zt__ := Int64.mul;
    abs := id;
    fromInteger := Int64.repr;
    negate := Int64.neg;
    signum := id;
}.

Instance Eq__Int64 : GHC.Base.Eq_ Int64.int  := fun _ k => k {|
    GHC.Base.op_zeze____ := Int64.eq;
    GHC.Base.op_zsze____ := (fun x y => Int64.eq x y);
|}.

Instance Bits__Int64 : Data.Bits.Bits Int64.int :=  {
  op_zizazi__   := Int64.and ;
  op_zizbzi__   := Int64.or ;
  bit           := bit_64;
  bitSizeMaybe  := fun _ => None ;
  clearBit      := fun n i => Int64.and n (bit_64 i);
  complement    := Int64.not;
  complementBit := fun x i => Int64.xor x (bit_64 i);
  isSigned      := fun x => true;
  popCount      := popCount_64 ;
  rotate        := fun n s => Int64.shl  n (Int64.repr s);
  rotateL       := fun n s => Int64.shl  n (Int64.repr s);
  rotateR       := fun n s => Int64.shru n (Int64.repr s);
  setBit        := fun x i => Int64.or x (bit_64 i);
  shift         := fun n s => Int64.shl  n (Int64.repr s);
  shiftL        := fun n s => Int64.shl  n (Int64.repr s);
  shiftR        := fun n s => Int64.shru n (Int64.repr s);
  testBit       := fun x i => Int64.testbit x i;
  unsafeShiftL  := fun n s => Int64.shl  n (Int64.repr s);
  unsafeShiftR  := fun n s => Int64.shru n (Int64.repr s);
  xor           := Int64.xor;
  zeroBits      := Int64.zero;
}.


(* Converted value declarations: *)

(* Skipping instance Monoid__IntSet *)

(* Translating `instance Data.Semigroup.Semigroup Data.IntSet.Internal.IntSet'
   failed: OOPS! Cannot find information for class Qualified "Data.Semigroup"
   "Semigroup" unsupported *)

(* Translating `instance Data.Data.Data Data.IntSet.Internal.IntSet' failed:
   OOPS! Cannot find information for class Qualified "Data.Data" "Data"
   unsupported *)

(* Translating `instance GHC.Exts.IsList Data.IntSet.Internal.IntSet' failed:
   OOPS! Cannot find information for class Qualified "GHC.Exts" "IsList"
   unsupported *)

(* Translating `instance GHC.Show.Show Data.IntSet.Internal.IntSet' failed:
   OOPS! Cannot find information for class Qualified "GHC.Show" "Show"
   unsupported *)

(* Translating `instance GHC.Read.Read Data.IntSet.Internal.IntSet' failed:
   OOPS! Cannot find information for class Qualified "GHC.Read" "Read"
   unsupported *)

(* Translating `instance Control.DeepSeq.NFData Data.IntSet.Internal.IntSet'
   failed: OOPS! Cannot find information for class Qualified "Control.DeepSeq"
   "NFData" unsupported *)

Definition bin : Prefix -> GHC.Num.Int -> IntSet -> IntSet -> IntSet :=
  fun arg_0__ arg_1__ arg_2__ arg_3__ =>
    match arg_0__ , arg_1__ , arg_2__ , arg_3__ with
      | _ , _ , l , Nil => l
      | _ , _ , Nil , r => r
      | p , m , l , r => Bin p m l r
    end.

Definition bitmapOfSuffix : GHC.Num.Int -> Int64.int :=
  fun s => shiftLL (GHC.Num.fromInteger 1) s.

Definition branchMask : Prefix -> Prefix -> GHC.Num.Int :=
  fun p1 p2 =>
    Coq.ZArith.BinInt.Z.pow 2 (Coq.ZArith.BinInt.Z.log2 (Coq.ZArith.BinInt.Z.lxor p1
                                                                                  p2)).

Definition empty : IntSet :=
  Nil.

Definition equal : IntSet -> IntSet -> bool :=
  fix equal arg_0__ arg_1__
        := match arg_0__ , arg_1__ with
             | Bin p1 m1 l1 r1 , Bin p2 m2 l2 r2 => andb (m1 GHC.Base.== m2) (andb (p1
                                                                                   GHC.Base.== p2) (andb (equal l1 l2)
                                                                                                         (equal r1 r2)))
             | Tip kx1 bm1 , Tip kx2 bm2 => andb (kx1 GHC.Base.== kx2) (bm1 GHC.Base.== bm2)
             | Nil , Nil => true
             | _ , _ => false
           end.

Local Definition Eq___IntSet_op_zeze__ : IntSet -> IntSet -> bool :=
  fun t1 t2 => equal t1 t2.

Definition highestBitSet : Int64.int -> GHC.Num.Int :=
  fun x => indexOfTheOnlyBit (highestBitMask x).

Definition unsafeFindMax : IntSet -> option Key :=
  fix unsafeFindMax arg_0__
        := match arg_0__ with
             | Nil => None
             | Tip kx bm => Some GHC.Base.$ (kx GHC.Num.+ highestBitSet bm)
             | Bin _ _ _ r => unsafeFindMax r
           end.

Definition lowestBitMask : Int64.int -> Int64.int :=
  fun x => x Data.Bits..&.(**) GHC.Num.negate x.

Definition lowestBitSet : Int64.int -> GHC.Num.Int :=
  fun x => indexOfTheOnlyBit (lowestBitMask x).

Definition unsafeFindMin : IntSet -> option Key :=
  fix unsafeFindMin arg_0__
        := match arg_0__ with
             | Nil => None
             | Tip kx bm => Some GHC.Base.$ (kx GHC.Num.+ lowestBitSet bm)
             | Bin _ _ l _ => unsafeFindMin l
           end.

Definition foldlBits {a}
    : GHC.Num.Int -> (a -> GHC.Num.Int -> a) -> a -> Int64.int -> a :=
  fun prefix f z bitmap =>
    let go :=
      unsafeFix (fun go arg_0__ arg_1__ =>
                  let j_6__ :=
                    match arg_0__ , arg_1__ with
                      | bm , acc => match lowestBitMask bm with
                                      | bitmask => match indexOfTheOnlyBit bitmask with
                                                     | bi => go (Data.Bits.xor bm bitmask) ((f acc) GHC.Base.$! (prefix
                                                                                           GHC.Num.+ bi))
                                                   end
                                    end
                    end in
                  match arg_0__ , arg_1__ with
                    | num_2__ , acc => if num_2__ GHC.Base.== GHC.Num.fromInteger 0 : bool
                                       then acc
                                       else j_6__
                  end) in
    go bitmap z.

Definition foldl {a} : (a -> Key -> a) -> a -> IntSet -> a :=
  fun f z =>
    let fix go arg_0__ arg_1__
              := match arg_0__ , arg_1__ with
                   | z' , Nil => z'
                   | z' , Tip kx bm => foldlBits kx f z' bm
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

Definition foldlFB {a} : (a -> Key -> a) -> a -> IntSet -> a :=
  foldl.

Definition toDescList : IntSet -> list Key :=
  foldl (GHC.Base.flip cons) nil.

Definition foldl'Bits {a}
    : GHC.Num.Int -> (a -> GHC.Num.Int -> a) -> a -> Int64.int -> a :=
  fun prefix f z bitmap =>
    let go :=
      unsafeFix (fun go arg_0__ arg_1__ =>
                  let j_6__ :=
                    match arg_0__ , arg_1__ with
                      | bm , acc => match lowestBitMask bm with
                                      | bitmask => match indexOfTheOnlyBit bitmask with
                                                     | bi => go (Data.Bits.xor bm bitmask) ((f acc) GHC.Base.$! (prefix
                                                                                           GHC.Num.+ bi))
                                                   end
                                    end
                    end in
                  match arg_0__ , arg_1__ with
                    | num_2__ , acc => if num_2__ GHC.Base.== GHC.Num.fromInteger 0 : bool
                                       then acc
                                       else j_6__
                  end) in
    go bitmap z.

Definition foldl' {a} : (a -> Key -> a) -> a -> IntSet -> a :=
  fun f z =>
    let fix go arg_0__ arg_1__
              := match arg_0__ , arg_1__ with
                   | z' , Nil => z'
                   | z' , Tip kx bm => foldl'Bits kx f z' bm
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

Definition maskW :=
  fun i m =>
    Coq.ZArith.BinInt.Z.of_N (i Data.Bits..&.(**) Data.Bits.xor
                             (Data.Bits.complement (m GHC.Num.- GHC.Num.fromInteger 1)) m).

Definition natFromInt : GHC.Num.Int -> N :=
  fun i => GHC.Real.fromIntegral i.

Definition shorter : GHC.Num.Int -> GHC.Num.Int -> bool :=
  fun m1 m2 => (natFromInt m1) GHC.Base.> (natFromInt m2).

Definition zero : GHC.Num.Int -> GHC.Num.Int -> bool :=
  fun i m =>
    ((natFromInt i) Data.Bits..&.(**) (natFromInt m)) GHC.Base.==
    GHC.Num.fromInteger 0.

Definition mask : GHC.Num.Int -> GHC.Num.Int -> Prefix :=
  fun i m => maskW (natFromInt i) (natFromInt m).

Definition match_ : GHC.Num.Int -> Prefix -> GHC.Num.Int -> bool :=
  fun i p m => (mask i m) GHC.Base.== p.

Definition nomatch : GHC.Num.Int -> Prefix -> GHC.Num.Int -> bool :=
  fun i p m => (mask i m) GHC.Base./= p.

Definition subsetCmp : IntSet -> IntSet -> comparison :=
  fix subsetCmp arg_0__ arg_1__
        := let j_12__ :=
             match arg_0__ , arg_1__ with
               | Bin _ _ _ _ , _ => Gt
               | Tip kx1 bm1 , Tip kx2 bm2 => if kx1 GHC.Base./= kx2 : bool
                                              then Gt
                                              else if bm1 GHC.Base.== bm2 : bool
                                                   then Eq
                                                   else if (bm1 Data.Bits..&.(**) Data.Bits.complement bm2) GHC.Base.==
                                                           GHC.Num.fromInteger 0 : bool
                                                        then Lt
                                                        else Gt
               | (Tip kx _ as t1) , Bin p m l r => if nomatch kx p m : bool
                                                   then Gt
                                                   else if zero kx m : bool
                                                        then match subsetCmp t1 l with
                                                               | Gt => Gt
                                                               | _ => Lt
                                                             end
                                                        else match subsetCmp t1 r with
                                                               | Gt => Gt
                                                               | _ => Lt
                                                             end
               | Tip _ _ , Nil => Gt
               | Nil , Nil => Eq
               | Nil , _ => Lt
             end in
           match arg_0__ , arg_1__ with
             | (Bin p1 m1 l1 r1 as t1) , Bin p2 m2 l2 r2 => let subsetCmpEq :=
                                                              match pair (subsetCmp l1 l2) (subsetCmp r1 r2) with
                                                                | pair Gt _ => Gt
                                                                | pair _ Gt => Gt
                                                                | pair Eq Eq => Eq
                                                                | _ => Lt
                                                              end in
                                                            let subsetCmpLt :=
                                                              if nomatch p1 p2 m2 : bool
                                                              then Gt
                                                              else if zero p1 m2 : bool
                                                                   then subsetCmp t1 l2
                                                                   else subsetCmp t1 r2 in
                                                            if shorter m1 m2 : bool
                                                            then Gt
                                                            else if shorter m2 m1 : bool
                                                                 then match subsetCmpLt with
                                                                        | Gt => Gt
                                                                        | _ => Lt
                                                                      end
                                                                 else if p1 GHC.Base.== p2 : bool
                                                                      then subsetCmpEq
                                                                      else Gt
             | _ , _ => j_12__
           end.

Definition isProperSubsetOf : IntSet -> IntSet -> bool :=
  fun t1 t2 => match subsetCmp t1 t2 with | Lt => true | _ => false end.

Definition isSubsetOf : IntSet -> IntSet -> bool :=
  fix isSubsetOf arg_0__ arg_1__
        := let j_6__ :=
             match arg_0__ , arg_1__ with
               | Bin _ _ _ _ , _ => false
               | Tip kx1 bm1 , Tip kx2 bm2 => andb (kx1 GHC.Base.== kx2) ((bm1
                                                   Data.Bits..&.(**) Data.Bits.complement bm2) GHC.Base.==
                                                   GHC.Num.fromInteger 0)
               | (Tip kx _ as t1) , Bin p m l r => if nomatch kx p m : bool
                                                   then false
                                                   else if zero kx m : bool
                                                        then isSubsetOf t1 l
                                                        else isSubsetOf t1 r
               | Tip _ _ , Nil => false
               | Nil , _ => true
             end in
           match arg_0__ , arg_1__ with
             | (Bin p1 m1 l1 r1 as t1) , Bin p2 m2 l2 r2 => if shorter m1 m2 : bool
                                                            then false
                                                            else if shorter m2 m1 : bool
                                                                 then andb (match_ p1 p2 m2) (if zero p1 m2 : bool
                                                                           then isSubsetOf t1 l2
                                                                           else isSubsetOf t1 r2)
                                                                 else andb (p1 GHC.Base.== p2) (andb (isSubsetOf l1 l2)
                                                                                                     (isSubsetOf r1 r2))
             | _ , _ => j_6__
           end.

Program Fixpoint disjoint (arg_0__ : IntSet) (arg_1__ : IntSet)
                          {measure (size_nat arg_0__ + size_nat arg_1__)} : bool
                   := match arg_0__ , arg_1__ with
                        | (Bin p1 m1 l1 r1 as t1) , (Bin p2 m2 l2 r2 as t2) => let disjoint2 :=
                                                                                 match nomatch p1 p2 m2 with
                                                                                   | true => true
                                                                                   | false => match zero p1 m2 with
                                                                                                | true => disjoint t1 l2
                                                                                                | false => disjoint t1
                                                                                                           r2
                                                                                              end
                                                                                 end in
                                                                               let disjoint1 :=
                                                                                 match nomatch p2 p1 m1 with
                                                                                   | true => true
                                                                                   | false => match zero p2 m1 with
                                                                                                | true => disjoint l1 t2
                                                                                                | false => disjoint r1
                                                                                                           t2
                                                                                              end
                                                                                 end in
                                                                               match shorter m1 m2 with
                                                                                 | true => disjoint1
                                                                                 | false => match shorter m2 m1 with
                                                                                              | true => disjoint2
                                                                                              | false => match p1
                                                                                                                 GHC.Base.==
                                                                                                                 p2 with
                                                                                                           | true =>
                                                                                                             andb
                                                                                                             (disjoint
                                                                                                             l1 l2)
                                                                                                             (disjoint
                                                                                                             r1 r2)
                                                                                                           | false =>
                                                                                                             true
                                                                                                         end
                                                                                            end
                                                                               end
                        | (Bin _ _ _ _ as t1) , Tip kx2 bm2 => let fix disjointBM arg_11__
                                                                         := match arg_11__ with
                                                                              | Bin p1 m1 l1 r1 => match nomatch kx2 p1
                                                                                                           m1 with
                                                                                                     | true => true
                                                                                                     | false =>
                                                                                                       match zero kx2
                                                                                                               m1 with
                                                                                                         | true =>
                                                                                                           disjointBM l1
                                                                                                         | false =>
                                                                                                           disjointBM r1
                                                                                                       end
                                                                                                   end
                                                                              | Tip kx1 bm1 => match kx1 GHC.Base.==
                                                                                                       kx2 with
                                                                                                 | true => (bm1
                                                                                                           Data.Bits..&.(**)
                                                                                                           bm2)
                                                                                                           GHC.Base.==
                                                                                                           GHC.Num.fromInteger
                                                                                                           0
                                                                                                 | false => true
                                                                                               end
                                                                              | Nil => true
                                                                            end in
                                                               disjointBM t1
                        | Bin _ _ _ _ , Nil => true
                        | Tip kx1 bm1 , t2 => let fix disjointBM arg_18__
                                                        := match arg_18__ with
                                                             | Bin p2 m2 l2 r2 => match nomatch kx1 p2 m2 with
                                                                                    | true => true
                                                                                    | false => match zero kx1 m2 with
                                                                                                 | true => disjointBM l2
                                                                                                 | false => disjointBM
                                                                                                            r2
                                                                                               end
                                                                                  end
                                                             | Tip kx2 bm2 => match kx1 GHC.Base.== kx2 with
                                                                                | true => (bm1 Data.Bits..&.(**) bm2)
                                                                                          GHC.Base.==
                                                                                          GHC.Num.fromInteger 0
                                                                                | false => true
                                                                              end
                                                             | Nil => true
                                                           end in
                                              disjointBM t2
                        | Nil , _ => true
                      end.
Solve Obligations with (termination_by_omega).

Definition link : Prefix -> IntSet -> Prefix -> IntSet -> IntSet :=
  fun p1 t1 p2 t2 =>
    let m := branchMask p1 p2 in
    let p := mask p1 m in if zero p1 m : bool then Bin p m t1 t2 else Bin p m t2 t1.

Definition insertBM : Prefix -> Int64.int -> IntSet -> IntSet :=
  fix insertBM arg_0__ arg_1__ arg_2__
        := match arg_0__ , arg_1__ , arg_2__ with
             | kx , bm , (Bin p m l r as t) => if nomatch kx p m : bool
                                               then link kx (Tip kx bm) p t
                                               else if zero kx m : bool
                                                    then Bin p m (insertBM kx bm l) r
                                                    else Bin p m l (insertBM kx bm r)
             | kx , bm , (Tip kx' bm' as t) => if kx' GHC.Base.== kx : bool
                                               then Tip kx' (bm Data.Bits..|.(**) bm')
                                               else link kx (Tip kx bm) kx' t
             | kx , bm , Nil => Tip kx bm
           end.

Program Fixpoint union (arg_0__ : IntSet) (arg_1__ : IntSet) {measure (size_nat
                       arg_0__ + size_nat arg_1__)} : IntSet
                   := match arg_0__ , arg_1__ with
                        | (Bin p1 m1 l1 r1 as t1) , (Bin p2 m2 l2 r2 as t2) => let union2 :=
                                                                                 match nomatch p1 p2 m2 with
                                                                                   | true => link p1 t1 p2 t2
                                                                                   | false => match zero p1 m2 with
                                                                                                | true => Bin p2 m2
                                                                                                          (union t1 l2)
                                                                                                          r2
                                                                                                | false => Bin p2 m2 l2
                                                                                                           (union t1 r2)
                                                                                              end
                                                                                 end in
                                                                               let union1 :=
                                                                                 match nomatch p2 p1 m1 with
                                                                                   | true => link p1 t1 p2 t2
                                                                                   | false => match zero p2 m1 with
                                                                                                | true => Bin p1 m1
                                                                                                          (union l1 t2)
                                                                                                          r1
                                                                                                | false => Bin p1 m1 l1
                                                                                                           (union r1 t2)
                                                                                              end
                                                                                 end in
                                                                               match shorter m1 m2 with
                                                                                 | true => union1
                                                                                 | false => match shorter m2 m1 with
                                                                                              | true => union2
                                                                                              | false => match p1
                                                                                                                 GHC.Base.==
                                                                                                                 p2 with
                                                                                                           | true => Bin
                                                                                                                     p1
                                                                                                                     m1
                                                                                                                     (union
                                                                                                                     l1
                                                                                                                     l2)
                                                                                                                     (union
                                                                                                                     r1
                                                                                                                     r2)
                                                                                                           | false =>
                                                                                                             link p1 t1
                                                                                                             p2 t2
                                                                                                         end
                                                                                            end
                                                                               end
                        | (Bin _ _ _ _ as t) , Tip kx bm => insertBM kx bm t
                        | (Bin _ _ _ _ as t) , Nil => t
                        | Tip kx bm , t => insertBM kx bm t
                        | Nil , t => t
                      end.
Solve Obligations with (termination_by_omega).

Definition unions : list IntSet -> IntSet :=
  fun xs => Data.Foldable.foldl union empty xs.

Definition nequal : IntSet -> IntSet -> bool :=
  fix nequal arg_0__ arg_1__
        := match arg_0__ , arg_1__ with
             | Bin p1 m1 l1 r1 , Bin p2 m2 l2 r2 => orb (m1 GHC.Base./= m2) (orb (p1
                                                                                 GHC.Base./= p2) (orb (nequal l1 l2)
                                                                                                      (nequal r1 r2)))
             | Tip kx1 bm1 , Tip kx2 bm2 => orb (kx1 GHC.Base./= kx2) (bm1 GHC.Base./= bm2)
             | Nil , Nil => false
             | _ , _ => true
           end.

Local Definition Eq___IntSet_op_zsze__ : IntSet -> IntSet -> bool :=
  fun t1 t2 => nequal t1 t2.

Program Instance Eq___IntSet : GHC.Base.Eq_ IntSet := fun _ k =>
    k {|GHC.Base.op_zeze____ := Eq___IntSet_op_zeze__ ;
      GHC.Base.op_zsze____ := Eq___IntSet_op_zsze__ |}.
Admit Obligations.

Definition node : GHC.Base.String :=
  GHC.Base.hs_string__ "+--".

Definition null : IntSet -> bool :=
  fun arg_0__ => match arg_0__ with | Nil => true | _ => false end.

Definition prefixBitMask : GHC.Num.Int :=
  Data.Bits.complement suffixBitMask.

Definition prefixOf : GHC.Num.Int -> Prefix :=
  fun x => x Data.Bits..&.(**) prefixBitMask.

Definition revNat : Int64.int -> Int64.int :=
  fun x1 =>
    match ((shiftRL x1 (GHC.Num.fromInteger 1)) Data.Bits..&.(**)
            GHC.Num.fromInteger 6148914691236517205) Data.Bits..|.(**) (shiftLL (x1
                                                                                Data.Bits..&.(**) GHC.Num.fromInteger
                                                                                6148914691236517205)
                                                                                (GHC.Num.fromInteger 1)) with
      | x2 => match ((shiftRL x2 (GHC.Num.fromInteger 2)) Data.Bits..&.(**)
                      GHC.Num.fromInteger 3689348814741910323) Data.Bits..|.(**) (shiftLL (x2
                                                                                          Data.Bits..&.(**)
                                                                                          GHC.Num.fromInteger
                                                                                          3689348814741910323)
                                                                                          (GHC.Num.fromInteger 2)) with
                | x3 => match ((shiftRL x3 (GHC.Num.fromInteger 4)) Data.Bits..&.(**)
                                GHC.Num.fromInteger 1085102592571150095) Data.Bits..|.(**) (shiftLL (x3
                                                                                                    Data.Bits..&.(**)
                                                                                                    GHC.Num.fromInteger
                                                                                                    1085102592571150095)
                                                                                                    (GHC.Num.fromInteger
                                                                                                    4)) with
                          | x4 => match ((shiftRL x4 (GHC.Num.fromInteger 8)) Data.Bits..&.(**)
                                          GHC.Num.fromInteger 71777214294589695) Data.Bits..|.(**) (shiftLL (x4
                                                                                                            Data.Bits..&.(**)
                                                                                                            GHC.Num.fromInteger
                                                                                                            71777214294589695)
                                                                                                            (GHC.Num.fromInteger
                                                                                                            8)) with
                                    | x5 => match ((shiftRL x5 (GHC.Num.fromInteger 16)) Data.Bits..&.(**)
                                                    GHC.Num.fromInteger 281470681808895) Data.Bits..|.(**) (shiftLL (x5
                                                                                                                    Data.Bits..&.(**)
                                                                                                                    GHC.Num.fromInteger
                                                                                                                    281470681808895)
                                                                                                                    (GHC.Num.fromInteger
                                                                                                                    16)) with
                                              | x6 => (shiftRL x6 (GHC.Num.fromInteger 32)) Data.Bits..|.(**) (shiftLL
                                                      x6 (GHC.Num.fromInteger 32))
                                            end
                                  end
                        end
              end
    end.

Definition foldrBits {a}
    : GHC.Num.Int -> (GHC.Num.Int -> a -> a) -> a -> Int64.int -> a :=
  fun prefix f z bitmap =>
    let go :=
      unsafeFix (fun go arg_0__ arg_1__ =>
                  let j_6__ :=
                    match arg_0__ , arg_1__ with
                      | bm , acc => match lowestBitMask bm with
                                      | bitmask => match indexOfTheOnlyBit bitmask with
                                                     | bi => go (Data.Bits.xor bm bitmask) ((f GHC.Base.$! ((prefix
                                                                                           GHC.Num.+
                                                                                           (GHC.Num.fromInteger 64
                                                                                           GHC.Num.- GHC.Num.fromInteger
                                                                                           1)) GHC.Num.- bi)) acc)
                                                   end
                                    end
                    end in
                  match arg_0__ , arg_1__ with
                    | num_2__ , acc => if num_2__ GHC.Base.== GHC.Num.fromInteger 0 : bool
                                       then acc
                                       else j_6__
                  end) in
    go (revNat bitmap) z.

Definition foldr {b} : (Key -> b -> b) -> b -> IntSet -> b :=
  fun f z =>
    let fix go arg_0__ arg_1__
              := match arg_0__ , arg_1__ with
                   | z' , Nil => z'
                   | z' , Tip kx bm => foldrBits kx f z' bm
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

Definition foldrFB {b} : (Key -> b -> b) -> b -> IntSet -> b :=
  foldr.

Definition toAscList : IntSet -> list Key :=
  foldr cons nil.

Definition toList : IntSet -> list Key :=
  toAscList.

Definition elems : IntSet -> list Key :=
  toAscList.

Local Definition Ord__IntSet_compare : IntSet -> IntSet -> comparison :=
  fun s1 s2 => GHC.Base.compare (toAscList s1) (toAscList s2).

Local Definition Ord__IntSet_op_zg__ : IntSet -> IntSet -> bool :=
  fun x y => _GHC.Base.==_ (Ord__IntSet_compare x y) Gt.

Local Definition Ord__IntSet_op_zgze__ : IntSet -> IntSet -> bool :=
  fun x y => _GHC.Base./=_ (Ord__IntSet_compare x y) Lt.

Local Definition Ord__IntSet_op_zl__ : IntSet -> IntSet -> bool :=
  fun x y => _GHC.Base.==_ (Ord__IntSet_compare x y) Lt.

Local Definition Ord__IntSet_op_zlze__ : IntSet -> IntSet -> bool :=
  fun x y => _GHC.Base./=_ (Ord__IntSet_compare x y) Gt.

Local Definition Ord__IntSet_max : IntSet -> IntSet -> IntSet :=
  fun x y => if Ord__IntSet_op_zlze__ x y : bool then y else x.

Local Definition Ord__IntSet_min : IntSet -> IntSet -> IntSet :=
  fun x y => if Ord__IntSet_op_zlze__ x y : bool then x else y.

Program Instance Ord__IntSet : GHC.Base.Ord IntSet := fun _ k =>
    k {|GHC.Base.op_zl____ := Ord__IntSet_op_zl__ ;
      GHC.Base.op_zlze____ := Ord__IntSet_op_zlze__ ;
      GHC.Base.op_zg____ := Ord__IntSet_op_zg__ ;
      GHC.Base.op_zgze____ := Ord__IntSet_op_zgze__ ;
      GHC.Base.compare__ := Ord__IntSet_compare ;
      GHC.Base.max__ := Ord__IntSet_max ;
      GHC.Base.min__ := Ord__IntSet_min |}.
Admit Obligations.

Definition fold {b} : (Key -> b -> b) -> b -> IntSet -> b :=
  foldr.

Definition foldr'Bits {a}
    : GHC.Num.Int -> (GHC.Num.Int -> a -> a) -> a -> Int64.int -> a :=
  fun prefix f z bitmap =>
    let go :=
      unsafeFix (fun go arg_0__ arg_1__ =>
                  let j_6__ :=
                    match arg_0__ , arg_1__ with
                      | bm , acc => match lowestBitMask bm with
                                      | bitmask => match indexOfTheOnlyBit bitmask with
                                                     | bi => go (Data.Bits.xor bm bitmask) ((f GHC.Base.$! ((prefix
                                                                                           GHC.Num.+
                                                                                           (GHC.Num.fromInteger 64
                                                                                           GHC.Num.- GHC.Num.fromInteger
                                                                                           1)) GHC.Num.- bi)) acc)
                                                   end
                                    end
                    end in
                  match arg_0__ , arg_1__ with
                    | num_2__ , acc => if num_2__ GHC.Base.== GHC.Num.fromInteger 0 : bool
                                       then acc
                                       else j_6__
                  end) in
    go (revNat bitmap) z.

Definition foldr' {b} : (Key -> b -> b) -> b -> IntSet -> b :=
  fun f z =>
    let fix go arg_0__ arg_1__
              := match arg_0__ , arg_1__ with
                   | z' , Nil => z'
                   | z' , Tip kx bm => foldr'Bits kx f z' bm
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

Definition size : IntSet -> GHC.Num.Int :=
  let fix go arg_0__ arg_1__
            := match arg_0__ , arg_1__ with
                 | acc , Bin _ _ l r => go (go acc l) r
                 | acc , Tip _ bm => acc GHC.Num.+ _GHC.Num.+_ (GHC.Num.fromInteger 0)
                                                               (Data.Bits.popCount (GHC.Num.fromInteger 0))
                 | acc , Nil => acc
               end in
  go (GHC.Num.fromInteger 0).

Definition splitRoot : IntSet -> list IntSet :=
  fun arg_0__ =>
    match arg_0__ with
      | Nil => nil
      | (Tip _ _ as x) => cons x nil
      | Bin _ m l r => if m GHC.Base.< GHC.Num.fromInteger 0 : bool
                       then cons r (cons l nil)
                       else cons l (cons r nil)
    end.

Definition suffixOf : GHC.Num.Int -> GHC.Num.Int :=
  fun x => x Data.Bits..&.(**) suffixBitMask.

Definition bitmapOf : GHC.Num.Int -> Int64.int :=
  fun x => bitmapOfSuffix (suffixOf x).

Definition insert : Key -> IntSet -> IntSet :=
  fun x => insertBM (prefixOf x) (bitmapOf x).

Definition fromList : list Key -> IntSet :=
  fun xs => let ins := fun t x => insert x t in Data.Foldable.foldl ins empty xs.

Definition map : (Key -> Key) -> IntSet -> IntSet :=
  fun f => fromList GHC.Base.∘ (GHC.Base.map f GHC.Base.∘ toList).

Definition lookupGE : Key -> IntSet -> option Key :=
  fun x t =>
    let fix go arg_0__ arg_1__
              := match arg_0__ , arg_1__ with
                   | def , Bin p m l r => if nomatch x p m : bool
                                          then if x GHC.Base.< p : bool
                                               then unsafeFindMin l
                                               else unsafeFindMin def
                                          else if zero x m : bool
                                               then go r l
                                               else go def r
                   | def , Tip kx bm => let maskGE :=
                                          (GHC.Num.negate (bitmapOf x)) Data.Bits..&.(**) bm in
                                        if prefixOf x GHC.Base.< kx : bool
                                        then Some GHC.Base.$ (kx GHC.Num.+ lowestBitSet bm)
                                        else if andb (prefixOf x GHC.Base.== kx) (maskGE GHC.Base./= GHC.Num.fromInteger
                                                     0) : bool
                                             then Some GHC.Base.$ (kx GHC.Num.+ lowestBitSet maskGE)
                                             else unsafeFindMin def
                   | def , Nil => unsafeFindMin def
                 end in
    let j_12__ := go Nil t in
    match t with
      | Bin _ m l r => if m GHC.Base.< GHC.Num.fromInteger 0 : bool
                       then if x GHC.Base.>= GHC.Num.fromInteger 0 : bool
                            then go Nil l
                            else go l r
                       else j_12__
      | _ => j_12__
    end.

Definition lookupGT : Key -> IntSet -> option Key :=
  fun x t =>
    let fix go arg_0__ arg_1__
              := match arg_0__ , arg_1__ with
                   | def , Bin p m l r => if nomatch x p m : bool
                                          then if x GHC.Base.< p : bool
                                               then unsafeFindMin l
                                               else unsafeFindMin def
                                          else if zero x m : bool
                                               then go r l
                                               else go def r
                   | def , Tip kx bm => let maskGT :=
                                          (GHC.Num.negate (shiftLL (bitmapOf x) (GHC.Num.fromInteger 1)))
                                          Data.Bits..&.(**) bm in
                                        if prefixOf x GHC.Base.< kx : bool
                                        then Some GHC.Base.$ (kx GHC.Num.+ lowestBitSet bm)
                                        else if andb (prefixOf x GHC.Base.== kx) (maskGT GHC.Base./= GHC.Num.fromInteger
                                                     0) : bool
                                             then Some GHC.Base.$ (kx GHC.Num.+ lowestBitSet maskGT)
                                             else unsafeFindMin def
                   | def , Nil => unsafeFindMin def
                 end in
    let j_12__ := go Nil t in
    match t with
      | Bin _ m l r => if m GHC.Base.< GHC.Num.fromInteger 0 : bool
                       then if x GHC.Base.>= GHC.Num.fromInteger 0 : bool
                            then go Nil l
                            else go l r
                       else j_12__
      | _ => j_12__
    end.

Definition lookupLE : Key -> IntSet -> option Key :=
  fun x t =>
    let fix go arg_0__ arg_1__
              := match arg_0__ , arg_1__ with
                   | def , Bin p m l r => if nomatch x p m : bool
                                          then if x GHC.Base.< p : bool
                                               then unsafeFindMax def
                                               else unsafeFindMax r
                                          else if zero x m : bool
                                               then go def l
                                               else go l r
                   | def , Tip kx bm => let maskLE :=
                                          ((shiftLL (bitmapOf x) (GHC.Num.fromInteger 1)) GHC.Num.- GHC.Num.fromInteger
                                          1) Data.Bits..&.(**) bm in
                                        if prefixOf x GHC.Base.> kx : bool
                                        then Some GHC.Base.$ (kx GHC.Num.+ highestBitSet bm)
                                        else if andb (prefixOf x GHC.Base.== kx) (maskLE GHC.Base./= GHC.Num.fromInteger
                                                     0) : bool
                                             then Some GHC.Base.$ (kx GHC.Num.+ highestBitSet maskLE)
                                             else unsafeFindMax def
                   | def , Nil => unsafeFindMax def
                 end in
    let j_12__ := go Nil t in
    match t with
      | Bin _ m l r => if m GHC.Base.< GHC.Num.fromInteger 0 : bool
                       then if x GHC.Base.>= GHC.Num.fromInteger 0 : bool
                            then go r l
                            else go Nil r
                       else j_12__
      | _ => j_12__
    end.

Definition lookupLT : Key -> IntSet -> option Key :=
  fun x t =>
    let fix go arg_0__ arg_1__
              := match arg_0__ , arg_1__ with
                   | def , Bin p m l r => if nomatch x p m : bool
                                          then if x GHC.Base.< p : bool
                                               then unsafeFindMax def
                                               else unsafeFindMax r
                                          else if zero x m : bool
                                               then go def l
                                               else go l r
                   | def , Tip kx bm => let maskLT :=
                                          (bitmapOf x GHC.Num.- GHC.Num.fromInteger 1) Data.Bits..&.(**) bm in
                                        if prefixOf x GHC.Base.> kx : bool
                                        then Some GHC.Base.$ (kx GHC.Num.+ highestBitSet bm)
                                        else if andb (prefixOf x GHC.Base.== kx) (maskLT GHC.Base./= GHC.Num.fromInteger
                                                     0) : bool
                                             then Some GHC.Base.$ (kx GHC.Num.+ highestBitSet maskLT)
                                             else unsafeFindMax def
                   | def , Nil => unsafeFindMax def
                 end in
    let j_12__ := go Nil t in
    match t with
      | Bin _ m l r => if m GHC.Base.< GHC.Num.fromInteger 0 : bool
                       then if x GHC.Base.>= GHC.Num.fromInteger 0 : bool
                            then go r l
                            else go Nil r
                       else j_12__
      | _ => j_12__
    end.

Definition member : Key -> IntSet -> bool :=
  fun x =>
    let fix go arg_0__
              := match arg_0__ with
                   | Bin p m l r => if nomatch x p m : bool
                                    then false
                                    else if zero x m : bool
                                         then go l
                                         else go r
                   | Tip y bm => andb (prefixOf x GHC.Base.== y) ((bitmapOf x Data.Bits..&.(**) bm)
                                      GHC.Base./= GHC.Num.fromInteger 0)
                   | Nil => false
                 end in
    go.

Definition notMember : Key -> IntSet -> bool :=
  fun k => negb GHC.Base.∘ member k.

Definition singleton : Key -> IntSet :=
  fun x => Tip (prefixOf x) (bitmapOf x).

Definition tip : Prefix -> Int64.int -> IntSet :=
  fun arg_0__ arg_1__ =>
    let j_4__ := match arg_0__ , arg_1__ with | kx , bm => Tip kx bm end in
    match arg_0__ , arg_1__ with
      | _ , num_2__ => if num_2__ GHC.Base.== GHC.Num.fromInteger 0 : bool
                       then Nil
                       else j_4__
    end.

Definition split : Key -> IntSet -> (IntSet * IntSet)%type :=
  fun x t =>
    let fix go arg_0__ arg_1__
              := match arg_0__ , arg_1__ with
                   | x' , (Bin p m l r as t') => if match_ x' p m : bool
                                                 then if zero x' m : bool
                                                      then match go x' l with
                                                             | pair lt gt => pair lt (union gt r)
                                                           end
                                                      else match go x' r with
                                                             | pair lt gt => pair (union lt l) gt
                                                           end
                                                 else if x' GHC.Base.< p : bool
                                                      then (pair Nil t')
                                                      else (pair t' Nil)
                   | x' , (Tip kx' bm as t') => let lowerBitmap :=
                                                  bitmapOf x' GHC.Num.- GHC.Num.fromInteger 1 in
                                                let higherBitmap :=
                                                  Data.Bits.complement (lowerBitmap GHC.Num.+ bitmapOf x') in
                                                if kx' GHC.Base.> x' : bool
                                                then (pair Nil t')
                                                else if kx' GHC.Base.< prefixOf x' : bool
                                                     then (pair t' Nil)
                                                     else pair (tip kx' (bm Data.Bits..&.(**) lowerBitmap)) (tip kx' (bm
                                                                                                                     Data.Bits..&.(**)
                                                                                                                     higherBitmap))
                   | _ , Nil => (pair Nil Nil)
                 end in
    let j_21__ := match go x t with | pair lt gt => pair lt gt end in
    match t with
      | Bin _ m l r => if m GHC.Base.< GHC.Num.fromInteger 0 : bool
                       then if x GHC.Base.>= GHC.Num.fromInteger 0 : bool
                            then match go x l with
                                   | pair lt gt => match union lt r with
                                                     | lt' => pair lt' gt
                                                   end
                                 end
                            else match go x r with
                                   | pair lt gt => match union gt l with
                                                     | gt' => pair lt gt'
                                                   end
                                 end
                       else j_21__
      | _ => j_21__
    end.

Definition splitMember : Key -> IntSet -> (IntSet * bool * IntSet)%type :=
  fun x t =>
    let fix go arg_0__ arg_1__
              := match arg_0__ , arg_1__ with
                   | x' , (Bin p m l r as t') => if match_ x' p m : bool
                                                 then if zero x' m : bool
                                                      then match go x' l with
                                                             | pair (pair lt fnd) gt => pair (pair lt fnd) (union gt r)
                                                           end
                                                      else match go x' r with
                                                             | pair (pair lt fnd) gt => pair (pair (union lt l) fnd) gt
                                                           end
                                                 else if x' GHC.Base.< p : bool
                                                      then pair (pair Nil false) t'
                                                      else pair (pair t' false) Nil
                   | x' , (Tip kx' bm as t') => let bitmapOfx' := bitmapOf x' in
                                                let lowerBitmap := bitmapOfx' GHC.Num.- GHC.Num.fromInteger 1 in
                                                let higherBitmap :=
                                                  Data.Bits.complement (lowerBitmap GHC.Num.+ bitmapOfx') in
                                                if kx' GHC.Base.> x' : bool
                                                then pair (pair Nil false) t'
                                                else if kx' GHC.Base.< prefixOf x' : bool
                                                     then pair (pair t' false) Nil
                                                     else match tip kx' (bm Data.Bits..&.(**) higherBitmap) with
                                                            | gt => match (bm Data.Bits..&.(**) bitmapOfx') GHC.Base./=
                                                                            GHC.Num.fromInteger 0 with
                                                                      | found => match tip kx' (bm Data.Bits..&.(**)
                                                                                               lowerBitmap) with
                                                                                   | lt => pair (pair lt found) gt
                                                                                 end
                                                                    end
                                                          end
                   | _ , Nil => pair (pair Nil false) Nil
                 end in
    let j_22__ := go x t in
    match t with
      | Bin _ m l r => if m GHC.Base.< GHC.Num.fromInteger 0 : bool
                       then if x GHC.Base.>= GHC.Num.fromInteger 0 : bool
                            then match go x l with
                                   | pair (pair lt fnd) gt => match union lt r with
                                                                | lt' => pair (pair lt' fnd) gt
                                                              end
                                 end
                            else match go x r with
                                   | pair (pair lt fnd) gt => match union gt l with
                                                                | gt' => pair (pair lt fnd) gt'
                                                              end
                                 end
                       else j_22__
      | _ => j_22__
    end.

Definition deleteBM : Prefix -> Int64.int -> IntSet -> IntSet :=
  fix deleteBM arg_0__ arg_1__ arg_2__
        := match arg_0__ , arg_1__ , arg_2__ with
             | kx , bm , (Bin p m l r as t) => if nomatch kx p m : bool
                                               then t
                                               else if zero kx m : bool
                                                    then bin p m (deleteBM kx bm l) r
                                                    else bin p m l (deleteBM kx bm r)
             | kx , bm , (Tip kx' bm' as t) => if kx' GHC.Base.== kx : bool
                                               then tip kx (bm' Data.Bits..&.(**) Data.Bits.complement bm)
                                               else t
             | _ , _ , Nil => Nil
           end.

Definition delete : Key -> IntSet -> IntSet :=
  fun x => deleteBM (prefixOf x) (bitmapOf x).

Program Fixpoint difference (arg_0__ : IntSet) (arg_1__ : IntSet)
                            {measure (size_nat arg_0__ + size_nat arg_1__)} : IntSet
                   := match arg_0__ , arg_1__ with
                        | (Bin p1 m1 l1 r1 as t1) , (Bin p2 m2 l2 r2 as t2) => let difference2 :=
                                                                                 match nomatch p1 p2 m2 with
                                                                                   | true => t1
                                                                                   | false => match zero p1 m2 with
                                                                                                | true => difference t1
                                                                                                          l2
                                                                                                | false => difference t1
                                                                                                           r2
                                                                                              end
                                                                                 end in
                                                                               let difference1 :=
                                                                                 match nomatch p2 p1 m1 with
                                                                                   | true => t1
                                                                                   | false => match zero p2 m1 with
                                                                                                | true => bin p1 m1
                                                                                                          (difference l1
                                                                                                          t2) r1
                                                                                                | false => bin p1 m1 l1
                                                                                                           (difference
                                                                                                           r1 t2)
                                                                                              end
                                                                                 end in
                                                                               match shorter m1 m2 with
                                                                                 | true => difference1
                                                                                 | false => match shorter m2 m1 with
                                                                                              | true => difference2
                                                                                              | false => match p1
                                                                                                                 GHC.Base.==
                                                                                                                 p2 with
                                                                                                           | true => bin
                                                                                                                     p1
                                                                                                                     m1
                                                                                                                     (difference
                                                                                                                     l1
                                                                                                                     l2)
                                                                                                                     (difference
                                                                                                                     r1
                                                                                                                     r2)
                                                                                                           | false => t1
                                                                                                         end
                                                                                            end
                                                                               end
                        | (Bin _ _ _ _ as t) , Tip kx bm => deleteBM kx bm t
                        | (Bin _ _ _ _ as t) , Nil => t
                        | (Tip kx bm as t1) , t2 => let fix differenceTip arg_12__
                                                              := match arg_12__ with
                                                                   | Bin p2 m2 l2 r2 => match nomatch kx p2 m2 with
                                                                                          | true => t1
                                                                                          | false => match zero kx
                                                                                                             m2 with
                                                                                                       | true =>
                                                                                                         differenceTip
                                                                                                         l2
                                                                                                       | false =>
                                                                                                         differenceTip
                                                                                                         r2
                                                                                                     end
                                                                                        end
                                                                   | Tip kx2 bm2 => match kx GHC.Base.== kx2 with
                                                                                      | true => tip kx (bm
                                                                                                       Data.Bits..&.(**)
                                                                                                       Data.Bits.complement
                                                                                                       bm2)
                                                                                      | false => t1
                                                                                    end
                                                                   | Nil => t1
                                                                 end in
                                                    differenceTip t2
                        | Nil , _ => Nil
                      end.
Solve Obligations with (termination_by_omega).

Definition op_zrzr__ : IntSet -> IntSet -> IntSet :=
  fun m1 m2 => difference m1 m2.

Notation "'_\\_'" := (op_zrzr__).

Infix "\\" := (_\\_) (at level 99).

Definition filter : (Key -> bool) -> IntSet -> IntSet :=
  fix filter predicate t
        := let bitPred :=
             fun kx bm bi =>
               if predicate (kx GHC.Num.+ bi) : bool
               then bm Data.Bits..|.(**) bitmapOfSuffix bi
               else bm in
           match t with
             | Bin p m l r => bin p m (filter predicate l) (filter predicate r)
             | Tip kx bm => tip kx (foldl'Bits (GHC.Num.fromInteger 0) (bitPred kx)
                                   (GHC.Num.fromInteger 0) bm)
             | Nil => Nil
           end.

Program Fixpoint intersection (arg_0__ : IntSet) (arg_1__ : IntSet)
                              {measure (size_nat arg_0__ + size_nat arg_1__)} : IntSet
                   := match arg_0__ , arg_1__ with
                        | (Bin p1 m1 l1 r1 as t1) , (Bin p2 m2 l2 r2 as t2) => let intersection2 :=
                                                                                 match nomatch p1 p2 m2 with
                                                                                   | true => Nil
                                                                                   | false => match zero p1 m2 with
                                                                                                | true => intersection
                                                                                                          t1 l2
                                                                                                | false => intersection
                                                                                                           t1 r2
                                                                                              end
                                                                                 end in
                                                                               let intersection1 :=
                                                                                 match nomatch p2 p1 m1 with
                                                                                   | true => Nil
                                                                                   | false => match zero p2 m1 with
                                                                                                | true => intersection
                                                                                                          l1 t2
                                                                                                | false => intersection
                                                                                                           r1 t2
                                                                                              end
                                                                                 end in
                                                                               match shorter m1 m2 with
                                                                                 | true => intersection1
                                                                                 | false => match shorter m2 m1 with
                                                                                              | true => intersection2
                                                                                              | false => match p1
                                                                                                                 GHC.Base.==
                                                                                                                 p2 with
                                                                                                           | true => bin
                                                                                                                     p1
                                                                                                                     m1
                                                                                                                     (intersection
                                                                                                                     l1
                                                                                                                     l2)
                                                                                                                     (intersection
                                                                                                                     r1
                                                                                                                     r2)
                                                                                                           | false =>
                                                                                                             Nil
                                                                                                         end
                                                                                            end
                                                                               end
                        | (Bin _ _ _ _ as t1) , Tip kx2 bm2 => let fix intersectBM arg_11__
                                                                         := match arg_11__ with
                                                                              | Bin p1 m1 l1 r1 => match nomatch kx2 p1
                                                                                                           m1 with
                                                                                                     | true => Nil
                                                                                                     | false =>
                                                                                                       match zero kx2
                                                                                                               m1 with
                                                                                                         | true =>
                                                                                                           intersectBM
                                                                                                           l1
                                                                                                         | false =>
                                                                                                           intersectBM
                                                                                                           r1
                                                                                                       end
                                                                                                   end
                                                                              | Tip kx1 bm1 => match kx1 GHC.Base.==
                                                                                                       kx2 with
                                                                                                 | true => tip kx1 (bm1
                                                                                                                   Data.Bits..&.(**)
                                                                                                                   bm2)
                                                                                                 | false => Nil
                                                                                               end
                                                                              | Nil => Nil
                                                                            end in
                                                               intersectBM t1
                        | Bin _ _ _ _ , Nil => Nil
                        | Tip kx1 bm1 , t2 => let fix intersectBM arg_18__
                                                        := match arg_18__ with
                                                             | Bin p2 m2 l2 r2 => match nomatch kx1 p2 m2 with
                                                                                    | true => Nil
                                                                                    | false => match zero kx1 m2 with
                                                                                                 | true => intersectBM
                                                                                                           l2
                                                                                                 | false => intersectBM
                                                                                                            r2
                                                                                               end
                                                                                  end
                                                             | Tip kx2 bm2 => match kx1 GHC.Base.== kx2 with
                                                                                | true => tip kx1 (bm1 Data.Bits..&.(**)
                                                                                                  bm2)
                                                                                | false => Nil
                                                                              end
                                                             | Nil => Nil
                                                           end in
                                              intersectBM t2
                        | Nil , _ => Nil
                      end.
Solve Obligations with (termination_by_omega).

Definition partition : (Key -> bool) -> IntSet -> (IntSet * IntSet)%type :=
  fun predicate0 t0 =>
    let fix go predicate t
              := let bitPred :=
                   fun kx bm bi =>
                     if predicate (kx GHC.Num.+ bi) : bool
                     then bm Data.Bits..|.(**) bitmapOfSuffix bi
                     else bm in
                 match t with
                   | Bin p m l r => match go predicate r with
                                      | pair r1 r2 => match go predicate l with
                                                        | pair l1 l2 => pair (bin p m l1 r1) (bin p m l2 r2)
                                                      end
                                    end
                   | Tip kx bm => let bm1 :=
                                    foldl'Bits (GHC.Num.fromInteger 0) (bitPred kx) (GHC.Num.fromInteger 0) bm in
                                  pair (tip kx bm1) (tip kx (Data.Bits.xor bm bm1))
                   | Nil => (pair Nil Nil)
                 end in
    id GHC.Base.$ go predicate0 t0.

Module Notations.
Notation "'_Data.IntSet.Internal.\\_'" := (op_zrzr__).
Infix "Data.IntSet.Internal.\\" := (_\\_) (at level 99).
End Notations.

(* Unbound variables:
     Eq Gt Lt N None Some andb bool comparison cons false highestBitMask id
     indexOfTheOnlyBit list negb nil op_zp__ op_zt__ option orb pair shiftLL shiftRL
     size_nat suffixBitMask true Coq.ZArith.BinInt.Z.log2 Coq.ZArith.BinInt.Z.lxor
     Coq.ZArith.BinInt.Z.of_N Coq.ZArith.BinInt.Z.pow Data.Bits.complement
     Data.Bits.op_zizazi__ Data.Bits.op_zizbzi__ Data.Bits.popCount Data.Bits.xor
     Data.Foldable.foldl GHC.Base.Eq_ GHC.Base.Ord GHC.Base.String GHC.Base.compare
     GHC.Base.flip GHC.Base.map GHC.Base.op_z2218U__ GHC.Base.op_zd__
     GHC.Base.op_zdzn__ GHC.Base.op_zeze__ GHC.Base.op_zg__ GHC.Base.op_zgze__
     GHC.Base.op_zl__ GHC.Base.op_zsze__ GHC.Num.Int GHC.Num.fromInteger
     GHC.Num.negate GHC.Num.op_zm__ GHC.Num.op_zp__ GHC.Real.fromIntegral Int64.int
*)
