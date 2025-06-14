shader_type spatial;
render_mode blend_mul, depth_draw_never, cull_front, unshaded, depth_test_inverted;
stencil_mode read, compare_not_equal, 2;

uniform vec4 color : source_color = vec4(1, 1, 1, 1);

void fragment() {
	ALBEDO = color.rgb;
	ALPHA *= color.a;
}
