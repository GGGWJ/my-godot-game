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
			ability.current_cooldown = cooldowns[ability]
 

func trigger_ability_by_idx(idx: int):
	if idx < 0 or idx >= abilities.size():
		print("Ability index %d out of range!" % idx)
		return

	var ability = abilities[idx]
	trigger_ability(ability)

func trigger_ability(ability: Ability):
	if ability == null:
		print("Ability is null!")
		return

	# 健壮性检查：使用字典 get 方法并提供默认值 0.0，避免空值导致比较报错
	if cooldowns.get(ability, 0.0) > 0.0:
		return

	ability.activate(entity)
	
	# 数据驱动：优先从 AbilityStats 获取冷却时间
	var cd: float = ability.cooldown
	if ability.stats:
		cd = ability.stats.cooldown
		
	cooldowns[ability] = cd
