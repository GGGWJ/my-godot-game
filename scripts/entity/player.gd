class_name Player
extends Entity

@export var weapon: Sprite2D
@onready var ability_controller: AbilityController = $AbilityController
@onready var footstep_effect: FootstepEffect = $FootstepEffect
@export var footstep_clip: AudioConfig
@export var spell_bar: SpellBar
@export var health_bar: PlayerHealthBar

var player_stats: PlayerStats:
	get: return stats as PlayerStats

var is_moving: bool = false
var weapon_right: Vector2
var weapon_left: Vector2
var spawn_location: Vector2
var footstep_timer: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()

	# 将玩家实体添加到“player”组，以便敌人可以轻松找到玩家实例
	add_to_group("player")
	weapon_right = weapon.position
	weapon_left = Vector2(-weapon.position.x, weapon.position.y)
	spawn_location = position

	var abilities = ability_controller.abilities
	
	for ability_idx in range(abilities.size()):
		var ability = abilities[ability_idx]
		spell_bar.register_ability(ability, ability_idx)

	EventBus.play_cast_ability.connect(_handle_ability)

	health_bar.set_health(current_health, stats.max_health)

	# 连接玩家生命值变化信号到血条更新函数
	health_changed.connect(health_bar.set_health)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_dead: return

	# 处理输入并计算速度
	_handle_input()
	# 移动动画函数
	_handle_animation()
	# 脚步音效
	_handle_footstep_sound(delta)

func _handle_input() -> void:
	# 处理移动逻辑
	var horizontal = Input.get_axis("left", "right")
	var vertical = Input.get_axis("up", "down")

	var movement = Vector2(horizontal, vertical)
	var n_movement = movement.normalized()

	# 更新速度，物理移动在基类 move_and_slide() 中完成
	if stats:
		velocity = n_movement * stats.speed
	else:
		velocity = Vector2.ZERO

	if n_movement.length() > 0:
		is_moving = true
		footstep_effect.play()
		_update_direction(n_movement)
	else:
		is_moving = false

func _update_direction(dir: Vector2) -> void:
	# 调用基类处理基础翻转（含 turning_cooldown 检查）
	var old_flip = animated_sprite.flip_h
	super._update_direction(dir)
	
	# 如果翻转状态发生了变化，同步更新武器
	if weapon and animated_sprite.flip_h != old_flip:
		weapon.flip_h = animated_sprite.flip_h
		weapon.position = weapon_left if animated_sprite.flip_h else weapon_right

func _handle_ability(ability: Ability) -> void:
	ability_controller.trigger_ability(ability)

func _handle_footstep_sound(delta: float) -> void:
	if is_moving:
		footstep_timer += delta
		if player_stats and footstep_timer >= player_stats.footstep_interval:
			AudioController.play(footstep_clip, global_position)
			footstep_timer = 0.0
	else:
		footstep_timer = 0.0


func _handle_animation():
	if is_moving:
		play_animation(AnimationWrapper.new("run"))
	else:
		play_animation(AnimationWrapper.new("idle"))

func _on_animated_sprite_2d_animation_finished() -> void:
	if current_anim != null and current_anim.name == "die":
		died.emit(self)
