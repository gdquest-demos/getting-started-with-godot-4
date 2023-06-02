shader_type sky;

uniform vec3 top_color : source_color = vec3(1.0);
uniform vec3 bottom_color : source_color = vec3(1.0);
uniform sampler2D gradient_curve;

void sky() {
	// gradient
	COLOR = mix(bottom_color.rgb, top_color.rgb, texture(gradient_curve, vec2(SKY_COORDS.y, 0.0)).x);
}
