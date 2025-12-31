shader_type canvas_item;

instance uniform vec3 skin_color : source_color;
instance uniform vec3 hair_color : source_color;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec3 normal_color = COLOR.rgb;
	//float skin_mix = clamp(COLOR.r - ((COLOR.g+COLOR.b)*1024.0), 0.0, 1.0);
	if(COLOR.g == 0.0 && COLOR.b == 0.0) {
		COLOR.rgb = skin_color*COLOR.r;
	}
	if(COLOR.r == 0.0 && COLOR.b == 0.0) {
		COLOR.rgb = hair_color*COLOR.g;
	}
}
