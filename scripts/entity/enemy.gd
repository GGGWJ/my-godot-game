class_name Enemy
extends Entity

@export var speed:float = 20
@export var stop_distance:float = 10

@onready var ability_controller:AbilityController = $AbilityController
@onready var collision_shape:CollisionShape2D = $Area2D/CollisionShape2D
@onready var hit_particles:CPUParticles2D = $HitParticles
@onready var pathfinding:Pathfinding = $Pathfinding

var player:Player
var velocity:Vector2
var current_speed:float
var last_position:Vector2

func _ready() -> void:
	# super._ready() 核心作用是在子类中执行父类的_ready()逻辑，避免父类初始化代码被覆盖；
	# 子类重写父类函数后，父类的对应函数不会自动执行，必须手动用super.函数名()调用；
	# 调用顺序建议放在子类函数开头，保证 “基础逻辑先执行，专属逻辑后执行”。
	super._ready()
	last_position = position
	player = get_tree().get_first_node_in_group("player") as Player

func _process(delta: float):

	if is_dead:return

	if player != null:
		var direction

		if pathfinding !=null:
			direction = pathfinding.find_path(player.global_position)
			if direction == null:
				# 如果寻路未找到路径，回退到直线朝向玩家，避免 Nil * float 报错
				direction = (player.position - self.position).normalized()
		else:
			direction = (player.position - self.position).normalized()

		if position.distance_to(player.position) > stop_distance:
			position += direction * speed * delta
		else:
			ability_controller.trigger_ability_by_idx(0)

		velocity = (position - last_position) / delta
		current_speed = velocity.length()
		_face_target(direction)
	
	last_position = position
	_handle_animation()


func _handle_animation():
	if current_speed <= 0:
		play_animation(AnimationWrapper.new("idle"))
	else:
		play_animation(AnimationWrapper.new("walk"))

func _face_target(dir:Vector2) -> void:
	if not animated_sprite.flip_h and dir.x < 0:
		animated_sprite.flip_h = true
	elif animated_sprite.flip_h and dir.x > 0:
		animated_sprite.flip_h = false

func get_height() -> float:
	if collision_shape != null:
		var shape = collision_shape.shape as CapsuleShape2D

		# * scale.y 是为了考虑实体缩放比例对高度的影响
		return shape.height * scale.y
	else:
		return super.get_height() * scale.y

func _show_damage_taken_effect():
	super._show_damage_taken_effect()

	if hit_particles != null:
		hit_particles.emitting = false
		hit_particles.emitting = true

func _on_animated_sprite_2d_animation_finished() -> void:
	if current_anim != null and current_anim.name == "die":
		queue_free()
