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

var _last_path_update_time: float = 0.0
const PATH_UPDATE_INTERVAL: float = 0.2

func _ready() -> void:
	# super._ready() 核心作用是在子类中执行父类的_ready()逻辑，避免父类初始化代码被覆盖
	super._ready()
	
	# 优化：随机化初始更新时间，防止所有敌人在同一帧进行寻路计算（避免卡顿波峰）
	_last_path_update_time = randf_range(0, PATH_UPDATE_INTERVAL)
	
	last_position = position
	player = get_tree().get_first_node_in_group("player") as Player
	add_to_group("enemy")
	
	if pathfinding != null:
		# 连接寻路组件的信号，接收避障后的安全速度
		pathfinding.velocity_computed.connect(_on_navigation_velocity_computed)

func _physics_process(delta: float) -> void:
	if is_dead:return

	# 当播放高优先级动画（如攻击）时，停止移动逻辑
	if current_anim != null and current_anim.is_high_priority:
		if pathfinding != null:
			pathfinding.set_velocity(Vector2.ZERO)
		return

	if player != null:
		var direction = Vector2.ZERO
		var desired_velocity = Vector2.ZERO

		if pathfinding != null:
			# 1. 设置目标 (优化：限制更新频率，减少寻路计算消耗)
			_last_path_update_time += delta
			if _last_path_update_time >= PATH_UPDATE_INTERVAL:
				pathfinding.set_target_position(player.global_position)
				_last_path_update_time = 0.0
			
			# 2. 判断是否需要移动
			if position.distance_squared_to(player.position) > stop_distance * stop_distance:
				# 3. 获取下一步的路径点
				var next_path_pos = pathfinding.get_next_path_position()
				direction = (next_path_pos - global_position).normalized()
				
				# 4. 计算期望速度并提交给避障系统
				desired_velocity = direction * speed
				pathfinding.set_velocity(desired_velocity)
			else:
				# 到了攻击范围，停止并攻击
				pathfinding.set_velocity(Vector2.ZERO)
				ability_controller.trigger_ability_by_idx(0)
				_face_target((player.position - position).normalized())
		else:
			# 降级处理：如果没有 Pathfinding 组件，就直线移动（无避障）
			direction = (player.position - self.position).normalized()
			if position.distance_squared_to(player.position) > stop_distance * stop_distance:
				position += direction * speed * delta
			else:
				ability_controller.trigger_ability_by_idx(0)
			_face_target(direction)

	# 动画逻辑依赖 current_speed
	if pathfinding == null: 
		# 只有在非导航模式下才手动计算 velocity，
		# 导航模式下 velocity 在回调中赋值
		velocity = (position - last_position) / delta
	
	current_speed = velocity.length()
	last_position = position
	_handle_animation()

# 回调函数：当 NavAgent 计算好避障速度后调用
func _on_navigation_velocity_computed(safe_velocity: Vector2):
	# 这个函数会在物理帧中被调用，我们在这里真正移动实体
	if is_dead: return

	# 再次防止攻击时打滑：如果正在播放高优先级动画，强制忽略位移更新
	if current_anim != null and current_anim.is_high_priority:
		return

	# 这里假设使用的是 Node2D 的 position 移动方式
	# 注意：在 _physics_process 里调用时，不需要乘 delta，因为 set_velocity 是每帧调用的
	# 但实际上 velocity_computed 输出的是 速度 (单位/秒)，所以移动位移需要乘 delta
	
	var delta = get_physics_process_delta_time()
	position += safe_velocity * delta
	
	velocity = safe_velocity # 更新 Entity 的 velocity 属性供其他逻辑使用
	
	if safe_velocity.length_squared() > 1.0:
		_face_target(safe_velocity.normalized())

# 将 _process 改名为 _handle_animation_unused 或删除，
# 因为我们将主要逻辑移到了 _physics_process
# func _process(delta: float): 
#    ...



func _handle_animation():
	if current_speed <= 0:
		play_animation(AnimationWrapper.new("idle"))
	else:
		play_animation(AnimationWrapper.new("walk"))

func _face_target(dir:Vector2) -> void:
	# 增加阈值检测，避免在垂直移动或微小抖动时频繁翻转
	if abs(dir.x) < 0.1: return 

	if not animated_sprite.flip_h and dir.x < 0:
		animated_sprite.flip_h = true
	elif animated_sprite.flip_h and dir.x > 0:
		animated_sprite.flip_h = false

func get_height() -> float:
	if collision_shape != null:
		var shape = collision_shape.shape
		if shape is CapsuleShape2D:
			# * scale.y 是为了考虑实体缩放比例对高度的影响
			return shape.height * scale.y
		elif shape is CircleShape2D:
			return shape.radius * scale.y
		else:
			return super.get_height() * scale.y
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
