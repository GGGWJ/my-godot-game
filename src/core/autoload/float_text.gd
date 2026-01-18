extends Node

@onready var damage_font = preload("res://assets/fonts/damage_font.tres")

func show_damage_text(damage: String,spawn_pos:Vector2,color:Color) -> void:
	var label = Label.new()
	label.text = damage
	label.z_index = 1000

	label.label_settings = LabelSettings.new()

	# 先放大，再缩小让字体高清
	label.label_settings.font_size = 100
	label.scale = Vector2(0.12, 0.12)
	label.label_settings.font_color = color
	label.label_settings.outline_size = 1
	label.label_settings.outline_color = "#000000"
	label.label_settings.font = damage_font

	add_child(label)

	var x_offset = randf_range(-10, 10)
	var spawn_offset = label.size / 2
	label.position = spawn_pos - spawn_offset + Vector2(x_offset, 0)
	label.pivot_offset = spawn_offset

	# 1. 创建Tween动画实例（Godot的动画工具，专门做属性渐变）
	var tween = create_tween()

	# 2. 定义X轴动画：Label的X坐标从当前值 → 当前X+x_offset，耗时0.35秒
	tween.tween_property(label, "position:x", label.position.x + x_offset,0.35)
	# 3. 设置动画缓动效果：指数曲线+先快后慢（EASE_OUT），移动更自然（不是匀速）
	# set_ease()：控制动画速度变化的趋势（先快后慢 / 先慢后快），核心是 “时机”；
	# set_trans()：控制动画速度变化的曲线形状（直线 / 指数 / 正弦 / 弹跳），核心是 “顺滑度 / 风格”；
	tween.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)

	# 4. 关键：设置后续动画和前面的X轴动画“并行执行”（同时开始）
	tween.parallel()

	# 5. 定义Y轴动画：Label的Y坐标从当前值 → 当前Y-10（向上移30像素），耗时0.3秒
	tween.tween_property(label, "position:y", label.position.y + -10,0.3)
	# 6. Y轴动画也用同样的缓动效果（先快后慢）
	tween.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)

	tween.parallel()
	tween.tween_property(label, "scale", Vector2.ZERO ,0.4).set_ease(Tween.EASE_IN)

	# 7. 暂停代码执行，等待整个Tween动画全部完成（X轴2秒结束，所以等2秒） 
	await tween.finished
	# 8. 动画结束后，销毁Label节点（释放内存，避免卡顿）
	label.queue_free()
