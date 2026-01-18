# 需要保证获得目标在其他需要用到目标的组件之前

class_name AbilityTargetPlayer
extends AbilityComponent

func _activate(context: AbilityContext):
	var player = get_tree().get_first_node_in_group("player")
	context.targets = [player]