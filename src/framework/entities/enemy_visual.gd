extends EntityVisual

## 敌人表现中介 (Enemy Visual Bridge)

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _process(_delta: float) -> void:
	if not entity or entity.is_dead:
		return
	
	_handle_movement_visuals()

func _handle_movement_visuals() -> void:
	if _is_high_priority_playing:
		return
		
	if entity.velocity.length() > 0.1:
		sprite.play("walk") 
	else:
		sprite.play("idle")
	
	var flip_target = entity.facing_direction.x
	if abs(entity.velocity.x) > 0.1:
		flip_target = entity.velocity.x

	if abs(flip_target) > 0.1:
		sprite.flip_h = flip_target < 0

func _play_visual_animation(anim_name: String) -> void:
	sprite.play(anim_name)
