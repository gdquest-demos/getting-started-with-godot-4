shader_type spatial;

uniform vec4 screen_color : source_color;
uniform sampler2D text_sampler : filter_nearest, repeat_enable;

uniform float ratio = 1.0;

uniform float pixel_size = 20.0;

uniform float intensity = 1.5;

void fragment() {
	vec2 scaled_uv = round(UV * pixel_size) / pixel_size;

	vec2 grid_2d = sin(fract(UV * pixel_size + 0.5) * 3.14);
	float grid = grid_2d.x * grid_2d.y;
	grid = grid * 0.6 + 0.4;

	float text = 1.0 - texture(text_sampler, scaled_uv * vec2(ratio, 1.0) + vec2(mod(TIME * 0.1, 1.0), 0.0)).x;

	
	ALBEDO = vec3(0.0);
	SPECULAR = 0.25;
	ROUGHNESS = 0.45;
	
	
	EMISSION = mix(screen_color.rgb * text, screen_color.rgb, screen_color.a) * grid * intensity;
	
}
