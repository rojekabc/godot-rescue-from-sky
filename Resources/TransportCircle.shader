shader_type canvas_item;

uniform vec4 color = vec4(1, 0, 1, 1);

void fragment() {
	float centerDistance = distance(UV, vec2(0.5));
	vec4 textureColor = texture(TEXTURE, UV);
	if (centerDistance <= 0.5 && textureColor.a == 0.0) {
		COLOR = color;
	} else {
		COLOR = textureColor;
	}
}