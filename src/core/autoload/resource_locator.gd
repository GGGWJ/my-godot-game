extends Node

# 全局的资源定位器，用于获取场景中的重要节点

var _play_scene: PlayScene = null

var packed_play_scene: PackedScene = preload("res://src/scenes/play_scene/play_scene.tscn")
var packed_home_scene: PackedScene = preload("res://src/scenes/home_scene/home_scene.tscn")



func _ready() -> void:
	_play_scene = get_tree().get_root().get_node("PlayScene") as PlayScene

func get_play_scene() -> PlayScene:
	if _play_scene == null:
		_play_scene = get_tree().get_root().get_node("PlayScene") as PlayScene
	
	return _play_scene

func go_to_play_scene() -> void:
	get_tree().change_scene_to_packed(packed_play_scene)

func go_to_home_scene() -> void:
	get_tree().change_scene_to_packed(packed_home_scene)
