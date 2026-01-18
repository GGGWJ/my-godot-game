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
	set_health(player.current_health, player.stats.max_health)

func set_health(current_health: float, max_health: float) -> void:
	print("更新血条：%f / %f" % [current_health, max_health])
	var value_proportion = _max_value / max_health
	value = clamp(current_health * value_proportion, 0, _max_value)