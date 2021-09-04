shader_type canvas_item;

uniform sampler2D sky_target;
uniform float test;

void fragment() {
	vec2 sky_uv = SCREEN_UV;
	COLOR.rgb = texture(sky_target,sky_uv).rgb;
	
}