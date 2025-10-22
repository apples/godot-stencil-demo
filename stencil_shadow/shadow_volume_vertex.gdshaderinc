render_mode skip_vertex_transform;

uniform vec3 light_dir_world;

void vertex() {
	vec3 n = MODEL_NORMAL_MATRIX * NORMAL;
	float d = dot(light_dir_world, n);
	vec4 extrude;
	if (d < 0.0) {
		extrude = vec4(light_dir_world * -50.0, 0.0);
	} else {
		extrude = vec4(light_dir_world * -0.001, 0.0);
	}
	vec4 model_v = MODEL_MATRIX * vec4(VERTEX, 1.0);
	VERTEX = (VIEW_MATRIX * (model_v + extrude)).xyz;
	NORMAL = MODELVIEW_NORMAL_MATRIX * NORMAL;
	BINORMAL = MODELVIEW_NORMAL_MATRIX * BINORMAL;
	TANGENT = MODELVIEW_NORMAL_MATRIX * TANGENT;
}
