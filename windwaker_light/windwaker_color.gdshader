shader_type spatial;
render_mode blend_mix, depth_draw_never, cull_front, unshaded, depth_test_inverted;
stencil_mode read, compare_not_equal, 2, write_stencil_fail, write_op_zero;

uniform vec4 color : source_color = vec4(1, 1, 1, 1);

void fragment() {
	ALBEDO = color.rgb;
	ALPHA *= color.a;
}
