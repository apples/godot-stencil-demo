shader_type spatial;
render_mode depth_draw_never, cull_back, unshaded, depth_test_disabled;
stencil_mode write, 0;

void fragment() {
	ALPHA = 0.0;
}
