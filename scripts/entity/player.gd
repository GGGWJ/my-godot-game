class_name Player
extends Entity

@export var speed:float = 500
@export var weapon:Sprite2D
@onready var ability_controller:AbilityController = $AbilityController
@onready var footstep_effect: FootstepEffect = $FootstepEffect
@export var footstep_clip:AudioConfig
@export var footstep_interval = 0.3
@export var spell_bar:SpellBar
@export var health_bar:PlayerHealthBar

var is_moving:bool = false
var weapon_right:Vector2
var weapon_left:Vector2
var turning_cooldown:float = 0.0
var spawn_location:Vector2
var footstep_timer:float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# super._ready() 核心作用是在子类中执行父类的_ready()逻辑，避免父类初始化代码被覆盖；
	# 子类重写父类函数后，父类的对应函数不会自动执行，必须手动用super.函数名()调用；
	# 调用顺序建议放在子类函数开头，保证 “基础逻辑先执行，专属逻辑后执行”。
	super._ready()

	# 将玩家实体添加到“player”组，以便敌人可以轻松找到玩家实例
	add_to_group("player")
	weapon_right = weapon.position
	weapon_left = -weapon.position
	spawn_location = position

	var abilities = ability_controller.abilities
	
	for ability_idx in range(abilities.size()):
		var ability = abilities[ability_idx]
		spell_bar.register_ability(ability, ability_idx)

	EventBus.play_cast_ability.connect(_handle_ability)

	health_bar.set_health(current_health, max_health)

	# 连接玩家生命值变化信号到血条更新函数
	player_health_changed.connect(health_bar.set_health)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_dead:return

	#移动函数
	_handle_movement(delta)
	#移动动画函数
	_handle_animation()
	# 脚步音效
	_handle_footstep_sound(delta)


func _handle_ability(ability:Ability):
	ability_controller.trigger_ability(ability)

func _handle_movement(delta: float):
	is_moving = false
	turning_cooldown = max(turning_cooldown - delta, 0)

	#处理移动逻辑
	var horizontal = Input.get_axis("left","right")
	var vertical = Input.get_axis("up","down")

	var movement = Vector2(horizontal, vertical)
	var n_movement = movement.normalized()

	self.position += n_movement * speed * delta

	if n_movement.length() > 0:
		is_moving = true
		footstep_effect.play()
		if turning_cooldown <= 0:
			if horizontal > 0:
				animated_sprite.flip_h = false
			elif horizontal < 0:
				animated_sprite.flip_h = true
	else:
		is_moving = false

func _handle_footstep_sound(delta: float):
	if is_moving:
		footstep_timer += delta
		if footstep_timer >= footstep_interval:
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
		var scene = get_parent() as PlayScene
		scene.handle_game_over(self)
