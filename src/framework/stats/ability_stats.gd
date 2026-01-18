class_name AbilityStats
extends Resource

## 技能基础配置资源 (Ability Configuration Resource)

@export_group("Basic Info")
@export var ability_name: String = "New Ability"
@export var icon: Texture2D
@export var description: String = ""

@export_group("Common Parameters")
@export var cooldown: float = 1.0
@export var mana_cost: float = 0.0

@export_group("Advanced Parameters")
## 用于存储特定组件需要的数值 (如：radius, damage, force)
## 键名应与组件所需的参数名保持一致
@export var parameters: Dictionary = {
	"damage": 10.0,
	"radius": 50.0,
	"speed": 100.0,
	"duration": 0.5
}
