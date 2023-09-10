extends Node3D

var pivot_point := Vector3(0, 3, -0.3)
var rope_length := 2.0
var swing_angle := deg_to_rad(20.0)
var speed := 3.0
var time := 0.0
@onready var light = $Light

var scale_factor:
	get:
		return light.scale.x
	set(value):
		light.scale = Vector3.ONE * value

func _ready():
	_flicker()

func _process(delta):
	time += delta * speed;
	var a = sin(time) * swing_angle
	light.position = pivot_point + -Vector3(sin(a), cos(a), 0) * rope_length
	light.rotate_x(delta)
	light.scale *= randf_range(0.98, 1.02)

func _flicker():
	var tween = create_tween()
	tween.tween_property(self, "scale_factor", randf_range(0.95, 1.05), 0.2)
	await tween.finished
	_flicker()
