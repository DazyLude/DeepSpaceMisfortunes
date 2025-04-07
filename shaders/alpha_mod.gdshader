shader_type canvas_item;

uniform float alpha = 0.5;

void fragment() {
	vec4 newColor = texture(TEXTURE, UV);
	newColor.a *= alpha;
	newColor.r = 0.1;
	newColor.g = 0.1;
	newColor.b = 0.1;
	COLOR = newColor;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
