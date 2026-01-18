class_name HealthComponent
extends Node

## 负责管理实体的生命值逻辑
## 职责：数值增减、死亡判定、发射信号

signal health_changed(current: float, max_health: float)
signal damaged(amount: float)
signal healed(amount: float)
signal died

var max_health: float = 100
var current_health: float:
	set(value):
		current_health = clamp(value, 0, max_health)
	get:
		return current_health

var is_dead: bool:
	get:
		return current_health <= 0

## 初始化
func initialize(health_val: float) -> void:
	max_health = health_val
	current_health = health_val
	health_changed.emit(current_health, max_health)

## 受到伤害
func apply_damage(amount: float) -> void:
	if is_dead: return
	
	current_health -= amount
	damaged.emit(amount)
	health_changed.emit(current_health, max_health)
	
	if current_health <= 0:
		died.emit()

## 治疗
func heal(amount: float) -> void:
	if is_dead: return
	
	current_health += amount
	healed.emit(amount)
	health_changed.emit(current_health, max_health)
