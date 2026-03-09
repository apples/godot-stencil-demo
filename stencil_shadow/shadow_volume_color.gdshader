shader_type spatial;
render_mode unshaded, blend_mul, depth_draw_never, cull_back;
stencil_mode read, compare_not_equal, 0, write, write_op_zero;

#include "shadow_volume_vertex.gdshaderinc"

void fragment() {
	ALBEDO = vec3(0.1, 0.1, 0.1);
	ALPHA = 0.5;
}
