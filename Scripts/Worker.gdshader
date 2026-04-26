shader_type canvas_item;

uniform float stretch_amount = 0.0; 

void vertex() {
	if (VERTEX.y > 0.0) {
		VERTEX.y += stretch_amount;
	} else {
		VERTEX.y -= stretch_amount;
	}
}