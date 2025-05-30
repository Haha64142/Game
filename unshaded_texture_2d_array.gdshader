shader_type spatial;

render_mode unshaded;

uniform sampler2DArray texture_albedo;
uniform int index;
uniform ivec2 test = ivec2(16, 16);

void fragment() {
	vec2 new_UV = vec2(round(UV.x * float(test.x)) / float(test.x), round(UV.y * float(test.y)) / float(test.y));
	vec4 albedo_tex = texture(texture_albedo, vec3(new_UV, float(index)));
	ALPHA *= albedo_tex.a;
	ALBEDO = albedo_tex.rgb;
}
