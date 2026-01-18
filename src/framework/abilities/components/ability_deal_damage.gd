class_name AbilityDealDamage
extends AbilityComponent

@export var damage: float = 0 # 0 表示尝试从 Stats 资源读取

func _activate(context: AbilityContext):
	var targets = context.targets
	
	# 优先从 Ability 的 stats 资源读取 damage 参数
	var final_damage = damage
	if final_damage <= 0 and context.ability.stats:
		final_damage = context.ability.stats.parameters.get("damage", 10.0)

	for target in targets:
		if target != null:
			if target is Entity:
				target.apply_damage(final_damage)

				for child in get_children():
					if child is AbilityComponent:
						child.activate(context)