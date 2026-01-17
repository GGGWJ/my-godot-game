class_name AbilityGetTargets
extends AbilityComponent

@export var radius: float = 100.0

func _activate(context: AbilityContext):
	var targets = check_colliders_around_position(context.caster, radius)
	context.targets = targets

func check_colliders_around_position(caster:Entity, p_radius: float) -> Array[Entity]:

	# 以施法者为中心，用圆形范围检测 2D 场景中的碰撞体
	var shape = CircleShape2D.new()
	shape.radius = p_radius

	# PhysicsShapeQueryParameters2D,物理检测的 “规则配置”，比如检测什么形状、检测中心在哪、是否检测 Area2D 等
	var query = PhysicsShapeQueryParameters2D.new()
	query.shape = shape
	query.transform.origin = caster.position
	query.collide_with_areas = true

	# var line = create_debug_circle(radius)
	# caster.add_child(line)

	var space_state = caster.get_world_2d().direct_space_state
	var results = space_state.intersect_shape(query)
	var targets: Array[Entity] = []

	if results.size() > 0:
		for result in results:
			var collider = result.collider
			var parent = collider.get_parent()

			# 核心修复：添加 parent != caster 判断，防止技能伤害到施法者自己
			if parent is Entity and parent != caster:
				targets.push_back(parent)

	# call_deferred("destroy_line", line, 0.2)
	return targets

func create_debug_circle(p_radius: float):
		var points = 32
		var line = Line2D.new()
		line.width = 2
		line.default_color = Color.RED

		for i in range(points + 1):
			var angle = (TAU / points) * i
			line.add_point(Vector2(cos(angle), sin(angle)) * p_radius)

		return line

func destroy_line(line:Line2D,seconds:float):
		await get_tree().create_timer(seconds).timeout

		if line != null:
			line.queue_free()
