class_name SpellButton
extends TextureButton

var ability:Ability = null
@export var icon:TextureRect
@export var progress_bar:TextureProgressBar
@export var cooldownlabel:Label
@export var keybind_label:Label


# 在 GDScript 中，普通变量赋值只是简单的数值替换
# 但通过set(参数名):定义 setter 后，每次给该变量赋值时，都会先执行 setter 里的代码，再完成赋值

# 定义内部变量存储实际值（加下划线区分）
var _binded_key: String = ""
# 对外暴露的变量，绑定自定义setter
var binded_key: String:
	# 获取值时返回内部变量（可选的getter）用来当外部调用binded_key，可以获得_binded_key里的实际值
	get:
		return _binded_key
	# 设置值时执行自定义逻辑
	set(key):
		# 先把新值存到内部变量，避免递归
		_binded_key = key
		# 同步创建/更新快捷键
		var shortcut = Shortcut.new()
		var input_key = InputEventKey.new()
		# 注意：unicode_at(0)仅适用于单字符（如"a"），多字符需额外处理
		if key != "":
			input_key.keycode = key.unicode_at(0)
			shortcut.events = [input_key]
		cooldownlabel.text = ""
		keybind_label.text = key

func _process(delta: float):
	if ability == null:
		return
	
	disabled = ability.current_cooldown > 0.0
	progress_bar.value = ability.current_cooldown
	# 3.1f中，f是浮点数类型标识，.1表示保留 1 位小数，3表示字符串最小宽度为 3（不足补空格），让字符串大小保持一致；

	if disabled:
		cooldownlabel.text = "%3.1f" % ability.current_cooldown
	else:
		cooldownlabel.text = ""

func set_ability(_ability:Ability):
	print("绑定技能：%s" % _ability.name)

	# 自带的禁用技能按钮功能，disabled=false表示启用按钮
	disabled = false
	ability = _ability
	icon.texture = _ability.icon_texture
	progress_bar.max_value = _ability.cooldown
	cooldownlabel.text = ""

func _on_pressed() -> void:
	if ability == null: 
		print("技能没有绑定") 
		return
	
	if disabled:
		print("技能冷却中，无法释放")
		return

	disabled = true
	
	EventBus.play_cast_ability.emit(ability)
