extends PanelContainer

@export var ability_button_scene: PackedScene = preload("res://scenes/ui/spell_button.tscn")
@onready var container: HBoxContainer = $MarginContainer/HBoxContainer

func _ready() -> void:
	EventBus.player_ready.connect(_on_player_ready)
	
	# 如果玩家已经存在（场景加载顺序导致信号遗漏），手动初始化一次
	var player = get_tree().get_first_node_in_group("player") as Player
	if player:
		_on_player_ready(player)

func _on_player_ready(player: Player) -> void:
	# 清理旧按钮（仅清理容器内的按钮）
	for child in container.get_children():
		child.queue_free()
	
	# 如果玩家没有技能控制器或技能，直接返回
	if not player.ability_controller or not player.ability_controller.abilities:
		return
	
	# 根据玩家技能动态创建按钮
	var index = 1
	for ability: Ability in player.ability_controller.abilities:
		var btn = ability_button_scene.instantiate()
		container.add_child(btn)
		
		# 设置技能内容
		if btn.has_method("set_ability"):
			btn.set_ability(ability)
		
		# 自动绑定数字键 1, 2, 3, 4...
		if "binded_key" in btn:
			btn.binded_key = str(index)
		
		index += 1
