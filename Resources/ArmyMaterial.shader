shader_type canvas_item;

uniform vec4 color = vec4(1.0, 0.0, 0.0, 1.0);

void fragment() {
	vec4 textureColor = texture(TEXTURE, UV);
	if (textureColor.a >= 0.047 && textureColor.a < 0.048) {
		COLOR = color;
	} else {
		COLOR = textureColor;
	}
}