class_name State
extends Node

## 状态基类
## 所有具体状态（如 Idle, Move, Attack）都应继承自此类

# 状态持有 FSM 引用
var fsm: FiniteStateMachine
# 状态持有 Entity 引用
var entity: Entity

func enter() -> void:
	pass

func exit() -> void:
	pass

func handle_input(_event: InputEvent) -> void:
	pass

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	pass
