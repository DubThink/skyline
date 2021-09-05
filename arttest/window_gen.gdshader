shader_type canvas_item;

uniform float bchannel;

void fragment(){
	COLOR.r = bchannel;//1f-abs(UV.y+UV.x-.8f);
	COLOR.g = 0.7f;
	COLOR.b = 1f;
}