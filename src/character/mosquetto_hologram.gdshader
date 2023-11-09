shader_type spatial;
render_mode depth_prepass_alpha,unshaded, shadows_disabled,cull_back;
#include "res://addons/DunkestrelShaderInc/func.gdshaderinc"
void fragment() {
	float n = random2_1(SCREEN_UV);
	float f = fresnel(2.0,NORMAL,VIEW);
//	f = 1.0 - f;
//	ALBEDO = vec3(f*f);
	ALPHA = f;
//	EMISSION = vec3(f * vec3(0.1,0.1,1.0));
}
