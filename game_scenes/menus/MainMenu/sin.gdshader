shader_type canvas_item;

uniform float bob_amplitude = 0.5; //The up and down-ness
uniform float bob_speed = 4.0;     //How fast it bobs

void vertex() {
	VERTEX.y += sin(TIME * bob_speed) * bob_amplitude;
}
