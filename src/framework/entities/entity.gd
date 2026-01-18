class_name Entity
extends CharacterBody2D

@export var stats: EntityStats # 数据资源

var is_dead: bool = false
var is_acting: bool = false
var current_health: float

signal health_changed(current_health: float, max_health: float)
signal damaged(amount: float) # 传递受到的伤害数值
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
	
	# 发送信号，由表现层决定如何展示（飘字、震屏等）
	damaged.emit(damage)
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

func get_visual() -> EntityVisual:
	return get_node_or_null("Visual") as EntityVisual
	