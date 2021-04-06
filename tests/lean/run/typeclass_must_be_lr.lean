class HasMulComm (α : Type u) [Mul α] : Prop where
    mulComm : {a b : α} → a * b = b * a

class A (α : Type u) extends Mul α
attribute [instance] A.mk

class B (α : Type u) extends A α, HasMulComm α
attribute [instance] B.mk

-- Still succeeds, since it is L->R and the `A α` subgoal has no metas in the type and so is not shelved
example [Mul α] [HasMulComm α] : B α := inferInstance
