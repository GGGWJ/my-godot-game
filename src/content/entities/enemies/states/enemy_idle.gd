class_name EnemyIdleState
extends State

func enter() -> void:
	if entity:
		entity.play_anim("idle")
		if entity.mover_component:
			entity.mover_component.stop()

func physics_update(_delta: float) -> void:
	var enemy = entity as Enemy
	if enemy and enemy.player and not enemy.is_dead:
		fsm.change_state("chase")
