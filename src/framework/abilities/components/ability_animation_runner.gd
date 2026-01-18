class_name AbilityAnimationRunner
extends AbilityComponent

@export var animation_name: String

func _activate(context: AbilityContext):
	context.caster.play_anim(animation_name, true)
