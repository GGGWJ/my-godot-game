class_name Hitbox
extends Area2D

## 攻击盒组件 (Hitbox)
## 职责：主动寻找并“揍” Hurtbox

signal hit_hurtbox(hurtbox: Hurtbox)

@export var damage_amount: float = 10.0
@export var knockback_force: float = 0.0

# 阵营标识，防止误伤（可以通过 Layer 解决，也可以通过代码逻辑解决）
@export_enum("Player", "Enemy", "Neutral") var team: String = "Neutral"

func _ready() -> void:
	# 自动设置监控属性
	monitoring = true
	monitorable = false # 攻击盒不需要被别人监控，它去监控别人
	
	# 连接自身的区域进入信号
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	if area is Hurtbox:
		var hurtbox = area as Hurtbox
		
		# 1. 简单的阵营检查
		if hurtbox.team == self.team:
			return
		
		# 2. 构造战斗载荷数据
		var damage_data = DamageData.new()
		damage_data.amount = damage_amount
		damage_data.source_node = owner # 伤害来源是挂载该场景的根节点
		damage_data.knockback_force = knockback_force
		damage_data.direction = (hurtbox.global_position - global_position).normalized()
		
		# 3. “握手”：把数据交给受击盒
		hurtbox.handle_hit(damage_data)
		
		hit_hurtbox.emit(hurtbox)
