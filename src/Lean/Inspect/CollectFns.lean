/-
Copyright (c) 2021 Microsoft Corporation. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Daniel Selsam
-/
import Lean.Inspect.Basic
import Std.Data.HashSet

namespace Lean.Inspect.CollectFns

open Lean
open Std (HashSet)

structure Context where
  env  : Environment

structure State where
  todo    : Array Name   := #[]
  visited : HashSet Name := {}

abbrev CollectFnsM := ReaderT Context (StateRefT State IO)

def pushFn (f : Name) : CollectFnsM Unit := do
  modify λ s => { s with todo := s.todo.push f }

def visitExpr (e : IR.Expr) : CollectFnsM Unit := do
  match e with
  | IR.Expr.fap f ys       => pushFn f
  | IR.Expr.pap f ys       => pushFn f
  | _                      => pure ()

partial def visitFnBody (body : IR.FnBody) : CollectFnsM Unit := do
  match body with
  | IR.FnBody.vdecl x ty e b    => visitExpr e
  | IR.FnBody.jdecl j xs v b    => visitFnBody b
  | IR.FnBody.set x i y b       => visitFnBody b
  | IR.FnBody.setTag x cidx b   => visitFnBody b
  | IR.FnBody.uset x i y b      => visitFnBody b
  | IR.FnBody.sset x i _ y ty b => visitFnBody b
  | IR.FnBody.inc x n c _ b     => visitFnBody b
  | IR.FnBody.dec x n c _ b     => visitFnBody b
  | IR.FnBody.del x b           => visitFnBody b
  | IR.FnBody.mdata d b         => visitFnBody b
  | IR.FnBody.case tid x _ cs   => pure ()
  | IR.FnBody.ret x             => pure ()
  | IR.FnBody.jmp j ys          => pure ()
  | IR.FnBody.unreachable       => pure ()

def visitFn (f : Name) : CollectFnsM Unit := do
  if (← get).visited.contains f then return ()
  match IR.findEnvDecl (← read).env f with
  | none   => throw $ IO.userError s!"[unfold] decl {f} not found"
  | some d => do
    match d with
    | IR.Decl.fdecl  _ xs type body _ => visitFnBody body
    | IR.Decl.extern f xs type ext    => pure ()
    modify λ s => { s with visited := s.visited.insert f }

partial def processTodo : CollectFnsM Unit := do
  if (← get).todo.isEmpty then return ()
  let f := (← get).todo.back
  modify λ s => { s with todo := s.todo.pop }
  visitFn f
  processTodo

def visitObject (x : Object) : CollectFnsM Unit := do
  match x with
  | Object.closure (some f) _ _ => visitFn f
  | _                           => pure ()


def collectFns (result : Result) : IO Unit := do
  (visitObject result.obj *> processTodo) { env := result.env } |>.run' {}

end CollectFns

export CollectFns (collectFns)
end Lean.Inspect
