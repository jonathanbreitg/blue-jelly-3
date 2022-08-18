shader_type canvas_item;
uniform float r = 0.0;
uniform float g = 0.0;
uniform float b = 0.0;

void fragment(){
	COLOR = texture(TEXTURE, UV);
	if ((COLOR.a > 0.0)){
		COLOR = vec4(r,g,b,1.0)
	//COLOR += vec4(r,g,b,1.0);
	}
}