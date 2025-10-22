shader_type spatial;
render_mode unshaded, blend_mix, depth_draw_never, cull_back;
stencil_mode 1, write_depth_fail, write_op_decrement_and_wrap;

#include "shadow_volume_vertex.gdshaderinc"

void fragment() {
	ALBEDO = vec3(0.0, 0.0, 0.0);
	ALPHA = 0.0;
}
