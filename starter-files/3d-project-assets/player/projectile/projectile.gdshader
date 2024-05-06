shader_type spatial;
render_mode ambient_light_disabled, shadows_disabled, unshaded;

uniform vec3 tail_color : source_color;
uniform vec3 head_color : source_color;

void vertex() {
	float def = sin(UV.y * 2.0 * PI - TIME * 20.0) + 1.0 / 2.0;
	VERTEX.xz += NORMAL.xz * def * 0.05 * UV.y * COLOR.x;
}

void fragment() {
	ALBEDO = mix(head_color, tail_color, COLOR.x);
}
