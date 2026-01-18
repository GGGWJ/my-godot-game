class_name EnemyAttackState
extends State

func enter() -> void:
	var enemy = entity as Enemy
	if not enemy: return
	
	if enemy.mover_component:
		enemy.mover_component.stop()
	
	# 面向玩家
	if enemy.player:
		enemy.facing_direction = (enemy.player.global_position - enemy.global_position).normalized()
	
	# 触发攻击技能（默认 idx 0）
	if enemy.ability_controller:
		enemy.ability_controller.trigger_ability_by_idx(0)

func physics_update(_delta: float) -> void:
	var enemy = entity as Enemy
	if not enemy or enemy.is_dead: return
	
	# 如果动作结束且不在攻击冷却，可以回到追击状态
	if not enemy.is_acting:
		fsm.change_state("chase")
