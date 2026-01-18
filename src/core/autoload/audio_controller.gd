extends Node

var buffer_size = 5
var available_players: Array[AudioStreamPlayer2D] = []

func _ready() -> void:
	_set_audio_players()

func _set_audio_players() -> void:
	for i in range(buffer_size):
		var audio_player = AudioStreamPlayer2D.new()
		available_players.push_back(audio_player)
		add_child(audio_player)

func _get_avaiable_player():
	# Godot 引擎 GDScript 中「数组的 find_custom 方法」，作用是按 “自定义条件” 在数组里查找元素
	# 返回第一个满足条件的元素的索引，如果没有找到则返回 -1。这里的条件是找到没有播放的播放器，not player.playing
	var player_idx = available_players.find_custom(func(player: AudioStreamPlayer2D):
		return not player.playing
	)

	if player_idx > -1:
		return available_players[player_idx]
	else:
		return null

func play(clip_config: AudioConfig,global_position = Vector2.INF):
	if clip_config == null: return
	var audio_streams = clip_config.audio_streams
	if audio_streams.is_empty(): return

	var audio_player = _get_avaiable_player()

	if audio_player == null:
		# 如果所有的音频播放器都被占用了，则再创建新的音频播放器
		_set_audio_players()
		audio_player = _get_avaiable_player()

	var random_idx = randi() % clip_config.audio_streams.size()

	audio_player.stop()

	if global_position != Vector2.INF:
		audio_player.global_position = global_position

	audio_player.stream = clip_config.audio_streams[random_idx]
	audio_player.volume_db = clip_config.volume_db
	audio_player.max_distance = clip_config.max_distance
	audio_player.pitch_scale = clip_config.pitch_scale
	audio_player.bus = clip_config.bus
	audio_player.play()

	return audio_player
