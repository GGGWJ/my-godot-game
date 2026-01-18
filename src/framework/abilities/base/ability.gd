class_name Ability
extends Node

@export var icon_texture: Texture2D
@export var stats: AbilityStats # 新增：引用外部数据资源
@export var cooldown: float = 2

var current_cooldown: float

func activate(entity: Entity):

	# .new会自动调用_init函数
	var context	= AbilityContext.new(entity, self)

	# print("Ability %s activated!" % self.name)
	_activate_components(context)

func _activate_components(context: AbilityContext):
	for child in get_children():
		if child is AbilityComponent:
			# print("Activating component: %s" % child.name)
			child.activate(context)
		else:
			print("Child %s is not an AbilityComponent." % child.name)
