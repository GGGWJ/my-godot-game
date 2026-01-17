class_name Entity
extends Node2D

@export var max_health:float = 100
@export var damage_text_color:Color = Color.FIREBRICK

var is_dead:bool = false
var current_anim:AnimationWrapper
var current_health:float

@onready var animated_sprite:AnimatedSprite2D = $AnimatedSprite2D

signal player_health_changed(current_health: float, max_health: float)

func _ready() -> void:
	current_health = max_health
	# 确保每个实体实例都有自己独立的材质，避免多个实体共享同一个材质导致的问题
	animated_sprite.material = animated_sprite.material.duplicate()
	animated_sprite.animation_finished.connect(on_animation_finished)

func _exit_tree() -> void:
	# 断开信号连接，防止内存泄漏
	animated_sprite.animation_finished.disconnect(on_animation_finished)

func apply_damage(damage:float) -> void:

	if is_dead: return

	current_health -= damage
	current_health = max(0, current_health)
	_show_damage_popup(damage)
	_show_damage_taken_effect()

	# 发送玩家生命值变化信号，用来控制血条更新
	player_health_changed.emit(current_health, max_health)

	if current_health <= 0:
		is_dead = true
		play_animation(AnimationWrapper.new("die", true))

func play_animation(anim:AnimationWrapper) -> void:
	if animated_sprite.animation == anim.name: return

	# 当前动画正在播放。并且当前动画（current_anim）是高优先级且新动画（anim）不是高优先级时，忽略切换请求
	# if()里需要全部满足条件才忽略切换请求
	if(
		current_anim != null and current_anim.is_high_priority
		and not anim.is_high_priority
	):return

	current_anim = anim
	animated_sprite.play(anim.name)

func turn_to_position(pos:Vector2):
	if position.x > pos.x and not animated_sprite.flip_h:
		animated_sprite.flip_h = true
	elif position.x < pos.x and animated_sprite.flip_h:
		animated_sprite.flip_h = false
		
func on_animation_finished():
	current_anim = null

# 获取实体的高度
func get_height() -> float:
	var anim = animated_sprite.animation
	var frame_tex = animated_sprite.sprite_frames.get_frame_texture(anim, 0)
	
	# * scale.y 是为了考虑实体缩放比例对高度的影响
	return frame_tex.get_height() * scale.y

func _show_damage_popup(damage:float):
	# 获取动画第一帧的高度，用于计算文字显示位置
	var height = get_height()
	var spawn_pos = Vector2(position.x, position.y - (height / 2))
	FloatText.show_damage_text(str(damage),spawn_pos,damage_text_color)

func _show_damage_taken_effect():
	if animated_sprite.material != null:
		for i in 2:
			animated_sprite.material.set_shader_parameter("is_hurt", true)
			await get_tree().create_timer(0.05).timeout
			animated_sprite.material.set_shader_parameter("is_hurt", false)
			await get_tree().create_timer(0.05).timeout
	