shader_type canvas_item;

uniform vec2 brush_position;
uniform float brush_range;
varying vec2 world_position;

void vertex()
{
    world_position = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
	// Called for every pixel the material is visible on.
	if (length(world_position-brush_position)<brush_range) {
		COLOR = vec4(1., 1., 1., 0.);
	} else {
		COLOR = vec4(0., 0., 0., .5);
	}
}