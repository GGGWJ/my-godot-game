class_name AbilityComponentGroup
extends AbilityComponent

var sub_components: Array[AbilityComponent] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child in get_children():
		if child is AbilityComponent:
			sub_components.push_back(child)

func _activate(context: AbilityContext):
	for component in sub_components:
		component.activate(context)