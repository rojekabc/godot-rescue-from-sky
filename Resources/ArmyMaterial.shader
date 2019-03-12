shader_type canvas_item;

uniform vec4 color = vec4(1.0, 0.0, 0.0, 1.0);
uniform float size = 0.25;

uniform float borderSize = 0.015;
uniform vec4 borderColor = vec4(0.0, 1.0, 0.0, 1.0);

uniform float secondBorderSize = 0.06;
uniform vec4 secondBorderColor = vec4(0.0, 0.0, 0.0, 1.0);

void fragment() {
	float pointDistance = distance(UV, vec2(0.5));
	
	// to draw circle
	if (pointDistance <= size) {
		if (pointDistance > size - borderSize) {
			COLOR = borderColor;
		} else if (pointDistance > size - borderSize - secondBorderSize) {
			COLOR = secondBorderColor;
		} else {
			COLOR = color;
		}
	} else {
		discard;
	}
	
}