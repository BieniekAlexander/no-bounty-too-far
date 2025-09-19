shader_type canvas_item;
const vec4 WHITE = vec4(1,1,1,1);
const vec4 BLACK = vec4(0,0,0,1);
const vec4 BLUE = vec4(0,0,1,1);
//void vertex() {vertex_color = COLOR;}
varying vec4 vertex_color;

void fragment() {
	if (COLOR==WHITE) {
		COLOR = vec4(0,0,0,0);
	}
}