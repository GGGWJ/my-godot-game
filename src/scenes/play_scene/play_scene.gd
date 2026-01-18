class_name PlayScene
extends Node

@export var screen_transition:ColorRect

var fps_label: Label

func _ready() -> void:
	# 限制游戏最大帧率为 60，保证流畅度并节省性能
	Engine.max_fps = 60

	# 连接玩家死亡信号
	var player = get_node_or_null("player")
	if player:
		player.died.connect(handle_game_over)
	
	# 动态创建一个 Label 来显示帧率
	fps_label = Label.new()
	fps_label.set_anchors_preset(Control.PRESET_TOP_LEFT)
	fps_label.offset_left = 10
	fps_label.offset_top = 10
	fps_label.add_theme_color_override("font_color", Color.YELLOW)
	fps_label.add_theme_font_size_override("font_size", 24)
	
	# 获取或创建一个 CanvasLayer (确保 UI 始终在最上层)
	var canvas_layer = get_node_or_null("CanvasLayer")
	if canvas_layer == null:
		canvas_layer = CanvasLayer.new()
		add_child(canvas_layer)
		
	canvas_layer.add_child(fps_label)

func _process(_delta: float) -> void:
	if fps_label != null:
		fps_label.text = "FPS: %d" % Engine.get_frames_per_second()

func handle_game_over(player:Player):
	var tween = fade_in_overlay()
	await tween.finished
	player.position = player.spawn_location

	tween = fade_out_overlay()
	await tween.finished

	player.is_dead = false
	player.current_health = player.stats.max_health
	player.health_changed.emit(player.current_health, player.stats.max_health)

func fade_out_overlay():
	var tween = create_tween()

	tween.tween_property(
		screen_transition,
		 "color:a",
		  0.0,
		  1.0
	).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
	return tween

func fade_in_overlay():
	var tween = create_tween()

	tween.tween_property(
		screen_transition,
		 "color:a",
		  1.0,
		  1.0
	).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
	return tween

func _on_pause_btn_pressed() -> void:
	get_tree().paused = true
