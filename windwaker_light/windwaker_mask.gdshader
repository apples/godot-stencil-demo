shader_type spatial;
render_mode depth_draw_never, cull_back, unshaded;
stencil_mode write_depth_fail, 2;

void fragment() {
	ALPHA = 0.0;
}
