class_name AbilityController
extends Node

var abilities: Array[Ability] = []
var cooldowns: Dictionary = {}
var entity: Entity = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	entity = get_parent() as Entity

	for child in get_children():
		if child is Ability:
			abilities.push_back(child)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for ability in cooldowns.keys():
		if cooldowns[ability] > 0.0:
			cooldowns[ability] = max(cooldowns[ability] - delta, 0.0)
 

func trigger_ability_by_idx(idx: int):
	if abilities.size() == 0:
		print("Ability index %d out of range!" % idx)
		return

	var ability = abilities.get(idx)
	_trigger_ability(ability)

func _trigger_ability(ability: Ability):
	if ability == null:
		print("Ability is null!")
		return

	# cooldowns.get(ability) 无默认值时，键不存在会返回null，null和数字比较会直接报错；
	# cooldowns.get(ability,0.0) 强制返回 float 类型（存在返回冷却时间，不存在返回 0.0），保证比较逻辑不报错；
	# 这是 GDScript 处理字典的核心健壮性技巧，尤其是数字比较 / 运算场景，一定要给默认值，避免空值导致程序崩溃。
	if cooldowns.get(ability,0.0) >0.0 :
		return

	ability.activate(entity)
	cooldowns[ability] = ability.cooldown