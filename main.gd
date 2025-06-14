extends Node3D

@onready var camera_positions = $CameraPositions
@onready var camera_3d = $Camera3D

var cam_index = 0
var tween: Tween = null

# Called when the node enters the scene tree for the first time.
func _ready():
	camera_3d.global_position = camera_positions.get_child(cam_index).global_position

func _process(_delta: float):
	if Input.is_action_just_pressed("ui_left"):
		_change_cam(-1)
	if Input.is_action_just_pressed("ui_right"):
		_change_cam(+1)
	if Input.is_action_just_pressed("ui_accept"):
		get_tree().paused = not get_tree().paused
	if Input.is_action_just_pressed("camp"):
		get_tree().change_scene_to_file("res://camp/camp.tscn")

func _change_cam(offset: int):
	cam_index = (cam_index + offset) % camera_positions.get_child_count()
	if tween != null:
		tween.kill()
	tween = create_tween() \
		.set_trans(Tween.TRANS_QUAD) \
		.set_ease(Tween.EASE_OUT)
	tween.tween_property(camera_3d, "global_position", camera_positions.get_child(cam_index).global_position, 0.5)
