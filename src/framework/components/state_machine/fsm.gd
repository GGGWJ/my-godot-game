class_name FiniteStateMachine
extends Node

## 有限状态机控制器
## 职责：管理状态切换、分发物理与逻辑更新

@export var initial_state: State

var current_state: State
var states: Dictionary = {}

@onready var entity: Entity = get_parent() as Entity

func _ready() -> void:
	# 等待一帧确保所有子节点（状态）都已就绪
	await get_tree().process_frame
	
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.fsm = self
			child.entity = entity
	
	if initial_state:
		change_state(initial_state.name)

func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)

func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)

func _unhandled_input(event: InputEvent) -> void:
	if current_state:
		current_state.handle_input(event)

func change_state(state_name: String) -> void:
	var new_state = states.get(state_name.to_lower())
	if not new_state:
		push_warning("状态不存在: " + state_name)
		return
	
	if current_state:
		current_state.exit()
	
	current_state = new_state
	current_state.enter()
	# print("[FSM] 状态切换至: ", state_name)
