class_name  AbilityContext

# extends RefCounted 核心是自动管理自定义类的内存，没人用就自动删；
# 它像个 “智能管家”，替你搞定内存清理的脏活累活，不用手动操作；
# 适合做纯数据 / 逻辑的自定义类（非场景显示类），是 Godot 4.x 里管理内存的常用方式。
extends RefCounted

var caster: Entity
var ability: Ability

# Variant 可以存任何类型的数据，类似动态类型；
var targets:Array[Variant] = []

func _init(_caster: Entity, _ability: Ability):
	self.caster = _caster
	self.ability = _ability

func get_target_position(idx:int) -> Vector2:
	var target = targets[idx]
	if target is Entity:
		return target.global_position
	elif target is Vector2:
		return target
	else:
		return Vector2.ZERO