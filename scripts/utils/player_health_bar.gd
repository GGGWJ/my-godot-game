class_name PlayerHealthBar
extends TextureProgressBar

var _max_value: float = 100

func set_health(current_health: float,max_health: float) -> void:
	print("更新血条：%f / %f" % [current_health, max_health])
	var value_proportion = _max_value / max_health
	value = clamp(current_health * value_proportion, 0, _max_value)