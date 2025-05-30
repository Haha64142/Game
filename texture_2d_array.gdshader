shader_type spatial;

uniform sampler2DArray texture_albedo;
uniform int index;
uniform float size = 16;

void fragment() {
	vec2 new_UV = vec2(round(UV.x * size) / size, round(UV.y * size) / size);
	vec4 albedo_tex = texture(texture_albedo, vec3(new_UV, float(index)));
	ALPHA *= albedo_tex.a;
	ALBEDO = albedo_tex.rgb;
}
