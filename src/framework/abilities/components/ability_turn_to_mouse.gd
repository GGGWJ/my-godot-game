class_name AbilityTurnToMouse
extends AbilityComponent

func _activate(context: AbilityContext):
	var mouse_pos = get_window().get_camera_2d().get_global_mouse_position()
	# 逻辑层不再处理具体的转向冷却和方法，由表现层监听速度方向
	# context.caster.turn_to_position(mouse_pos)
