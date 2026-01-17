class_name AbilityPushBack
extends AbilityComponent

@export var push_back_distance: float = 30.0
@export var duration: float = 1.0
@export var frequency: float = 3
@export var revert: bool = false

var push_back_counter = 0
var last_activation_time = -1

func _activate(context: AbilityContext):
	if frequency != -1 and Time.get_ticks_msec() - last_activation_time > 1000:
		push_back_counter = 0

	push_back_counter += 1

	if frequency == -1 or push_back_counter >= frequency:
		push_back_counter = 0

		var caster = context.caster
		var caster_pos = caster.position
		var mouse_pos = get_window().get_camera_2d().get_global_mouse_position()

		var push_dir

		if revert:
			push_dir = (mouse_pos - caster_pos).normalized()
		else:
			push_dir = (caster_pos - mouse_pos).normalized()

		var target_pos = caster_pos + push_dir * push_back_distance

		var tween = create_tween()
		tween.tween_property(caster, "position", target_pos, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	last_activation_time = Time.get_ticks_msec()