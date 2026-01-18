class_name FootstepEffect
extends Node2D

@onready var foot_1: CPUParticles2D = $CPUParticles2D
@onready var foot_2: CPUParticles2D = $CPUParticles2D2

func play():
	if not foot_1.emitting:foot_1.restart()

	# create_timer 第二个参数表示是否暂停时也计时，false表示不计时
	await get_tree().create_timer(0.2,false).timeout
	if not foot_2.emitting:foot_2.restart()