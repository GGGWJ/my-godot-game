extends EntityVisual

## Player 表现中介 (Player Visual Bridge)
## 负责 Player 的动画、翻转、武器同步及特效

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var weapon: Sprite2D = $Weapon
@onready var footstep_effect: FootstepEffect = $FootstepEffect

var _weapon_right_pos: Vector2
var _weapon_left_pos: Vector2
var _footstep_timer: float = 0.0

func _setup_visual() -> void:
	if weapon:
		_weapon_right_pos = weapon.position
		_weapon_left_pos = Vector2(-weapon.position.x, weapon.position.y)
	
	# 物理复制材质，防止共享
	if sprite.material:
		sprite.material = sprite.material.duplicate()

func _process(delta: float) -> void:
	if not entity or entity.is_dead:
		return
	
	_handle_movement_visuals(delta)
	_handle_footstep_visuals(delta)

func _handle_movement_visuals(_delta: float) -> void:
	if _is_high_priority_playing:
		return
		
	var vel = entity.velocity
	
	# 1. 处理动画
	if vel.length() > 0.1:
		sprite.play("run")
	else:
		sprite.play("idle")
	
	# 2. 处理翻转
	# 优先通过当前移动速度判断
	var flip_target = entity.facing_direction.x
	if abs(vel.x) > 0.1:
		flip_target = vel.x
		
	if abs(flip_target) > 0.1:
		var side = flip_target < 0
		sprite.flip_h = side
		if weapon:
			weapon.flip_h = side
			weapon.position = _weapon_left_pos if side else _weapon_right_pos

func _play_visual_animation(anim_name: String) -> void:
	sprite.play(anim_name)

func _handle_footstep_visuals(delta: float) -> void:
	if not "is_moving" in entity: return
	
	if entity.is_moving:
		_footstep_timer += delta
		var interval = 0.3 # 默认间隔
		if "player_stats" in entity and entity.player_stats:
			interval = entity.player_stats.footstep_interval
			
		if _footstep_timer >= interval:
			if "footstep_clip" in entity:
				AudioController.play(entity.footstep_clip, global_position)
			if footstep_effect:
				footstep_effect.play()
			_footstep_timer = 0.0
	else:
		_footstep_timer = 0.0

func _on_health_changed(_current: float, _max: float) -> void:
	# 显式重写以自定义玩家受击逻辑（比如震动或特殊音效）
	super._on_health_changed(_current, _max)

# override base for specific death logic
func _on_animated_sprite_2d_animation_finished() -> void:
	super._on_animated_sprite_2d_animation_finished()
		
	if sprite.animation == "die":
		# 可以在这里做一些死亡后的视觉清理
		pass
