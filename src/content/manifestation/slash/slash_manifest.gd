class_name SlashManifest
extends AbilityManifest

# static静态变量，所有实例共享（内存中只有一份）,程序运行期间一直存在
static var alternate_slash: bool = true

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Hitbox = $Hitbox
@export var rotation_offset: float = 0.0

var cloned_weapon: Node2D
var _original_weapon: Node2D


func _activate(context: AbilityContext):
	var mouse_pos = get_viewport().get_camera_2d().get_global_mouse_position()
	look_at(mouse_pos)

	# 初始化攻击盒数据
	if hitbox:
		if context.ability.stats:
			hitbox.damage_amount = context.ability.stats.parameters.get("damage", 10.0)
			hitbox.knockback_force = context.ability.stats.parameters.get("knockback", 0.0)
		hitbox.team = "Player" # 或者从 context.caster 获取

	# 交替挥砍武器方向
	alternate_slash = not alternate_slash
	animated_sprite.flip_v = alternate_slash

	var visual = context.caster.get_visual()
	if visual:
		_original_weapon = visual.get_weapon_node()

	# 给武器添加一个偏移量
	if _original_weapon != null:
		_original_weapon.hide()
		var base_angle = (mouse_pos - _original_weapon.global_position).angle()
		var offset_rad = deg_to_rad(rotation_offset)

		# 交替挥砍武器方向
		if not animated_sprite.flip_v:
			offset_rad = -offset_rad

		var weapon_angle = base_angle + offset_rad
		var weapon_direction = Vector2(cos(weapon_angle), sin(weapon_angle))

		cloned_weapon = _original_weapon.duplicate() as Node2D
		cloned_weapon.show()
		context.caster.add_child(cloned_weapon)

		# 给武器加上远离角色30的偏移
		cloned_weapon.global_position = context.caster.global_position + weapon_direction * 30

		cloned_weapon.rotation = weapon_angle + PI / 2

func _process(_delta: float) -> void:

	##动画播放完毕后删除该节点，frame_progress可以用来计算动画播放的进度，范围是0.0-1.0，1.0表示动画播放完毕
	if animated_sprite.frame_progress >=1.0:
		_finish_attack()
		

func _finish_attack():
	self.hide()
	
	if is_instance_valid(_original_weapon):
		_original_weapon.show()
		
	if cloned_weapon:
		await get_tree().create_timer(0.1,false).timeout
		cloned_weapon.queue_free()

	queue_free()
