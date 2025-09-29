shader_type canvas_item;
const vec4 WHITE = vec4(1,1,1,1);
const vec4 SIGHT_DRAW = vec4(1,0,0,.2);
uniform float vision_angle;
uniform vec2 agent_position;
uniform vec2 sight_vector;

void fragment() {
	float angle = acos(dot(normalize(VERTEX - agent_position), sight_vector));
	
	if (COLOR.a==0. || angle > vision_angle) {
		COLOR = vec4(0,0,0,0);
	} else {
		COLOR = SIGHT_DRAW;
	}
}