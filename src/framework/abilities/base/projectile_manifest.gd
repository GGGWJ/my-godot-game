class_name ProjectileManifest
extends AbilityManifest

@export var damage = 10.0
@export var speed: float = 20.0
@export var target_group: String
@export var max_distance: float = 1000.0
@export var rotating: bool = false
@export var rotation_speed: float = 180.0 # 每秒旋转角度，单位度
@export var hit_sound: AudioConfig

var current_dir: Vector2 = Vector2.ZERO
var current_distance: float = 0.0

signal projectile_hit(target: Entity)
signal projectile_fired()

func activate(context: AbilityContext):
	projectile_fired.emit()
	if context.targets.size()>0:
		var target_pos = context.get_target_position(0)
		current_dir = (target_pos - global_position).normalized()
		look_at(target_pos)

func _process(delta: float) -> void:
		var movement = current_dir * speed * delta
		current_distance += movement.length()
		global_position += movement

		if rotating:
			rotate(deg_to_rad(rotation_speed * delta))

		if current_distance >= max_distance:
			queue_free()


func _on_area_2d_area_entered(area: Area2D) -> void:
	var parent = area.get_parent()

	if parent != null and parent.is_in_group(target_group):
		if parent is Entity:
			_handle_impact(parent)

func _handle_impact(target: Entity) -> void:
	# 逻辑：施加伤害
	target.apply_damage(damage)
	
	# 表现：发射信号（可用于触发爆炸特效、打击音效等）
	projectile_hit.emit(target)
	
	# 如果有简单音效配置，直接播放（或由表现层监听信号播放）
	if hit_sound != null:
		AudioController.play(hit_sound, global_position)
	
	# 销毁
	queue_free()
