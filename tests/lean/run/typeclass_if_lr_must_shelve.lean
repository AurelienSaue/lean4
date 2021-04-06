class Top (α : Type) where

axiom K : Type → Type

class Field (α : Type) where

@[instance] axiom fieldNat : Field Nat

-- Dummy (bad) instance that would loop if queried on `Field ?`
@[instance] axiom badInst {α : Type} [Field (K α)] : Field α

class VectorSpace (α β : Type) [Field α] where

@[instance] axiom field2vs {α : Type} [Field α] : VectorSpace α α
@[instance] axiom vs2top {α β : Type} [Field α] [VectorSpace α β] : Top β

-- Does the right thing, since `Field ?` gets shelved.
noncomputable example : Top Nat := inferInstance
