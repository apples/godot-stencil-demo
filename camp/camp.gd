extends Node3D

const FIREFLY = preload("uid://sgmsgo10h2wg")

var flame_color_material: StandardMaterial3D = preload("uid://7lvck5nms6yf")
var flame_stencil_material: StandardMaterial3D = preload("uid://wqtqmpa0icay")

var _time: float = 0.0

@onready var camera_gimbal: Marker3D = $CameraGimbal
@onready var campfire_light: OmniLight3D = $CampfireLight

func _ready() -> void:
	for i in 50:
		var r = randf() * 50.0 + 3.0
		var v = Vector2.from_angle(randf() * TAU)
		var n = FIREFLY.instantiate()
		n.position = Vector3(v.x * r, 1.0, v.y * r)
		add_child(n)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("camp"):
		get_tree().change_scene_to_file("res://main.tscn")
	
	_time += delta * 0.5
	camera_gimbal.rotation.y += delta * 0.075
	flame_color_material.uv1_offset.y += delta * 0.15
	flame_stencil_material.uv1_offset.y += delta * 1.2
