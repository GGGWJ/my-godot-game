class_name DamageData
extends RefCounted

## 战斗载荷数据
## 职责：在 Hitbox 和 Hurtbox 之间传递所有伤害相关信息

var amount: float = 0.0          # 伤害数值
var source_node: Node            # 来源节点（谁打出的伤害）
var knockback_force: float = 0.0 # 击退力量
var direction: Vector2 = Vector2.ZERO # 伤害方向
var element_type: String = ""    # 属性（火、冰等）

func _init(_amount: float = 0.0, _source: Node = null, _knockback: float = 0.0, _direction: Vector2 = Vector2.ZERO) -> void:
	self.amount = _amount
	self.source_node = _source
	self.knockback_force = _knockback
	self.direction = _direction
