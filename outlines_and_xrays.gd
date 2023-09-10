extends Node3D

var speed = 1.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	rotate_y(delta * speed)
