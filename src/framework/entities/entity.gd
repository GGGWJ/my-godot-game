class_name Entity
extends CharacterBody2D

@export var stats: EntityStats # 数据资源

var is_dead: bool = false
var is_acting: bool = false
var current_health: float

signal health_changed(current_health: float, max_health: float)
signal died(entity: Entity)
signal animation_requested(anim_name: String, is_high_priority: bool)

func _ready() -> void:
	if stats:
		current_health = stats.max_health

func _physics_process(_delta: float) -> void:
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

	# 发送生命值变化信号，用来监听视觉反馈
	health_changed.emit(current_health, stats.max_health)

	if current_health <= 0:
		die()

func die() -> void:
	is_dead = true
	died.emit(self)
	play_anim("die", true)

func play_anim(anim_name: String, is_high_priority: bool = false) -> void:
	if is_high_priority:
		is_acting = true
	animation_requested.emit(anim_name, is_high_priority)

func on_action_finished() -> void:
	is_acting = false

func _show_damage_popup(damage: float) -> void:
	# 逻辑高度建议放入 Stats 或通过信号由表现层处理，这里暂时由逻辑层估算
	var spawn_pos = Vector2(global_position.x, global_position.y - 20)
	FloatText.show_damage_text(str(damage), spawn_pos, stats.damage_text_color)
	