shader_type canvas_item;

uniform sampler2D voronoi_sampler : repeat_enable;
uniform sampler2D edge_curve;
uniform float offset = 0.0;
uniform vec2 texture_offset = vec2(0.0);
uniform sampler2D color_gradient : source_color;

void fragment() {
	float voronoi = 1.0 - texture(voronoi_sampler, UV * 0.25 + texture_offset).x;
	float d = distance(UV, vec2(0.5)) * 2.0;
	float n_smooth_d = (voronoi * offset) * texture(edge_curve, vec2(d, 0.0)).x;
	COLOR.a *= step(0.5, n_smooth_d);
	COLOR.rgb = texture(color_gradient, vec2(n_smooth_d, 0.0)).rgb;
}
