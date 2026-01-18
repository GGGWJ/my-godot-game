class_name EnemyChaseState
extends State

var _last_path_update_time: float = 0.0
const PATH_UPDATE_INTERVAL: float = 0.2

func enter() -> void:
	if entity:
		entity.play_anim("run")
	_last_path_update_time = randf_range(0, PATH_UPDATE_INTERVAL) # 随机化初始时间，防止大量怪合同帧寻路

func physics_update(delta: float) -> void:
	var enemy = entity as Enemy
	if not enemy or enemy.is_dead or not enemy.player:
		fsm.change_state("idle")
		return

	# 1. 距离检查：如果进入攻击范围，切换到攻击状态
	var dist_sq = enemy.global_position.distance_squared_to(enemy.player.global_position)
	var stop_dist = enemy.enemy_stats.stop_distance if enemy.enemy_stats else 30.0
	
	if dist_sq <= stop_dist * stop_dist:
		fsm.change_state("attack")
		return

	# 2. 寻路/移动逻辑
	if enemy.pathfinding:
		_last_path_update_time += delta
		if _last_path_update_time >= PATH_UPDATE_INTERVAL:
			enemy.pathfinding.set_target_position(enemy.player.global_position)
			_last_path_update_time = 0.0
		
		var next_pos = enemy.pathfinding.get_next_path_position()
		var direction = (next_pos - enemy.global_position).normalized()
		enemy.pathfinding.set_velocity(direction * enemy.stats.speed)
	else:
		# 无避障寻路时的直线移动
		var direction = (enemy.player.global_position - enemy.global_position).normalized()
		if enemy.mover_component:
			enemy.mover_component.move_in_direction(direction)
