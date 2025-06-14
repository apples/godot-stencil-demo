@tool
extends Node3D

const PRIORITY_OFFSET = 1
const MAX_PRIORITY = 125
static var next_priority: int = 0

@export var material: Material = preload("uid://b6dbnskt7saxl")
@export var radius: float = 1.0: set = set_radius
@export var intensity: float = 1.0

@onready var light: MeshInstance3D = $Light

func _ready() -> void:
	light.scale = Vector3(radius, radius, radius)
	
	if Engine.is_editor_hint() and Engine.get_singleton("EditorInterface").get_edited_scene_root() == self:
		return
	
	if not material:
		return
	
	var priority = next_priority + PRIORITY_OFFSET
	next_priority = posmod(next_priority + 3, MAX_PRIORITY)
	
	light.material_override = material.duplicate_deep()
	light.material_override.render_priority = priority
	light.material_override.next_pass.render_priority = priority + 1
	light.material_override.next_pass.next_pass.render_priority = priority + 2

func set_radius(v: float) -> void:
	radius = v
	if light:
		light.scale = Vector3(v, v, v)
