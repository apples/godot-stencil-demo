extends Node3D

@export var duration_sec: float
@export var mesh: Mesh
@export var opaque_nostencil_material: Material
@export var opaque_stencil_material: Material
@export var transparent_stencil_material: Material

@onready var camera_3d: Camera3D = $Camera3D
@onready var text_edit: TextEdit = $TextEdit

func _ready() -> void:
	var vp_rid: RID = get_tree().root.get_viewport_rid()
	
	RenderingServer.viewport_set_measure_render_time(vp_rid, true)
	
	var N = 5000
	
	for cfg in [
		{ opaque_nostencil = 0, opaque_stencil = 0, transparent_stencil = 0 },
		{ opaque_nostencil = N, opaque_stencil = 0, transparent_stencil = 0 },
		{ opaque_nostencil = 0, opaque_stencil = N, transparent_stencil = 0 },
		{ opaque_nostencil = N, opaque_stencil = N, transparent_stencil = 0 },
		#{ opaque_nostencil = 0, opaque_stencil = 0, transparent_stencil = 0 },
		#{ opaque_nostencil = N, opaque_stencil = 0, transparent_stencil = 0 },
		#{ opaque_nostencil = 0, opaque_stencil = N, transparent_stencil = 0 },
		#{ opaque_nostencil = 0, opaque_stencil = 0, transparent_stencil = N },
		#{ opaque_nostencil = N, opaque_stencil = N, transparent_stencil = 0 },
		#{ opaque_nostencil = 0, opaque_stencil = N, transparent_stencil = N },
		#{ opaque_nostencil = N, opaque_stencil = 0, transparent_stencil = N },
		#{ opaque_nostencil = N, opaque_stencil = N, transparent_stencil = N },
	]:
		_print("{ opaque_nostencil = %s, opaque_stencil = %s, transparent_stencil = %s }" % [cfg.opaque_nostencil, cfg.opaque_stencil, cfg.transparent_stencil])
		
		for i in cfg.opaque_nostencil:
			var mi = MeshInstance3D.new()
			mi.mesh = mesh
			mi.scale = Vector3.ONE * randf_range(0.8, 1.2)
			mi.position = Vector3(
				randf_range(-15.0, 15.0),
				randf_range(-10.0, 10.0),
				randf_range(-0.5, 0.5),
			)
			mi.material_override = opaque_nostencil_material
			add_child(mi)
		
		for i in cfg.opaque_stencil:
			var mi = MeshInstance3D.new()
			mi.mesh = mesh
			mi.scale = Vector3.ONE * randf_range(0.8, 1.2)
			mi.position = Vector3(
				randf_range(-15.0, 15.0),
				randf_range(-10.0, 10.0),
				randf_range(-0.5, 0.5),
			)
			mi.material_override = opaque_stencil_material
			add_child(mi)
		
		for i in cfg.transparent_stencil:
			var mi = MeshInstance3D.new()
			mi.mesh = mesh
			mi.scale = Vector3.ONE * randf_range(0.8, 1.2)
			mi.position = Vector3(
				randf_range(-15.0, 15.0),
				randf_range(-10.0, 10.0),
				randf_range(-0.5, 0.5),
			)
			mi.material_override = transparent_stencil_material
			add_child(mi)
		
		# TODO: Any better ways of waiting for shader compilation?
		for i in 3:
			await get_tree().process_frame
		
		var render_cpu: float = 0.0
		var render_gpu: float = 0.0
		var idle_max: float = 0.0
		var physics_max: float = 0.0
		var frames_captured: int = 0
		
		var time_limit: int = int(duration_sec * 1000000)
		var begin_time: int = Time.get_ticks_usec()
		
		# Wait 1.5 seconds to warm up
		while (Time.get_ticks_usec() - begin_time) < 1500000:
			await get_tree().process_frame
		
		begin_time = Time.get_ticks_usec()
		while (Time.get_ticks_usec() - begin_time) < time_limit:
			await get_tree().process_frame
			
			render_cpu += RenderingServer.viewport_get_measured_render_time_cpu(vp_rid)  + RenderingServer.get_frame_setup_time_cpu()
			render_gpu += RenderingServer.viewport_get_measured_render_time_gpu(vp_rid)
			idle_max = maxf(idle_max, Performance.get_monitor(Performance.TIME_PROCESS) * 1000)
			physics_max = maxf(physics_max, Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS) * 1000)
			frames_captured += 1
		
		render_cpu /= float(max(1.0, float(frames_captured)))
		render_gpu /= float(max(1.0, float(frames_captured)))
		
		_print("render_cpu =      %10.3f" % [render_cpu])
		_print("render_gpu =      %10.3f" % [render_gpu])
		_print("idle_max =        %10.3f" % [idle_max])
		_print("physics_max =     %10.3f" % [physics_max])
		_print("frames_captured = %6d" % [frames_captured])
		
		for i in range(2, get_child_count()):
			get_child(i).queue_free()
		await get_tree().process_frame
		
		_print("---")
	
	_print("Done.")

func _print(what):
	print(what)
	text_edit.text += what + "\n"
	text_edit.get_v_scroll_bar().value = text_edit.get_v_scroll_bar().max_value
