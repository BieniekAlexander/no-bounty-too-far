shader_type canvas_item;
const vec4 WHITE = vec4(1,1,1,1);
const vec4 BLACK = vec4(0,0,0,1);
//void vertex() {vertex_color = COLOR;}
varying vec4 vertex_color;

void fragment() {
	vertex_color = COLOR;
	int alpha = int(vertex_color.z * 255.0);
	if (vertex_color==WHITE) {
		COLOR = vec4(0,0,0,0);
	}
	else {
		COLOR = vec4(0,0,0,1);
	}
}