class_name AbilityDealDamage
extends AbilityComponent

@export var damage: float = 10.0 # 默认伤害 10

func _activate(context: AbilityContext):
	var targets = context.targets
	
	# 优先从 Ability 的 stats 资源读取 damage 参数
	var final_damage = damage
	if context.ability.stats:
		final_damage = context.ability.stats.parameters.get("damage", damage)

	# print("[AbilityDealDamage 调试] 激活伤害: ", final_damage, " 目标数量: ", targets.size())

	for target in targets:
		if target != null:
			if target is Entity:
				print("[AbilityDealDamage 调试] 对实体应用伤害: ", target.name)
				target.apply_damage(final_damage)

				for child in get_children():
					if child is AbilityComponent:
						child.activate(context)