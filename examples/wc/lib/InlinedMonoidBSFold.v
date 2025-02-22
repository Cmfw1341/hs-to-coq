(* Default settings (from HsToCoq.Coq.Preamble) *)

Generalizable All Variables.

Unset Implicit Arguments.
Set Maximal Implicit Insertion.
Unset Strict Implicit.
Unset Printing Implicit Defensive.

Require Coq.Program.Tactics.
Require Coq.Program.Wf.

(* Converted imports: *)

Require BL.
Require Import Data.Functor.
Require Import Data.Traversable.
Require Import GHC.Base.
Require Types.

(* No type declarations to convert. *)

(* Converted value declarations: *)

Definition countFile : BL.ByteString -> Types.Counts :=
  BL.foldl' (fun a b => a <<>> Types.countChar b) mempty.

Definition inlinedMonoidBSFold
   : list String -> IO (list (String * Types.Counts)%type) :=
  fun paths =>
    for_ paths (fun fp =>
                  (countFile <$> BL.readFile fp) >>= (fun count => return_ (pair fp count))).

(* External variables:
     IO String for_ list mempty op_zgzgze__ op_zlzdzg__ op_zlzlzgzg__ op_zt__ pair
     return_ BL.ByteString BL.foldl' BL.readFile Types.Counts Types.countChar
*)
