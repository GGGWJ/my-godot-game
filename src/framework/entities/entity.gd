class_name Entity
extends CharacterBody2D

@export var stats: EntityStats # 数据资源

var is_dead: bool = false
var is_acting: bool = false
var facing_direction: Vector2 = Vector2.RIGHT # 逻辑上的朝向

# 组件引用
var health_component: HealthComponent
var mover_component: MoverComponent
var fsm: FiniteStateMachine

# 向后兼容的存取器
var current_health: float:
	get: return health_component.current_health if health_component else 0.0
	set(value):
		if health_component:
			health_component.current_health = value

signal health_changed(current_health: float, max_health: float)
signal damaged(amount: float) # 传递受到的伤害数值
signal died(entity: Entity)
signal animation_requested(anim_name: String, is_high_priority: bool)

func _ready() -> void:
	_setup_health_component()
	_setup_mover_component()
	_setup_fsm()
	
	if stats and health_component:
		health_component.initialize(stats.max_health)

func _setup_health_component() -> void:
	# 优先寻找预定义的子节点，没有则动态创建一个
	health_component = get_node_or_null("HealthComponent")
	if not health_component:
		health_component = HealthComponent.new()
		health_component.name = "HealthComponent"
		add_child(health_component)
	
	# 连接组件信号到实体的转发信号（维持中介身份）
	health_component.health_changed.connect(func(c, m): health_changed.emit(c, m))
	health_component.damaged.connect(func(a): damaged.emit(a))
	health_component.died.connect(die)

func _setup_mover_component() -> void:
	mover_component = get_node_or_null("MoverComponent")
	# 注意：移动组件通常需要在场景编辑器中配置参数（如加速度），
	# 所以这里不自动创建，而是如果不存在就打印提示，或者使用默认参数创建
	if not mover_component:
		mover_component = MoverComponent.new()
		mover_component.name = "MoverComponent"
		add_child(mover_component)

func _setup_fsm() -> void:
	fsm = get_node_or_null("FSM")

func _physics_process(_delta: float) -> void:
	if is_dead: 
		return
	
	# 统一执行移动滑动逻辑
	move_and_slide()

func apply_damage(damage: float) -> void:
	if is_dead or not health_component: 
		return

	health_component.apply_damage(damage)

func heal(amount: float) -> void:
	if is_dead or not health_component:
		return
	health_component.heal(amount)

func die(entity_ref: Entity = self) -> void:
	# 已经在 health_component 中判定过了，这里执行实体的清理/表现逻辑
	if is_dead and entity_ref == self: return 
	
	is_dead = true
	died.emit(self)
	play_anim("die", true)

func play_anim(anim_name: String, is_high_priority: bool = false) -> void:
	if is_high_priority:
		is_acting = true
	animation_requested.emit(anim_name, is_high_priority)

func on_action_finished() -> void:
	is_acting = false

func get_visual() -> EntityVisual:
	return get_node_or_null("Visual") as EntityVisual
	