class_name PlayerHealthBar
extends TextureProgressBar

var _max_value: float = 100

func _ready() -> void:
	# 监听全局信号，实现解耦
	EventBus.player_health_changed.connect(set_health)
	EventBus.player_ready.connect(_on_player_ready)
	
	# 如果玩家已经存在（场景加载顺序导致信号遗漏），手动初始化
	var player = get_tree().get_first_node_in_group("player") as Player
	if player:
		_on_player_ready(player)

func _on_player_ready(player: Player) -> void:
	# 初始状态同步
	if player.stats:
		set_health(player.current_health, player.stats.max_health)
	else:
		# 如果还没加载 stats，监听信号（player_stats 通常在 _ready 加载）
		# 这里可以设置一个默认值或者等待
		print("Warning: Player stats not yet loaded in health bar")

func set_health(current_health: float, max_health: float) -> void:
	# print("更新血条：%f / %f" % [current_health, max_health])
	var value_proportion = _max_value / max_health
	value = clamp(current_health * value_proportion, 0, _max_value)