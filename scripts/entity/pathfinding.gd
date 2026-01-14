class_name Pathfinding
extends Node2D

signal velocity_computed(safe_velocity: Vector2)

@export var avoidance_enabled: bool = true
@export var radius: float = 20.0 # 避障半径，根据您的怪物大小调整
@export var max_neighbors: int = 4 # 优化：降低检测邻居数量 (原6)
@export var neighbor_distance: float = 50.0 # 优化：降低检测邻居范围 (原100)

var agent: NavigationAgent2D

func _ready() -> void:
	# 动态创建 NavigationAgent2D
	agent = NavigationAgent2D.new()
	agent.avoidance_enabled = avoidance_enabled
	agent.radius = radius
	agent.neighbor_distance = neighbor_distance # 考虑多远范围内的邻居
	agent.max_neighbors = max_neighbors # 最多考虑多少个邻居
	agent.time_horizon = 0.5 # 避障预判时间

	# 关键点：这里就像是“接电话线”。
	# 意思是：当 agent 内部发出 "velocity_computed" 信号时（即它算完了），
	# 请自动执行本脚本里的 "_on_velocity_computed" 这个函数。
	agent.velocity_computed.connect(_on_velocity_computed)
	
	add_child(agent)

func set_target_position(target_pos: Vector2):
	agent.target_position = target_pos

func get_next_path_position() -> Vector2:
	# 确保在第一帧不会报错，或者如果路径未就绪直接返回当前位置
	if not agent.is_target_reachable():
		return global_position
		
	return agent.get_next_path_position()

func set_velocity(velocity: Vector2):
	if agent.avoidance_enabled:
		# 1. 提交请求：告诉 Godot "我想用这个速度走"
		agent.set_velocity(velocity)
		
		# 2. 此时函数直接结束了！_on_velocity_computed 还没有运行！
		# 3. Godot 引擎会在后台默默计算物理避障...
		# 4. 几毫秒后，Godot 算完了，它会通过上面 _ready 里的连接，自动触发 _on_velocity_computed
	else:
		# 如果没开避障，不想麻烦 Godot 算，我们自己手动调用
		# 假装算完了（结果就是原封不动的速度），为了让我们这边的信号逻辑保持统一
		_on_velocity_computed(velocity)

func _on_velocity_computed(safe_velocity: Vector2):
	# 将计算好的安全速度转发出去
	velocity_computed.emit(safe_velocity)
