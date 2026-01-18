class_name AbilityTrail
extends AbilityComponent

@export var duration: float = 0.25
@export var ghost_interval: float = 0.05 # 产生残影的间隔
@export var ghost_lifetime: float = 0.3 # 残影消失的时间

func _activate(context: AbilityContext):
	var caster = context.caster
	var sprite = caster.find_child("AnimatedSprite2D", true, false) as AnimatedSprite2D
	
	if not sprite:
		return

	var end_time = Time.get_ticks_msec() + (duration * 1000)
	
	while Time.get_ticks_msec() < end_time:
		_create_ghost(caster, sprite)
		await caster.get_tree().create_timer(ghost_interval).timeout

func _create_ghost(caster: Node2D, sprite: AnimatedSprite2D):
	# 创建一个临时的 Sprite 用于显示残影
	var ghost = Sprite2D.new()
	
	# 下面的设置是为了让残影看起来和当前时刻的玩家一模一样
	ghost.texture = sprite.sprite_frames.get_frame_texture(sprite.animation, sprite.frame)
	ghost.global_position = sprite.global_position
	ghost.flip_h = sprite.flip_h
	ghost.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST # 保持像素风格
	
	# 设置视觉效果：半透明、稍微变暗或变色
	ghost.modulate = Color(0.6, 0.8, 1.0, 0.6) # 浅蓝色调，增强“虚幻”感
	ghost.z_index = caster.z_index - 1 # 放在玩家层级下面
	
	# 关键：添加到根节点，防止残影跟着玩家移动
	caster.get_tree().root.add_child(ghost)
	
	# 渐隐消失并自动销毁
	var tween = ghost.create_tween()
	tween.tween_property(ghost, "modulate:a", 0.0, ghost_lifetime)
	tween.tween_callback(ghost.queue_free)
