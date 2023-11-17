shader_type canvas_item;

void fragment() {
	if(COLOR.r == 1.0){
		COLOR.a = 0.0;
	}
}
