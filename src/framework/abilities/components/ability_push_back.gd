class_name AbilityPushBack
extends AbilityComponent

@export var push_back_distance: float = 0.0 # 设置为 0 则从 AbilityStats 读取
@export var duration: float = 0.0 # 设置为 0 则从 AbilityStats 读取
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

		var final_distance = push_back_distance
		var final_duration = duration
		
		if context.ability.stats:
			if final_distance <= 0:
				final_distance = context.ability.stats.parameters.get("push_back_distance", 30.0)
			if final_duration <= 0:
				final_duration = context.ability.stats.parameters.get("push_back_duration", 0.1)

		var target_pos = caster_pos + push_dir * final_distance

		var tween = create_tween()
		tween.tween_property(caster, "position", target_pos, final_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	last_activation_time = Time.get_ticks_msec()