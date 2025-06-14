extends Node3D

const WANDER_RADIUS: float = 5.0
const MOVE_SPEED: float = 3.0
const VELOCITY_SMOOTHING: float = 0.5
const LIGHT_INTENSITY_BASE: float = 0.5
const LIGHT_INTENSITY_AMPLITUDE: float = 0.4
const LIGHT_RADIUS_BASE: float = 1.5
const LIGHT_RADIUS_AMPLITUDE: float = 1.0

var target_position: Vector3
var velocity: Vector3
var sin_freq: float = randf() + 1.0
var sin_amp: float = randf() * 0.5 + 1.0
var time_alive: float = randf() * 10000.0
var time_since_target_change: float = 0.0
var target_change_interval: float = randf_range(2.0, 4.0)

@onready var light_node: Node3D = $WindwakerLight
@onready var glow: MeshInstance3D = $Glow

func _ready() -> void:
	_generate_new_target()

func _process(delta: float) -> void:
	time_alive += delta
	time_since_target_change += delta
	
	if time_since_target_change >= target_change_interval:
		_generate_new_target()
		time_since_target_change = 0.0
		target_change_interval = randf_range(2.0, 4.0)
	
	var direction_to_target: Vector3 = (target_position - global_position).normalized()
	var target_velocity: Vector3 = direction_to_target * MOVE_SPEED
	
	velocity = velocity.lerp(target_velocity, 1.0 - exp(-VELOCITY_SMOOTHING * delta))
	global_position += velocity * delta
	
	var sin_value: float = clampf(sin(time_alive * sin_freq) * sin_amp, -1.0, 1.0)
	light_node.intensity = LIGHT_INTENSITY_BASE + sin_value * LIGHT_INTENSITY_AMPLITUDE
	light_node.radius = LIGHT_RADIUS_BASE + sin_value * LIGHT_RADIUS_AMPLITUDE
	glow.scale = Vector3.ONE * remap(sin_value, -1.0, 1.0, 0.5, 1.0)
	
	var d = position - Vector3(0.0, 1.0, 0.0)
	if d.length() < 3.0:
		position = Vector3(0.0, 1.0, 0.0) + d.normalized() * 3.0

func _generate_new_target() -> void:
	var d = Vector2.from_angle(TAU * randf())
	target_position = position + Vector3(d.x, 0, d.y) * randf() * WANDER_RADIUS
