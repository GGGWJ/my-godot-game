class_name Player
extends Entity

@onready var ability_controller: AbilityController = $AbilityController
@export var footstep_clip: AudioConfig

var player_stats: PlayerStats:
	get: return stats as PlayerStats

var is_moving: bool = false
var spawn_location: Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()

	# 将玩家实体添加到“player”组，以便敌人可以轻松找到玩家实例
	add_to_group("player")
	spawn_location = position

	EventBus.play_cast_ability.connect(_handle_ability)
	
	# 连接生命值变化到全局信号
	health_changed.connect(func(curr, m): EventBus.player_health_changed.emit(curr, m))
	
	# 通知 UI 玩家已就绪
	EventBus.player_ready.emit(self)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if is_dead: return

	# 如果有状态机，逻辑由状态机接管
	if fsm: return

	# 处理输入并计算速度 (Legacy 模式)
	_handle_input()

func _handle_input() -> void:
	# 处理移动逻辑
	var horizontal = Input.get_axis("left", "right")
	var vertical = Input.get_axis("up", "down")
	
	var movement = Vector2(horizontal, vertical)
	var n_movement = movement.normalized()

	# 现在的逻辑：不再自己算 velocity，而是传给 MoverComponent
	if mover_component:
		mover_component.move_in_direction(n_movement)

	is_moving = n_movement.length() > 0

func _handle_ability(ability: Ability) -> void:
	ability_controller.trigger_ability(ability)
