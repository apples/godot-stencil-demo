@tool
extends MeshInstance3D
class_name StencilShadow

const STENCIL_VOLUME_MATERIAL = preload("uid://db2ldefe1afo3")

@export var light_source: Light3D

var _original_mesh: Mesh
var _material_instance: ShaderMaterial

func _ready() -> void:
	_material_instance = STENCIL_VOLUME_MATERIAL.duplicate_deep(Resource.DEEP_DUPLICATE_INTERNAL)
	_generate_mesh()
	extra_cull_margin = 50.0

func _process(_delta: float) -> void:
	var light_dir_world: Vector3
	if light_source is OmniLight3D or light_source is SpotLight3D:
		light_dir_world = (light_source.global_position - global_position).normalized()
	elif light_source is DirectionalLight3D:
		light_dir_world = light_source.global_basis.z.normalized()
	_material_instance.set_shader_parameter("light_dir_world", light_dir_world)
	_material_instance.next_pass.set_shader_parameter("light_dir_world", light_dir_world)
	_material_instance.next_pass.next_pass.set_shader_parameter("light_dir_world", light_dir_world)
	
	if _original_mesh != get_parent().mesh:
		_generate_mesh()
	
	skin = get_parent().skin
	skeleton = get_path_to(get_parent().get_node(get_parent().skeleton))
	

func _get_configuration_warnings() -> PackedStringArray:
	var warns = PackedStringArray()
	if get_parent() is not MeshInstance3D:
		warns.append("Parent must be a MeshInstance3D")
	if not light_source:
		warns.append("light_source must be valid")
	return warns

func _validate_property(property: Dictionary) -> void:
	if property.name == "mesh":
		property.usage = PROPERTY_USAGE_EDITOR

func _generate_mesh() -> void:
	if _original_mesh:
		_original_mesh.changed.disconnect(_generate_mesh)
		_original_mesh = null
	
	var p := get_parent() as MeshInstance3D
	if not p or not p.mesh:
		mesh = null
		return
	
	var m := p.mesh as ArrayMesh
	
	var shadow_vertices = PackedVector3Array()
	var shadow_normals = PackedVector3Array()
	var shadow_bones = PackedInt32Array()
	var shadow_weights = PackedFloat32Array()
	var shadow_indices = PackedInt32Array()
	
	# Maps an edge [vertex_1, vertex_2] to [i, j], where
	# shadow_indices[i],shadow_indices[j] is the edge in the shadow surface.
	var edge_tris: Dictionary[PackedVector3Array, PackedInt32Array]
	
	for s in m.get_surface_count():
		assert(m.surface_get_primitive_type(s) == Mesh.PRIMITIVE_TRIANGLES)
		var arrays = m.surface_get_arrays(s)
		var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
		var bones: PackedInt32Array = arrays[Mesh.ARRAY_BONES]
		var weights: PackedFloat32Array = arrays[Mesh.ARRAY_WEIGHTS]
		var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
		assert(not indices.is_empty())
		
		for tri: int in range(0, indices.size(), 3):
			var face_vertices := PackedVector3Array([
				vertices[indices[tri]],
				vertices[indices[tri + 1]],
				vertices[indices[tri + 2]],
			])
			var face_normal = (face_vertices[2] - face_vertices[0]) \
				.cross(face_vertices[1] - face_vertices[0]).normalized()
			var first_idx := shadow_vertices.size()
			shadow_vertices.append_array(face_vertices)
			shadow_normals.append_array([face_normal, face_normal, face_normal])
			shadow_bones.append_array([
				bones[indices[tri] * 4], bones[indices[tri] * 4 + 1], bones[indices[tri] * 4 + 2], bones[indices[tri] * 4 + 3],
				bones[indices[tri + 1] * 4], bones[indices[tri + 1] * 4 + 1], bones[indices[tri + 1] * 4 + 2], bones[indices[tri + 1] * 4 + 3],
				bones[indices[tri + 2] * 4], bones[indices[tri + 2] * 4 + 1], bones[indices[tri + 2] * 4 + 2], bones[indices[tri + 2] * 4 + 3],
			])
			shadow_weights.append_array([
				weights[indices[tri] * 4], weights[indices[tri] * 4 + 1], weights[indices[tri] * 4 + 2], weights[indices[tri] * 4 + 3],
				weights[indices[tri + 1] * 4], weights[indices[tri + 1] * 4 + 1], weights[indices[tri + 1] * 4 + 2], weights[indices[tri + 1] * 4 + 3],
				weights[indices[tri + 2] * 4], weights[indices[tri + 2] * 4 + 1], weights[indices[tri + 2] * 4 + 2], weights[indices[tri + 2] * 4 + 3],
			])
			shadow_indices.append_array([first_idx, first_idx + 1, first_idx + 2])
			for e: int in 3:
				var edge_vertices := PackedVector3Array([
					face_vertices[e],
					face_vertices[(e + 1) % 3],
				])
				var counter_edge_vertices := PackedVector3Array([edge_vertices[1], edge_vertices[0]])
				if counter_edge_vertices not in edge_tris:
					edge_tris[edge_vertices] = PackedInt32Array([
						first_idx + e,
						first_idx + (e + 1) % 3,
					])
				else:
					var counter_edge_shadow_indices := edge_tris[counter_edge_vertices]
					var quad = [
						counter_edge_shadow_indices[0],
						counter_edge_shadow_indices[1],
						first_idx + e,
						first_idx + (e + 1) % 3,
					]
					shadow_indices.append_array([
						quad[0], quad[2], quad[1],
						quad[2], quad[0], quad[3],
					])
					edge_tris.erase(counter_edge_vertices)
	
	var shadow_mesh := ArrayMesh.new()
	var shadow_arrays := []
	shadow_arrays.resize(Mesh.ARRAY_MAX)
	shadow_arrays[Mesh.ARRAY_VERTEX] = shadow_vertices
	shadow_arrays[Mesh.ARRAY_NORMAL] = shadow_normals
	shadow_arrays[Mesh.ARRAY_BONES] = shadow_bones
	shadow_arrays[Mesh.ARRAY_WEIGHTS] = shadow_weights
	shadow_arrays[Mesh.ARRAY_INDEX] = shadow_indices
	shadow_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, shadow_arrays)
	
	mesh = shadow_mesh
	_original_mesh = m
	_original_mesh.changed.connect(_generate_mesh)
	
	set_surface_override_material(0, _material_instance)
