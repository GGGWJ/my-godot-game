class_name AbilityDealDamage
extends AbilityComponent

@export var damage: float = 10

func _activate(context: AbilityContext):
	var targets = context.targets

	for target in targets:
		if target != null:
			if target is Entity:
				target.apply_damage(damage)

				for child in get_children():
					if child is AbilityComponent:
						child.activate(context)