shader_type canvas_item;
const vec4 WHITE = vec4(1,1,1,1);
const vec4 SIGHT_DRAW = vec4(1,0,0,.2);
varying vec4 vertex_color;

void fragment() {
	if (COLOR.a==0.) {
		COLOR = vec4(0,0,0,0);
	} else {
		COLOR = SIGHT_DRAW;
	}
}