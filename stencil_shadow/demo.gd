@tool
extends Node3D

@onready var beetlebot_skin: Node3D = $BeetlebotSkin
@onready var animation_player: AnimationPlayer = $BeetlebotSkin/beetle_bot/AnimationPlayer
@onready var csg_box_3d_2: CSGBox3D = $CSGBox3D2

func _ready() -> void:
	animation_player.play("walk")

func _process(delta: float) -> void:
	beetlebot_skin.rotation.x += delta * 0.12
	beetlebot_skin.rotation.y += delta * 0.32
	beetlebot_skin.rotation.z += delta * 0.72
	csg_box_3d_2.rotation.y += delta * 0.5
