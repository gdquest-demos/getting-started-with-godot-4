shader_type spatial;
uniform vec3 color : source_color;

float fresnel(float amount, vec3 normal, vec3 view)
{
	return pow((1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0 )), amount);
}


void fragment() {
	float f = fresnel(0.8, NORMAL, VIEW);
	float wave = abs((sin((UV.y - TIME * 0.1) * 10.0 * PI) + 1.0) / 2.0);
	ALBEDO = color;
	EMISSION = color * 2.0;
	ALPHA = step(UV.y, wave) * (1.0 - UV.y) * (1.0 - f);
	
}
