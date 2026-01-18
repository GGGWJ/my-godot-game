class_name Enemy
extends Entity

@onready var ability_controller: AbilityController = $AbilityController
@onready var pathfinding: Pathfinding = $Pathfinding

var enemy_stats: EnemyStats:
	get: return stats as EnemyStats

var player: Player
var last_position: Vector2

var _last_path_update_time: float = 0.0
const PATH_UPDATE_INTERVAL: float = 0.2

func _ready() -> void:
	super._ready()
	
	_last_path_update_time = randf_range(0, PATH_UPDATE_INTERVAL)
	last_position = position
	player = get_tree().get_first_node_in_group("player") as Player
	add_to_group("enemy")
	
	if pathfinding != null:
		pathfinding.velocity_computed.connect(_on_navigation_velocity_computed)

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	if is_dead: return

	# 动作锁定检查
	if is_acting:
		velocity = Vector2.ZERO
		return

	if player != null:
		var direction = Vector2.ZERO

		if pathfinding != null:
			_last_path_update_time += delta
			if _last_path_update_time >= PATH_UPDATE_INTERVAL:
				pathfinding.set_target_position(player.global_position)
				_last_path_update_time = 0.0

			var stop_dist = enemy_stats.stop_distance if enemy_stats else 10.0
			if position.distance_squared_to(player.global_position) > stop_dist * stop_dist:
				var next_path_pos = pathfinding.get_next_path_position()
				direction = (next_path_pos - global_position).normalized()
				pathfinding.set_velocity(direction * stats.speed)
				facing_direction = direction
			else:
				velocity = Vector2.ZERO
				facing_direction = (player.global_position - global_position).normalized()
				ability_controller.trigger_ability_by_idx(0)
		else:
			direction = (player.global_position - global_position).normalized()
			var stop_dist = enemy_stats.stop_distance if enemy_stats else 10.0
			if position.distance_squared_to(player.global_position) > stop_dist * stop_dist:
				velocity = direction * stats.speed
				facing_direction = direction
			else:
				velocity = Vector2.ZERO
				facing_direction = direction
				ability_controller.trigger_ability_by_idx(0)

func _on_navigation_velocity_computed(safe_velocity: Vector2) -> void:
	if is_dead or is_acting:
		velocity = Vector2.ZERO
		return
	velocity = safe_velocity
