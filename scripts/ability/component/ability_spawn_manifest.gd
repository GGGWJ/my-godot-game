class_name AbilitySpawnManifest
extends AbilityComponent


@export var manifest_scene: PackedScene

## 是否将生成的物体作为实体的子节点
@export var set_as_child: bool = false

##特效的偏移
@export var spawn_offset: Vector2 = Vector2.ZERO

func _activate(context: AbilityContext):
	if manifest_scene == null:
		print("No object scene assigned to SpawnObjectAC.")
		return
	
	##告诉编辑器这个节点是个Node2D类型，方便节点识别调用AbilityManifest的方法
	var ability_manifest = manifest_scene.instantiate() as AbilityManifest
	var caster = context.caster

	if set_as_child:
		caster.add_child(ability_manifest)
	else:
		var root = get_tree().get_root()
		ability_manifest.position = caster.position
		root.add_child(ability_manifest)

	ability_manifest.position += spawn_offset
	ability_manifest.activate(context)
