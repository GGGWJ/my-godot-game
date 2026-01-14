class_name PlayScene
extends Node

@export var screen_transition:ColorRect

func handle_game_over(player:Player):
	var tween = fade_in_overlay()
	await tween.finished
	player.position = player.spawn_location

	tween = fade_out_overlay()
	await tween.finished

	player.is_dead = false
	player.current_health = player.max_health

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