shader_type sky;

uniform sampler2D clouds_sampler : filter_linear_mipmap;
uniform vec3 top_color : source_color = vec3(1.0);
uniform vec3 bottom_color : source_color = vec3(1.0);
uniform vec3 clouds_tint : source_color = vec3(1.0);


void sky() {
	// Sky gradient
	COLOR = mix(bottom_color.rgb, top_color.rgb, clamp(EYEDIR.y, 0.0, 1.0));

	// Clouds
	vec2 cloud_uv = EYEDIR.xz / EYEDIR.y;
	float cloud_mask = texture(clouds_sampler, cloud_uv * 0.05 + TIME * 0.001).x;
	cloud_mask *= step(SKY_COORDS.y, 0.5) * 
	clamp((1.0 - distance(vec2(0.5), cloud_uv) * 0.1), 0.0, 1.0);
	COLOR.rgb = mix(COLOR.rgb, clouds_tint, cloud_mask);
}
