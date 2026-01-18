class_name Hurtbox
extends Area2D

## 受击盒组件 (Hurtbox)
## 职责：作为“身体”接收伤害，并筛选有效攻击

signal received_hit(damage_data: DamageData)

@export_enum("Player", "Enemy", "Neutral") var team: String = "Neutral"
@export var is_invincible: bool = false # 无敌状态

# 组件引用：它需要知道把血量扣给谁
var health_component: HealthComponent
var entity: Entity

func _ready() -> void:
	# 自动寻找所属实体的组件
	entity = owner as Entity
	if entity:
		health_component = entity.health_component
	
	# 设置属性
	monitoring = false # 受击盒不需要主动探测，它等着被撞
	monitorable = true

## 处理被命中的核心逻辑
func handle_hit(damage_data: DamageData) -> void:
	if is_invincible:
		return
	
	# 触发反馈信号（可以用于播特效或音效）
	received_hit.emit(damage_data)
	
	# 1. 扣除血量
	if health_component:
		health_component.apply_damage(damage_data.amount)
	
	# 2. 处理物理反馈（如击退）
	if entity and damage_data.knockback_force > 0:
		_apply_knockback(damage_data)

func _apply_knockback(damage_data: DamageData) -> void:
	# 击退逻辑通常直接影响实体的速度
	if entity:
		entity.velocity += damage_data.direction * damage_data.knockback_force
		# 注意：如果在状态机中，可能需要通知移动状态处理这种异常速度
