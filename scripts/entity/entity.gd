class_name Entity
extends CharacterBody2D

@export var stats: EntityStats # 数据资源

var is_dead: bool = false
var current_anim: AnimationWrapper
var current_health: float
var turning_cooldown: float = 0.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

signal health_changed(current_health: float, max_health: float)
signal died(entity: Entity)

func _ready() -> void:
	if stats:
		current_health = stats.max_health
	
	# 确保每个实体实例都有自己独立的材质，避免多个实体共享同一个材质导致的问题
	if animated_sprite.material:
		animated_sprite.material = animated_sprite.material.duplicate()
	
	animated_sprite.animation_finished.connect(on_animation_finished)

func _exit_tree() -> void:
	# 断开信号连接，防止内存泄漏
	if animated_sprite.animation_finished.is_connected(on_animation_finished):
		animated_sprite.animation_finished.disconnect(on_animation_finished)

func _physics_process(delta: float) -> void:
	if turning_cooldown > 0:
		turning_cooldown -= delta
		
	if is_dead: 
		return
	
	# 统一执行移动滑动逻辑
	move_and_slide()

func apply_damage(damage: float) -> void:
	if is_dead: 
		return

	current_health -= damage
	current_health = max(0, current_health)
	_show_damage_popup(damage)
	_show_damage_taken_effect()

	# 发送生命值变化信号，用来控制血条更新
	health_changed.emit(current_health, stats.max_health)

	if current_health <= 0:
		die()

func die() -> void:
	is_dead = true
	play_animation(AnimationWrapper.new("die", true))

func play_animation(anim: AnimationWrapper) -> void:
	if animated_sprite.animation == anim.name: return

	# 当前动画正在播放。并且当前动画（current_anim）是高优先级且新动画（anim）不是高优先级时，忽略切换请求
	# if()里需要全部满足条件才忽略切换请求
	if(
		current_anim != null and current_anim.is_high_priority
		and not anim.is_high_priority
	):return

	current_anim = anim
	animated_sprite.play(anim.name)

func turn_to_position(pos: Vector2):
	# 面向某个位置（通常用于技能释放）
	var dir = (pos - global_position).normalized()
	_update_direction(dir)

func _update_direction(dir: Vector2):
	if turning_cooldown > 0: return
	if abs(dir.x) < 0.1: return
	animated_sprite.flip_h = dir.x < 0

func on_animation_finished():
	current_anim = null

# 获取实体的高度
func get_height() -> float:
	var anim = animated_sprite.animation
	var frame_tex = animated_sprite.sprite_frames.get_frame_texture(anim, 0)
	
	# * scale.y 是为了考虑实体缩放比例对高度的影响
	return frame_tex.get_height() * scale.y

func _show_damage_popup(damage: float) -> void:
	# 获取动画第一帧的高度，用于计算文字显示位置
	var height = get_height()
	var spawn_pos = Vector2(global_position.x, global_position.y - (height / 2))
	FloatText.show_damage_text(str(damage), spawn_pos, stats.damage_text_color)

func _show_damage_taken_effect():
	if animated_sprite.material != null:
		for i in 2:
			animated_sprite.material.set_shader_parameter("is_hurt", true)
			await get_tree().create_timer(0.05,false).timeout
			animated_sprite.material.set_shader_parameter("is_hurt", false)
			await get_tree().create_timer(0.05,false).timeout
	