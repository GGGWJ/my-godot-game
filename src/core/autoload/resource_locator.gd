extends Node

# 全局的资源定位器，用于获取场景中的重要节点

var _play_scene: PlayScene = null

const MANIFEST_PATH = "res://resources/system/game_manifest.tres"
var manifest: GameManifest

func _ready() -> void:
	if FileAccess.file_exists(MANIFEST_PATH):
		manifest = load(MANIFEST_PATH)
	
	_play_scene = get_tree().get_root().get_node_or_null("PlayScene") as PlayScene

func get_play_scene() -> PlayScene:
	if _play_scene == null:
		_play_scene = get_tree().get_root().get_node_or_null("PlayScene") as PlayScene
	
	return _play_scene

func go_to_play_scene() -> void:
	if manifest and manifest.play_scene:
		get_tree().change_scene_to_packed(manifest.play_scene)
	else:
		push_error("Manifest or PlayScene missed!")

func go_to_home_scene() -> void:
	if manifest and manifest.home_scene:
		get_tree().change_scene_to_packed(manifest.home_scene)
	else:
		push_error("Manifest or HomeScene missed!")
