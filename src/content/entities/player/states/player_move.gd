class_name PlayerMoveState
extends State

func enter() -> void:
	if entity:
		entity.play_anim("run")

func physics_update(_delta: float) -> void:
	var horizontal = Input.get_axis("left", "right")
	var vertical = Input.get_axis("up", "down")
	var direction = Vector2(horizontal, vertical).normalized()
	
	if direction.length() < 0.1:
		fsm.change_state("idle")
		return
	
	if entity and entity.mover_component:
		entity.mover_component.move_in_direction(direction)
		# 同步移动状态给 Entity 变量（虽然现在主要靠状态机判断，但保留变量以便兼容）
		entity.is_moving = true

func exit() -> void:
	if entity:
		entity.is_moving = false
