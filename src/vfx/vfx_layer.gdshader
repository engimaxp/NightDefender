shader_type canvas_item;
uniform vec4 tint_color:source_color = vec4(1.0);
uniform float display_range = 1.0;

void fragment() {
	COLOR = texture(TEXTURE,UV);
	COLOR.rgb *= tint_color.rgb;
	COLOR.a = COLOR.r * display_range;
	
}
