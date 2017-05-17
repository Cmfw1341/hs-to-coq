{-# LANGUAGE TupleSections, LambdaCase, RecordWildCards,
             OverloadedLists, OverloadedStrings,
             FlexibleContexts #-}

module HsToCoq.ConvertHaskell.Expr (
  -- * Expressions
  convertExpr, convertLExpr,
  -- * Bindings
  convertLocalBinds,
  -- ** Generic
  convertTypedBindings, convertTypedModuleBindings, convertTypedBinding,
  -- * Functions, matches, and guards
  -- ** Functions
  convertFunction,
  -- ** Matches
  convertMatchGroup, convertMatch,
  -- ** `do' blocks and similar
  convertDoBlock, convertListComprehension,
  convertPatternBinding,
  -- ** Guards
  ConvertedGuard(..), convertGuard, guardTerm,
  convertLGRHSList, convertGRHSs, convertGRHS, convertGuards
  ) where

import Control.Lens

import Data.Bifunctor
import Data.Foldable
import Data.Traversable
import Data.Function
import HsToCoq.Util.Function
import Data.Maybe
import Data.List (intercalate)
import HsToCoq.Util.List hiding (unsnoc)
import Data.List.NonEmpty (NonEmpty(..), nonEmpty)
import qualified Data.List.NonEmpty as NEL
import qualified Data.Text as T

import Control.Monad.Trans.Maybe
import Control.Monad.Except
import Control.Monad.Writer

import           Data.Map.Strict (Map)
import qualified Data.Set        as S
import qualified Data.Map.Strict as M

import GHC hiding (Name, HsChar, HsString)
import qualified GHC
import Bag
import BasicTypes
import HsToCoq.Util.GHC.FastString
import RdrName
import HsToCoq.Util.GHC.Exception

import HsToCoq.Util.GHC
import HsToCoq.Util.GHC.HsExpr
import HsToCoq.Coq.Gallina as Coq
import HsToCoq.Coq.Gallina.Util
import HsToCoq.Coq.FreeVars

import HsToCoq.ConvertHaskell.Parameters.Renamings
import HsToCoq.ConvertHaskell.Parameters.Edits
import HsToCoq.ConvertHaskell.Monad
import HsToCoq.ConvertHaskell.InfixNames
import HsToCoq.ConvertHaskell.Variables
import HsToCoq.ConvertHaskell.Definitions
import HsToCoq.ConvertHaskell.Literals
import HsToCoq.ConvertHaskell.Type
import HsToCoq.ConvertHaskell.Pattern
import HsToCoq.ConvertHaskell.Sigs

--------------------------------------------------------------------------------

convertExpr :: ConversionMonad m => HsExpr RdrName -> m Term
convertExpr (HsVar (L _ x)) =
  Var . toPrefix <$> var ExprNS x

convertExpr (HsUnboundVar x) =
  Var <$> freeVar (unboundVarOcc x)

convertExpr (HsRecFld fld) =
  Var . toPrefix <$> var ExprNS (rdrNameAmbiguousFieldOcc fld)

convertExpr (HsOverLabel _) =
  convUnsupported "overloaded labels"

convertExpr (HsIPVar _) =
  convUnsupported "implicit parameters"

convertExpr (HsOverLit OverLit{..}) =
  case ol_val of
    HsIntegral   _src int -> PolyNum <$> convertInteger "integer literals" int
    HsFractional _        -> convUnsupported "fractional literals"
    HsIsString   _src str -> pure $ convertFastString str

convertExpr (HsLit lit) =
  case lit of
    GHC.HsChar   _ c       -> pure $ HsChar c
    HsCharPrim   _ _       -> convUnsupported "`Char#' literals"
    GHC.HsString _ fs      -> pure $ convertFastString fs
    HsStringPrim _ _       -> convUnsupported "`Addr#' literals"
    HsInt        _ _       -> convUnsupported "`Int' literals"
    HsIntPrim    _ _       -> convUnsupported "`Int#' literals"
    HsWordPrim   _ _       -> convUnsupported "`Word#' literals"
    HsInt64Prim  _ _       -> convUnsupported "`Int64#' literals"
    HsWord64Prim _ _       -> convUnsupported "`Word64#' literals"
    HsInteger    _ int _ty -> Num <$> convertInteger "`Integer' literals" int
    HsRat        _ _       -> convUnsupported "`Rational' literals"
    HsFloatPrim  _         -> convUnsupported "`Float#' literals"
    HsDoublePrim _         -> convUnsupported "`Double#' literals"

convertExpr (HsLam mg) =
  uncurry Fun <$> convertFunction mg

convertExpr (HsLamCase PlaceHolder mg) =
  uncurry Fun <$> convertFunction mg

convertExpr (HsApp e1 e2) =
  App1 <$> convertLExpr e1 <*> convertLExpr e2

convertExpr (HsAppType _ _) =
  convUnsupported "type applications"

convertExpr (HsAppTypeOut _ _) =
  convUnsupported "`HsAppTypeOut' constructor"

convertExpr (OpApp el eop PlaceHolder er) =
  case eop of
    L _ (HsVar (L _ hsOp)) -> do
      op <- var ExprNS hsOp
      l  <- convertLExpr el
      r  <- convertLExpr er
      pure $ if identIsOperator op
             then Infix l op r
             else App2 (Var op) l r
    _ ->
      convUnsupported "non-variable infix operators"

convertExpr (NegApp _ _) =
  convUnsupported "negation"

convertExpr (HsPar e) =
  Parens <$> convertLExpr e

convertExpr (SectionL l opE) =
  convert_section (Just l) opE Nothing

convertExpr (SectionR opE r) =
  convert_section Nothing opE (Just r)

-- TODO: Mark converted unboxed tuples specially?
convertExpr (ExplicitTuple exprs _boxity) = do
  -- TODO A tuple constructor in the Gallina grammar?
  (tuple, args) <- runWriterT
                .  fmap (foldl1 . App2 $ Var "pair")
                .  for exprs $ unLoc <&> \case
                     Present e           -> lift $ convertLExpr e
                     Missing PlaceHolder -> do arg <- lift $ gensym "arg"
                                               Var arg <$ tell [arg]
  pure $ maybe id Fun (nonEmpty $ map (Inferred Coq.Explicit . Ident) args) tuple

convertExpr (HsCase e mg) =
  Coq.Match <$> (fmap pure $ MatchItem <$> convertLExpr e <*> pure Nothing <*> pure Nothing)
            <*> pure Nothing
            <*> convertMatchGroup mg

convertExpr (HsIf overloaded c t f) =
  if maybe True isNoSyntaxExpr overloaded
  then If <$> convertLExpr c <*> pure Nothing <*> convertLExpr t <*> convertLExpr f
  else convUnsupported "overloaded if-then-else"

convertExpr (HsMultiIf PlaceHolder lgrhsList) =
  convertLGRHSList [] lgrhsList MissingValue

convertExpr (HsLet (L _ binds) body) =
  convertLocalBinds binds $ convertLExpr body

convertExpr (HsDo sty (L _ stmts) PlaceHolder) =
  case sty of
    ListComp        -> convertListComprehension stmts
    DoExpr          -> convertDoBlock stmts
    
    MonadComp       -> convUnsupported "monad comprehensions"
    PArrComp        -> convUnsupported "parallel array comprehensions"
    MDoExpr         -> convUnsupported "`mdo' expressions"
    ArrowExpr       -> convUnsupported "arrow expressions"
    GhciStmtCtxt    -> convUnsupported "GHCi statement expressions"
    PatGuard _      -> convUnsupported "pattern guard expressions"
    ParStmtCtxt _   -> convUnsupported "parallel statement expressions"
    TransStmtCtxt _ -> convUnsupported "transform statement expressions"

convertExpr (ExplicitList PlaceHolder overloaded exprs) =
  if maybe True isNoSyntaxExpr overloaded
  then foldr (Infix ?? "::") (Var "nil") <$> traverse convertLExpr exprs
  else convUnsupported "overloaded lists"

convertExpr (ExplicitPArr _ _) =
  convUnsupported "explicit parallel arrays"

-- TODO: Unify with the `RecCon` case in `ConPatIn` for `convertPat` (in
-- `HsToCoq.ConvertHaskell.Pattern`)
convertExpr (RecordCon (L _ hsCon) PlaceHolder conExpr HsRecFields{..}) = do
  unless (isNoPostTcExpr conExpr) $
    convUnsupported "unexpected post-typechecker record constructor"
  
  let recConUnsupported what = do
        hsConStr <- ghcPpr hsCon
        convUnsupported $  "creating a record with the " ++ what
                        ++ " constructor `" ++ T.unpack hsConStr ++ "'"
  
  con <- var ExprNS hsCon
  
  use (constructorFields . at con) >>= \case
    Just (RecordFields conFields) -> do
      let defaultVal field | isJust rec_dotdot = Var field
                           | otherwise         = MissingValue
      
      vals <- fmap M.fromList . for rec_flds $ \(L _ (HsRecField (L _ (FieldOcc (L _ hsField) PlaceHolder)) hsVal pun)) -> do
                field <- var ExprNS hsField
                val   <- if pun
                         then pure $ Var field
                         else convertLExpr hsVal
                pure (field, val)
      pure . appList (Var con)
           $ map (\field -> PosArg $ M.findWithDefault (defaultVal field) field vals) conFields
    
    Just (NonRecordFields count)
      | null rec_flds && isNothing rec_dotdot ->
        pure . appList (Var con) $ replicate count (PosArg MissingValue)
      
      | otherwise ->
        recConUnsupported "non-record"
    
    Nothing -> recConUnsupported "unknown"

convertExpr (RecordUpd recVal fields PlaceHolder PlaceHolder PlaceHolder PlaceHolder) = do
  updates <- fmap M.fromList . for fields $ \(L _ HsRecField{..}) -> do
               field <- var ExprNS . rdrNameAmbiguousFieldOcc $ unLoc hsRecFieldLbl
               pure (field, if hsRecPun then Nothing else Just hsRecFieldArg)
  
  let updFields       = M.keys updates
      prettyUpdFields what =
        let quote f = "`" ++ T.unpack f ++ "'"
        in what ++ case assertUnsnoc updFields of
                     ([],   f)  -> " "  ++ quote f
                     ([f1], f2) -> "s " ++ quote f1                        ++ " and "  ++ quote f2
                     (fs,   f') -> "s " ++ intercalate ", " (map quote fs) ++ ", and " ++ quote f'
  
  recType <- S.minView . S.fromList <$> traverse (\field -> use $ recordFieldTypes . at field) updFields >>= \case
               Just (Just recType, []) -> pure recType
               Just (Nothing,      []) -> convUnsupported $ "invalid record update with " ++ prettyUpdFields "non-record-field"
               _                       -> convUnsupported $ "invalid mixed-data-type record updates with " ++ prettyUpdFields "the given field"
  
  ctors   <- maybe (convUnsupported "invalid unknown record type") pure =<< use (constructors . at recType)
  
  let loc  = mkGeneralLocated "generated"
      toHs = mkVarUnqual . fsLit . T.unpack

  let partialUpdateError con =
        GHC.Match { m_fixity = NonFunBindMatch
                  , m_pats   = [ loc . ConPatIn (loc $ toHs con)
                                     . RecCon $ HsRecFields { rec_flds = []
                                                            , rec_dotdot = Nothing } ]
                  , m_type   = Nothing
                  , m_grhss  = GRHSs { grhssGRHSs = [ loc . GRHS [] . loc $
                                                      -- TODO: A special variable which is special-cased to desugar to `MissingValue`?
                                                      HsApp (loc . HsVar . loc . mkVarUnqual $ fsLit "error")
                                                            (loc . HsLit . GHC.HsString "" $ fsLit "Partial record update") ]
                                     , grhssLocalBinds = loc EmptyLocalBinds } }
  
  matches <- for ctors $ \con ->
    use (constructorFields . at con) >>= \case
      Just (RecordFields fields) | all (`elem` fields) $ M.keysSet updates -> do
        let addFieldOcc :: HsRecField' RdrName arg -> HsRecField RdrName arg
            addFieldOcc field@HsRecField{hsRecFieldLbl = L s lbl} =
              field{hsRecFieldLbl = L s $ FieldOcc (L s lbl) PlaceHolder}
            useFields fields = HsRecFields { rec_flds   = map (fmap addFieldOcc) fields
                                           , rec_dotdot = Nothing }
        (fieldPats, fieldVals) <- fmap (bimap useFields useFields . unzip) . for fields $ \field -> do
          fieldVar <- gensym field
          let mkField arg = loc $ HsRecField { hsRecFieldLbl = loc $ toHs field
                                             , hsRecFieldArg = arg
                                             , hsRecPun      = False }
          pure ( mkField . loc . GHC.VarPat . loc $ toHs fieldVar
               , mkField . fromMaybe (loc . HsVar . loc $ toHs field) -- NOT `fieldVar` – this was punned
                         $ M.findWithDefault (Just . loc . HsVar . loc $ toHs fieldVar) field updates )
        
        pure GHC.Match { m_fixity = NonFunBindMatch
                       , m_pats   = [ loc . ConPatIn (loc $ toHs con) $ RecCon fieldPats ]
                       , m_type   = Nothing
                       , m_grhss  = GRHSs { grhssGRHSs = [ loc . GRHS [] . loc $
                                                           RecordCon (loc $ toHs con)
                                                                     PlaceHolder
                                                                     noPostTcExpr
                                                                     fieldVals ]
                                          , grhssLocalBinds = loc EmptyLocalBinds } }
        
      Just _ ->
        pure $ partialUpdateError con
      Nothing ->
        convUnsupported "invalid unknown constructor in record update"
  
  convertExpr . HsCase recVal $ MG { mg_alts    = loc $ map loc matches
                                   , mg_arg_tys = []
                                   , mg_res_ty  = PlaceHolder
                                   , mg_origin  = Generated }


convertExpr (ExprWithTySig e (HsIB PlaceHolder (HsWC PlaceHolder _ss ty))) =
  HasType <$> convertLExpr e <*> convertLType ty

convertExpr (ExprWithTySigOut _ _) =
  convUnsupported "`ExprWithTySigOut' constructor"

convertExpr (ArithSeq _postTc _overloadedLists info) =
  -- TODO: Special-case infinite lists?
  -- TODO: `enumFrom{,Then}{,To}` is really…?
  -- TODO: Add Coq syntax sugar?  Something like
  --
  --     Notation "[ :: from        '..' ]"    := (enumFrom       from).
  --     Notation "[ :: from , next '..' ]"    := (enumFromThen   from next).
  --     Notation "[ :: from        '..' to ]" := (enumFromTo     from      to).
  --     Notation "[ :: from , next '..' to ]" := (enumFromThenTo from next to).
  --
  -- Only `'..'` doesn't work for some reason.
  case info of
    From       low           -> App1 (Var "enumFrom")       <$> convertLExpr low
    FromThen   low next      -> App2 (Var "enumFromThen")   <$> convertLExpr low <*> convertLExpr next
    FromTo     low      high -> App2 (Var "enumFromTo")     <$> convertLExpr low                       <*> convertLExpr high
    FromThenTo low next high -> App3 (Var "enumFromThenTo") <$> convertLExpr low <*> convertLExpr next <*> convertLExpr high

convertExpr (PArrSeq _ _) =
  convUnsupported "parallel array arithmetic sequences"

convertExpr (HsSCC _ _ e) =
  convertLExpr e

convertExpr (HsCoreAnn _ _ e) =
  convertLExpr e

convertExpr (HsBracket _) =
  convUnsupported "Template Haskell brackets"

convertExpr (HsRnBracketOut _ _) =
  convUnsupported "`HsRnBracketOut' constructor"

convertExpr (HsTcBracketOut _ _) =
  convUnsupported "`HsTcBracketOut' constructor"

convertExpr (HsSpliceE _) =
  convUnsupported "Quasiquoters and Template Haskell splices"

convertExpr (HsProc _ _) =
  convUnsupported "`proc' expressions"

convertExpr (HsStatic _) =
  convUnsupported "static pointers"

convertExpr (HsArrApp _ _ _ _ _) =
  convUnsupported "arrow application command"

convertExpr (HsArrForm _ _ _) =
  convUnsupported "arrow command formation"

convertExpr (HsTick _ e) =
  convertLExpr e

convertExpr (HsBinTick _ _ e) =
  convertLExpr e

convertExpr (HsTickPragma _ _ _ e) =
  convertLExpr e

convertExpr EWildPat =
  convUnsupported "wildcard pattern in expression"

convertExpr (EAsPat _ _) =
  convUnsupported "as-pattern in expression"

convertExpr (EViewPat _ _) =
  convUnsupported "view-pattern in expression"

convertExpr (ELazyPat _) =
  convUnsupported "lazy pattern in expression"

convertExpr (HsWrap _ _) =
  convUnsupported "`HsWrap' constructor"

--------------------------------------------------------------------------------

-- Module-local
convert_section :: (ConversionMonad m) => Maybe (LHsExpr RdrName) -> LHsExpr RdrName -> Maybe (LHsExpr RdrName) -> m Term
convert_section  ml opE mr = do
  let hs  = HsVar . mkGeneralLocated "generated" . mkVarUnqual . fsLit . T.unpack
      coq = Inferred Coq.Explicit . Ident
  
  arg <- gensym "arg"
  let orArg = fromMaybe (noLoc $ hs arg)
  Fun [coq arg] <$> convertExpr (OpApp (orArg ml) opE PlaceHolder (orArg mr))

--------------------------------------------------------------------------------

convertLExpr :: ConversionMonad m => LHsExpr RdrName -> m Term
convertLExpr = convertExpr . unLoc

--------------------------------------------------------------------------------

convertFunction :: ConversionMonad m => MatchGroup RdrName (LHsExpr RdrName) -> m (Binders, Term)
convertFunction mg = do
  eqns <- convertMatchGroup mg
  args <- case eqns of
            Equation (MultPattern args :| _) _ : _ ->
              traverse (const $ gensym "arg") args
            _ ->
              convUnsupported "empty `MatchGroup' in function"
  let argBinders = (Inferred Coq.Explicit . Ident) <$> args
      match      = Coq.Match (args <&> \arg -> MatchItem (Var arg) Nothing Nothing) Nothing eqns
  pure (argBinders, match)

--------------------------------------------------------------------------------

isTrueLExpr :: GhcMonad m => LHsExpr RdrName -> m Bool
isTrueLExpr (L _ (HsVar x))         = ((||) <$> (== "otherwise") <*> (== "True")) <$> ghcPpr x
isTrueLExpr (L _ (HsTick _ e))      = isTrueLExpr e
isTrueLExpr (L _ (HsBinTick _ _ e)) = isTrueLExpr e
isTrueLExpr (L _ (HsPar e))         = isTrueLExpr e
isTrueLExpr _                       = pure False

--------------------------------------------------------------------------------

-- TODO: Unify `buildTrivial` and `buildNontrivial`?
convertPatternBinding :: ConversionMonad m
                      => LPat RdrName -> LHsExpr RdrName
                      -> (Term -> (Term -> Term) -> m a)
                      -> (Term -> Ident -> (Term -> Term -> Term) -> m a)
                      -> Term
                      -> m a
convertPatternBinding hsPat hsExp buildTrivial buildNontrivial fallback = do
  (pat, guards) <- runWriterT $ convertLPat hsPat
  exp <- convertLExpr hsExp
  
  refutability pat >>= \case
    Trivial tpat | null guards ->
      buildTrivial exp $ Fun [Inferred Coq.Explicit $ maybe UnderscoreName Ident tpat]
    
    nontrivial -> do
      cont <- gensym "cont"
      arg  <- gensym "arg"
      
      -- TODO: Use SSReflect's `let:` in the `SoleConstructor` case?
      -- (Involves adding a constructor to `Term`.)
      let fallbackMatches
            | SoleConstructor <- nontrivial = []
            | otherwise                     = [ Equation [MultPattern [UnderscorePat]] fallback ]
          guarded tm | null guards = tm
                     | otherwise   = If (foldr1 (App2 $ Var "andb") guards) Nothing
                                        tm
                                        fallback
      
      buildNontrivial exp cont $ \body rest ->
        Let cont [Inferred Coq.Explicit $ Ident arg] Nothing
                 (Coq.Match [MatchItem (Var arg) Nothing Nothing] Nothing $ 
                   Equation [MultPattern [pat]] (guarded rest) : fallbackMatches)
          body

convertDoBlock :: ConversionMonad m => [ExprLStmt RdrName] -> m Term
convertDoBlock allStmts = case fmap unLoc <$> unsnoc allStmts of
  Just (stmts, BodyStmt e _ _ _) -> foldMap (Endo . toExpr . unLoc) stmts `appEndo` convertLExpr e
  Just _                         -> convUnsupported "invalid malformed `do' block"
  Nothing                        -> convUnsupported "invalid empty `do' block"
  where
    toExpr (BodyStmt e _bind _guard _PlaceHolder) rest =
      Infix <$> convertLExpr e <*> pure ">>" <*> rest
    
    toExpr (BindStmt pat exp _bind _fail PlaceHolder) rest =
      convertPatternBinding
        pat exp
        (\exp' fun          -> Infix exp' ">>=" . fun <$> rest)
        (\exp' cont letCont -> letCont (Infix exp' ">>=" (Var cont)) <$> rest)
        (Var "fail" `App1` HsString "Partial pattern match in `do' notation")
    
    toExpr (LetStmt (L _ binds)) rest =
      convertLocalBinds binds rest
    
    toExpr (RecStmt{}) _ =
      convUnsupported "`rec' statements in `do` blocks"
    
    toExpr _ _ =
      convUnsupported "impossibly fancy `do' block statements"

convertListComprehension :: ConversionMonad m => [ExprLStmt RdrName] -> m Term
convertListComprehension allStmts = case fmap unLoc <$> unsnoc allStmts of
  Just (stmts, LastStmt e _applicativeDoInfo _returnInfo) ->
    foldMap (Endo . toExpr . unLoc) stmts `appEndo`
      (Infix <$> (convertLExpr e) <*> pure "::" <*> pure (Var "nil"))
  Just _ ->
    convUnsupported "invalid malformed list comprehensions"
  Nothing ->
    convUnsupported "invalid empty list comprehension"
  where
    toExpr (BodyStmt e _bind _guard _PlaceHolder) rest =
      isTrueLExpr e >>= \case
        True  -> rest
        False -> If <$> convertLExpr e <*> pure Nothing
                    <*> rest
                    <*> pure (Var "nil")

    -- TODO: `concatMap` is really…?
    toExpr (BindStmt pat exp _bind _fail PlaceHolder) rest =
      convertPatternBinding
        pat exp
        (\exp' fun          -> App2 (Var "concatMap") <$> (fun <$> rest) <*> pure exp')
        (\exp' cont letCont -> letCont (App2 (Var "concatMap") (Var cont) exp') <$> rest)
        (Var "nil")
    
    toExpr (LetStmt (L _ binds)) rest =
      convertLocalBinds binds rest
    
    toExpr _ _ =
      convUnsupported "impossibly fancy list comprehension conditions"

--------------------------------------------------------------------------------

convertMatchGroup :: ConversionMonad m => MatchGroup RdrName (LHsExpr RdrName) -> m [Equation]
convertMatchGroup (MG (L _ alts) _ _ _) = traverse (convertMatch . unLoc) alts

convertMatch :: ConversionMonad m => Match RdrName (LHsExpr RdrName) -> m Equation
convertMatch GHC.Match{..} = do
  (pats, guards) <- runWriterT $
    maybe (convUnsupported "no-pattern case arms") pure . nonEmpty
      =<< traverse convertLPat m_pats
  oty <- traverse convertLType m_type
  rhs <- convertGRHSs (map BoolGuard guards) m_grhss placeholder
  pure . Equation [MultPattern pats] $ maybe id (flip HasType) oty rhs

convertMatch' :: ConversionMonad m
              => Match RdrName (LHsExpr RdrName)
              -> m (NonEmpty Pattern, Term -> m Term)
convertMatch' GHC.Match{..} = do
  (pats, guards) <- runWriterT $
    maybe (convUnsupported "no-pattern case arms") pure . nonEmpty
      =<< traverse convertLPat m_pats
  oty <- traverse convertLType m_type
  pure ( pats
       , fmap (maybe id (flip HasType) oty) . convertGRHSs (map BoolGuard guards) m_grhss )

convertMatchGroup' :: (ConversionMonad m)
                   => MatchGroup RdrName (LHsExpr RdrName)
                   -> m [[(NonEmpty Pattern, Term -> m Term)]]
convertMatchGroup' (MG (L _ alts) _ _ _) = do
  groupByM (compatibleSeqs `on` fst) =<< traverse (convertMatch' . unLoc) alts

buildMatch' :: ConversionMonad m
            => [(NonEmpty Pattern, Term -> m Term)]
            -> (NonEmpty Term -> m Term)
buildMatch' eqns args = foldrM build MissingValue eqns where
  build (pats,rhs) next = do
    body <- rhs next
    pure $ match args [Equation [MultPattern pats] body]

match :: NonEmpty Term -> [Equation] -> Term
match args = Coq.Match (args <&> \arg -> MatchItem arg Nothing Nothing) Nothing

{-
f x  | p  x  = y  x
f x' | p' x' = y' x'

====>

match __arg_0__ with
  | x => if p x
         then y x
         else match __arg_0__ with
               | x' => if p' x'
                       then y' x'
                       else _
              end
end
-}

--------------------------------------------------------------------------------

data ConvertedGuard m = OtherwiseGuard
                      | BoolGuard      Term
                      | PatternGuard   Pattern Term
                      | LetGuard       (m Term -> m Term)

convertGuard :: ConversionMonad m => [GuardLStmt RdrName] -> m [ConvertedGuard m]
convertGuard [] = pure []
convertGuard gs = collapseGuards <$> traverse (toCond . unLoc) gs where
  toCond (BodyStmt e _bind _guard _PlaceHolder) =
    isTrueLExpr e >>= \case
      True  -> pure [OtherwiseGuard]
      False -> (:[]) . BoolGuard <$> convertLExpr e
  toCond (LetStmt (L _ binds)) =
    pure . (:[]) . LetGuard $ convertLocalBinds binds
  toCond (BindStmt pat exp _bind _fail PlaceHolder) = do
    (pat', guards) <- runWriterT $ convertLPat pat
    exp'           <- convertLExpr exp
    pure $ PatternGuard pat' exp' : map BoolGuard guards
  toCond _ =
    convUnsupported "impossibly fancy guards"

  -- TODO: Add multi-pattern-guard case
  addGuard g [] =
    [g]
  addGuard (BoolGuard cond') (BoolGuard cond : gs) =
    BoolGuard (App2 (Var "andb") cond' cond) : gs
  addGuard g' (g:gs) =
    g':g:gs
  
  collapseGuards = foldr addGuard [] . concat

-- Returns a function waiting for the next guard
guardTerm :: ConversionMonad m => [ConvertedGuard m] -> Term -> (Term -> m Term)
guardTerm gs guarded unguarded = go gs where
  go [] =
    pure guarded
  go (OtherwiseGuard : []) =
    pure guarded
  go (OtherwiseGuard : (_:_)) =
    convUnsupported "unused guards after an `otherwise' (or similar)"
  go (BoolGuard cond : gs) =
    If cond Nothing <$> go gs <*> pure unguarded
  go (PatternGuard pat exp : gs) = do
    guarded' <- go gs
    pure $ Coq.Match [MatchItem exp Nothing Nothing] Nothing
                     [ Equation [MultPattern [pat]] guarded'
                     , Equation [MultPattern [UnderscorePat]] unguarded ]
  go (LetGuard bind : gs) =
    bind $ go gs

--------------------------------------------------------------------------------

convertGuards :: ConversionMonad m => [([ConvertedGuard m],Term)] -> (Term -> m Term)
convertGuards [] = const $ convUnsupported "empty lists of guarded statements"
convertGuards gs = foldrM (uncurry guardTerm) ?? gs
-- TODO: We could support enhanced fallthrough if we detected more
-- `MissingValue` cases, e.g.
--
--     foo (Con1 x y) | rel x y = rhs1
--     foo other                = rhs2
--
-- Right now, this doesn't catch the fallthrough.  Oh well!

convertGRHS :: ConversionMonad m
            => [ConvertedGuard m] -> GRHS RdrName (LHsExpr RdrName)
            -> m ([ConvertedGuard m],Term)
convertGRHS extraGuards (GRHS gs rhs) = (,) <$> ((extraGuards ++) <$> convertGuard gs)
                                            <*> convertLExpr rhs

convertLGRHSList :: ConversionMonad m
                 => [ConvertedGuard m] -> [LGRHS RdrName (LHsExpr RdrName)]
                 -> Term -> m Term
convertLGRHSList extraGuards lgrhses terminal =
  (convertGuards ?? terminal) =<< traverse (convertGRHS extraGuards . unLoc) lgrhses

convertGRHSs :: ConversionMonad m
             => [ConvertedGuard m] -> GRHSs RdrName (LHsExpr RdrName)
             -> Term -> m Term
convertGRHSs extraGuards GRHSs{..} = convertLocalBinds (unLoc grhssLocalBinds)
                                   . convertLGRHSList extraGuards grhssGRHSs

placeholder :: a
placeholder = error "placeholder"
{-# WARNING placeholder "placeholder" #-}

--------------------------------------------------------------------------------

convertTypedBinding :: ConversionMonad m => Maybe Term -> HsBind RdrName -> m (Maybe ConvertedBinding)
convertTypedBinding _convHsTy VarBind{}     = convUnsupported "[internal] `VarBind'"
convertTypedBinding _convHsTy AbsBinds{}    = convUnsupported "[internal?] `AbsBinds'"
convertTypedBinding _convHsTy AbsBindsSig{} = convUnsupported "[internal?] `AbsBindsSig'"
convertTypedBinding _convHsTy PatSynBind{}  = convUnsupported "pattern synonym bindings"
convertTypedBinding _convHsTy PatBind{..}   = do -- TODO use `_convHsTy`?
  -- TODO: Respect `skipped'?
  (pat, guards) <- runWriterT $ convertLPat pat_lhs
  Just . ConvertedPatternBinding pat <$> convertGRHSs (map BoolGuard guards) pat_rhs
convertTypedBinding  convHsTy FunBind{..}   = runMaybeT $ do
  (name, opName) <- freeVar (unLoc fun_id) <&> \case
                      name | identIsVariable name -> (name,            Nothing)
                           | otherwise            -> (infixToCoq name, Just name)
  guard . not =<< use (edits.skipped.contains name)
  
  let (tvs, coqTy) =
        -- The @forall@ed arguments need to be brought into scope
        let peelForall (Forall tvs body) = first (NEL.toList tvs ++) $ peelForall body
            peelForall ty                = ([], ty)
        in maybe ([], Nothing) (second Just . peelForall) convHsTy
  
  defn <-
    if all (null . m_pats . unLoc) . unLoc $ mg_alts fun_matches
    then case unLoc $ mg_alts fun_matches of
           [L _ (GHC.Match _ [] mty grhss)] ->
             maybe (pure id) (fmap (flip HasType) . convertLType) mty <*> convertGRHSs [] grhss placeholder
           _ ->
             convUnsupported "malformed multi-match variable definitions"
    else do
      (argBinders, match) <- convertFunction fun_matches
      pure $ let bodyVars = getFreeVars match
             in if name `S.member` bodyVars || maybe False (`S.member` bodyVars) opName
                then Fix . FixOne $ FixBody name argBinders Nothing Nothing match -- TODO recursion and binary operators
                else Fun argBinders match
  
  addScope <- maybe id (flip InScope) <$> use (edits.additionalScopes.at (SPValue, name))
  
  pure . ConvertedDefinitionBinding $ ConvertedDefinition name tvs coqTy (addScope defn) opName

--------------------------------------------------------------------------------

-- TODO mutual recursion :-(
convertTypedModuleBindings :: ConversionMonad m
                           => [(Maybe ModuleName, HsBind RdrName)] -> Map Ident Signature
                           -> (ConvertedBinding -> m a)
                           -> Maybe (HsBind RdrName -> GhcException -> m a)
                           -> m [a]
convertTypedModuleBindings defns sigs build mhandler =
  let processed defn = runMaybeT
                     . maybe id (ghandle . (lift .: ($ defn))) mhandler . (lift . build =<<)
                     . MaybeT
  in fmap catMaybes . for defns $ \(mname, defn) -> maybeWithCurrentModule mname $ do
       ty <- case defn of
               FunBind{fun_id = L _ hsName} ->
                 fmap sigType . (`M.lookup` sigs) <$> var ExprNS hsName
               _ ->
                 pure Nothing
       processed defn $ convertTypedBinding ty defn

convertTypedBindings :: ConversionMonad m
                     => [HsBind RdrName] -> Map Ident Signature
                     -> (ConvertedBinding -> m a)
                     -> Maybe (HsBind RdrName -> GhcException -> m a)
                     -> m [a]
convertTypedBindings = convertTypedModuleBindings . map (Nothing,)

--------------------------------------------------------------------------------

convertLocalBinds :: ConversionMonad m => HsLocalBinds RdrName -> m Term -> m Term
convertLocalBinds (HsValBinds (ValBindsIn binds lsigs)) body = localizeConversionState $ do
  sigs     <- convertLSigs lsigs
  convDefs <- convertTypedBindings (map unLoc . bagToList $ binds) sigs pure Nothing
  sequence_ $ mapMaybe (withConvertedBinding (withConvertedDefinitionOp $ rename ExprNS)
                                             (\_ _ -> Nothing))
                       convDefs
  let matchLet pat term body = Coq.Match [MatchItem term Nothing Nothing] Nothing
                                         [Equation [MultPattern [pat]] body]
  (foldr (withConvertedBinding (withConvertedDefinitionDef Let) matchLet) ?? convDefs) <$> body
convertLocalBinds (HsValBinds (ValBindsOut _ _)) _ =
  convUnsupported "post-renaming `ValBindsOut' bindings"
convertLocalBinds (HsIPBinds _) _ =
  convUnsupported "local implicit parameter bindings"
convertLocalBinds EmptyLocalBinds body =
  body
