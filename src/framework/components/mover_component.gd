class_name MoverComponent
extends Node

## 负责管理实体的位移物理逻辑
## 职责：处理速度计算、摩擦力、平滑移动控制

@onready var entity: Entity = get_parent() as Entity

@export var acceleration: float = 2000.0  # 加速度
@export var friction: float = 1200.0      # 摩擦力
@export var use_smoothing: bool = true    # 是否开启平滑移动（惯性）

var input_direction: Vector2 = Vector2.ZERO
var max_speed: float = 200.0

func _ready() -> void:
	if not entity:
		push_error("MoverComponent 必须作为 Entity 的子节点！")
		return
	
	if entity.stats:
		max_speed = entity.stats.speed

## 外部指令：移动到特定方向
func move_in_direction(direction: Vector2) -> void:
	input_direction = direction.normalized()
	if input_direction.length() > 0.1:
		entity.facing_direction = input_direction

## 外部指令：以特定速度移动（通常用于导航避障的结果）
func apply_velocity(velocity: Vector2) -> void:
	if velocity.length() > 0.1:
		entity.facing_direction = velocity.normalized()
	entity.velocity = velocity

## 外部指令：立即停止
func stop() -> void:
	input_direction = Vector2.ZERO

func _physics_process(delta: float) -> void:
	if not entity or entity.is_dead:
		return
	
	if entity.is_acting:
		# 处理攻击等动作时的位移锁定（可以在这里实现微量位移或完全静止）
		entity.velocity = entity.velocity.move_toward(Vector2.ZERO, friction * delta)
		return

	var target_velocity = input_direction * max_speed
	
	if use_smoothing:
		if input_direction.length() > 0:
			# 加速阶段
			entity.velocity = entity.velocity.move_toward(target_velocity, acceleration * delta)
		else:
			# 减速阶段（摩擦力）
			entity.velocity = entity.velocity.move_toward(Vector2.ZERO, friction * delta)
	else:
		# 线性直接移动（无惯性）
		entity.velocity = target_velocity
