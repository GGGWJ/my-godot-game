extends Node

# 全局的资源定位器，用于获取场景中的重要节点

var _play_scene: PlayScene = null

func _ready() -> void:
	_play_scene = get_tree().get_root().get_node("PlayScene") as PlayScene

func get_play_scene() -> PlayScene:
	if _play_scene == null:
		_play_scene = get_tree().get_root().get_node("PlayScene") as PlayScene
	
	return _play_scene