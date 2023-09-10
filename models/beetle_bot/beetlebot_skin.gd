extends Node3D

@export var walk_dist: float = 5
@export var walk_speed: float = 1

var origin: Vector3

func _ready():
	origin = position
	$beetle_bot/AnimationPlayer.play("walk")

func _process(delta):
	position += basis * Vector3.MODEL_FRONT * walk_speed * delta
	if position.distance_to(origin) > walk_dist:
		position = origin
