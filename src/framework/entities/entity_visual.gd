class_name EntityVisual
extends Node2D

## 表现中介基类 (Visual Bridge Base)
## 负责监听 Entity 的状态变化并驱动视觉效果

@onready var entity: Entity = get_parent() as Entity

var _is_high_priority_playing: bool = false

func _ready() -> void:
	if not entity:
		push_error("EntityVisual 必须作为 Entity 的子节点！")
		return
	
	# 连接基础信号
	entity.health_changed.connect(_on_health_changed)
	entity.damaged.connect(_on_damaged)
	entity.died.connect(_on_died)
	entity.animation_requested.connect(_on_animation_requested)
	
	_setup_visual()

func _setup_visual() -> void:
	# 关键修复：物理复制材质，防止所有实例共享同一个 ShaderMaterial 导致“一被打全闪红”
	var sprite = get_node_or_null("AnimatedSprite2D")
	if sprite and sprite.material:
		sprite.material = sprite.material.duplicate()

func _on_animation_requested(anim_name: String, is_high_priority: bool) -> void:
	if _is_high_priority_playing and not is_high_priority:
		return
	
	_is_high_priority_playing = is_high_priority
	_play_visual_animation(anim_name)

func _play_visual_animation(_anim_name: String) -> void:
	# 子类实现具体播放逻辑 (Sprite or AnimationPlayer)
	pass

func _on_animated_sprite_2d_animation_finished() -> void:
	_is_high_priority_playing = false
	if entity:
		entity.on_action_finished()

func _on_health_changed(_current: float, _max: float) -> void:
	_show_hurt_effect()

func _on_damaged(amount: float) -> void:
	# 表现层决定飘字位置：在实体中心点上方浮动
	var spawn_pos = global_position + Vector2(0, -20)
	var color = entity.stats.damage_text_color if entity.stats else Color.WHITE
	FloatText.show_damage_text(str(amount), spawn_pos, color)

func _on_died(_entity: Entity) -> void:
	_on_animation_requested("die", true)

func _show_hurt_effect() -> void:
	# 查找可能存在的精灵并设置 Shader 参数
	var sprite = get_node_or_null("AnimatedSprite2D")
	if sprite and sprite.material:
		sprite.material.set_shader_parameter("is_hurt", true)
		await get_tree().create_timer(0.1).timeout
		sprite.material.set_shader_parameter("is_hurt", false)

## 公共视觉接口，供外部（如技能表现层）调用，避免直接耦合节点名
func get_weapon_node() -> Node2D:
	return get_node_or_null("Weapon") as Node2D

func get_sprite_node() -> AnimatedSprite2D:
	return get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D
