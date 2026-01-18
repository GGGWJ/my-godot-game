class_name PlayerIdleState
extends State

func enter() -> void:
	if entity:
		entity.play_anim("idle")
		if entity.mover_component:
			entity.mover_component.stop()

func physics_update(_delta: float) -> void:
	var horizontal = Input.get_axis("left", "right")
	var vertical = Input.get_axis("up", "down")
	
	if horizontal != 0 or vertical != 0:
		fsm.change_state("move")
