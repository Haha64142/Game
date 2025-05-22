shader_type spatial;

uniform sampler2DArray texture_albedo;
uniform int index;


void fragment() {
	vec4 albedo_tex = texture(texture_albedo, vec3(UV, float(index)));
	ALPHA *= albedo_tex.a;
	ALBEDO = albedo_tex.rgb;
}
