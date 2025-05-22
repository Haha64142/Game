shader_type spatial;
render_mode alpha_to_coverage;

uniform float alpha_value : hint_range(0, 1);
uniform sampler2DArray texture_albedo;
uniform int index;


void fragment() {
	vec4 albedo_tex = texture(texture_albedo, vec3(UV, float(index)));
	ivec3 albedo_texture_size = textureSize(texture_albedo, index);
	ALPHA = alpha_value;
	ALPHA_TEXTURE_COORDINATE = UV * vec2(float(albedo_texture_size.x), float(albedo_texture_size.y));
	ALBEDO = albedo_tex.rgb;
}
